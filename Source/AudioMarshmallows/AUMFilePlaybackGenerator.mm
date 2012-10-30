/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import <tgmath.h>
#import "AUMFilePlaybackGenerator.h"

#import "MarshmallowCocoa.h"
#import "AUMAudioFileReader.h"
#import "AUMAudioSession.h"
#import "AUMAudioFileReader.h"
#import "AUMUnitAbstract.h"
#import "Private/AUMFilePlaybackGeneratorRCB.h"
#import "Private/AUMRendererAudioSource.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMFilePlayerUnit
/////////////////////////////////////////////////////////////////////////

@implementation AUMFilePlaybackGenerator
{
    id <MThreadProtocol> _updateThread;
    
    AUMFilePlaybackGeneratorRCB *_renderer;     ///< C++
    AUMRendererAudioSource *_audioSource;       ///< Holds the buffer for the RCB to read from (C++)
    AUMAudioFileReader *_audioFile;             ///< File reader to feed the _audioSource (ObjC)
    
    NSInvocation *_cbPlaybackDidOccurInvoc;     // used to cancel on change or nil
    
    NSTimeInterval _sampleRate;
    
    /** The amount to add to the value reported by the source to determine the actual play position.  Set on seek when the source is reset to a non-zero starting point 
     
        A Float to correspond to RendererSource (as it can be a decimal with pitch scaled reads.)
     */
    Float32 _sourcePosOffsetInFrames;
    
    /** @name Seek state vars. Cache settings to process after source is paused */
    /// @{
    BOOL _seekIsPending;
    AUMRendererAudioSource::State _sourceStateToResumeAfterSeek;
    NSUInteger _seekToFrame;
    /// @}
    
    /** @name Seek state vars. Cache settings to process after source is paused */
    /// @{
    BOOL _audioFileChangeIsPending;
    AUMRendererAudioSource::State _sourceStatetoResumeAfterFileChange;
    AUMAudioFileReader *_audioFileToChangeTo;
    /// @}

}

@synthesize renderCallbackStruct=_renderCallbackStruct;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

- (id)initWithDiskBufferSizeInBytes:(NSUInteger)aDiskBufferSizeInBytes
                       updateThread:(id<MThreadProtocol>)anUpdateThread updateInterval:(NSTimeInterval)anUpdateInterval
{
    // Get the params from AUMAudioSession
    NSTimeInterval sr = AUMAudioSession.currentHardwareSampleRate;
    NSTimeInterval ioBuff = AUMAudioSession.IOBufferDuration;
    
    // Does this indicate not currently set??
    if (sr == 0 || ioBuff == 0) {
        [NSException raise:NSInternalInconsistencyException format:@"Sample rate and IOBufferDuration must be set on Audio Session prior to using this initialiser"];
    }
    
    return [self initWithSampleRate:sr
              diskBufferSizeInBytes:aDiskBufferSizeInBytes
                   ioBufferDuration:ioBuff
                       updateThread:anUpdateThread
                     updateInterval:anUpdateInterval];
}

/////////////////////////////////////////////////////////////////////////

/** Create an underlying RemoteIO unit and set our callback to it */
- (id)initWithSampleRate:(Float64)theSampleRate
   diskBufferSizeInBytes:(NSUInteger)aDiskBufferSizeInBytes
        ioBufferDuration:(NSTimeInterval)theIOBufferDuration
            updateThread:(id<MThreadProtocol>)anUpdateThread
          updateInterval:(NSTimeInterval)anUpdateInterval
{
    /////////////////////////////////////////
    // SETUP REMOTEIO UNIT
    /////////////////////////////////////////
    _audioSource = NULL;
    _loop = NO;
    _sourcePosOffsetInFrames = 0;
    _seekIsPending = NO;
    _sampleRate = theSampleRate;
    _playbackDidOccurUpdateInterval = 0.5; // 1/2 second default
    _autoRewindOnFinished = YES;
    
    // Set up the C++ renderer and set our properties to fulfill the AUMGeneratorRenderer protocol
    NSUInteger ioBufferInFrames = ceil(theSampleRate * theIOBufferDuration);
    _renderer = new AUMFilePlaybackGeneratorRCB(ioBufferInFrames, theSampleRate);
    _renderCallbackStruct.inputProc = &AUMFilePlaybackGeneratorRCB::renderCallback;
    _renderCallbackStruct.inputProcRefCon = (void *)_renderer;    

    // Grab the audioSource from the renderer and initialise its buffer
    _audioSource = _renderer->audioSource();
    _audioSource->initializeBuffer(aDiskBufferSizeInBytes, _renderer->requiredAudioFormat().mBytesPerFrame);
    
    
    /////////////////////////////////////////
    // SETUP SOURCE UPDATE THREAD
    /////////////////////////////////////////

    // Create an invocation to call our update method
    _updateThread = anUpdateThread;
    __weak id weakSelf = self;      // Watch out for circular references here
    NSInvocation *inv = [NSInvocation mm_invocationWithTarget:weakSelf block:^(id target) {
        [target _updateSource];
    }];
    [anUpdateThread addInvocation:inv desiredInterval:anUpdateInterval];

    return self;
}

/////////////////////////////////////////////////////////////////////////

- (void)dealloc
{
    [_updateThread cancel];
    _audioSource = NULL;
    if (_renderer)
        delete _renderer;
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Property Accessors
/////////////////////////////////////////////////////////////////////////

- (NSURL *)fileURL
{
    if (_audioFile)
        return _audioFile.fileURL;
    return nil;
}

/////////////////////////////////////////////////////////////////////////

- (void)setVolume:(AUMAudioControlParameter)volume
{
    _audioSource->volume(volume);
}

/////////////////////////////////////////////////////////////////////////

- (AUMAudioControlParameter)volume
{
    return _audioSource->volume();
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)isPlaying
{
    // QueuedToPause will be considered not isPlaying to the client end.  This could have some implications...
    return (_audioSource->state() == AUMRendererAudioSource::Playing);
}

/////////////////////////////////////////////////////////////////////////

- (NSUInteger)playheadPosFrames
{
    // modulus to take into account looping
    return (NSUInteger)round(_sourcePosOffsetInFrames + _audioSource->playheadPosInFrames()) % _audioFile.lengthInFrames;
}

- (NSTimeInterval)playheadPosTime
{
    return self.playheadPosFrames / _sampleRate;
}

- (NSUInteger)audioFileLengthInFrames
{
    if (!_audioFile) return 0;
    return _audioFile.lengthInFrames;
}

/////////////////////////////////////////////////////////////////////////

@synthesize cbPlaybackDidOccur=_cbPlaybackDidOccur;

- (void (^)(AUMFilePlaybackGenerator *, NSUInteger, NSTimeInterval))cbPlaybackDidOccur
{
    @synchronized(self) {
        return _cbPlaybackDidOccur;
    }
}

- (void)setCbPlaybackDidOccur:(void (^)(AUMFilePlaybackGenerator *, NSUInteger, NSTimeInterval))aBlock
{
    // Remove the old invocation
    if (_cbPlaybackDidOccurInvoc) {
        [_updateThread removeInvocation:_cbPlaybackDidOccurInvoc];
        _cbPlaybackDidOccurInvoc = nil;
    }
 
    if (aBlock) {
        // The @synchros here and on the getter ensure any partially executed blocks finish before the property gets reassigned
        @synchronized(self) {
            _cbPlaybackDidOccur = aBlock;
            __weak id weakSelf = self;
            _cbPlaybackDidOccurInvoc = [NSInvocation mm_invocationWithTarget:weakSelf block:^(id target) {
                [target _callPlaybackDidOccurCallback];
            }];
            [_updateThread addInvocation:_cbPlaybackDidOccurInvoc desiredInterval:_playbackDidOccurUpdateInterval];
        }
    }
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)loadAudioFileFromURL:(NSURL *)fileURL
{
    // Load the file
    AUMAudioFileReader *newFile = [AUMAudioFileReader audioFileForURL:fileURL];
    newFile.outFormat = _renderer->requiredAudioFormat();
    
    @synchronized(self) {
        _seekIsPending = NO; // just in case its possible

        // If stopped then do it straight away
        if (_audioSource->state() == AUMRendererAudioSource::Paused ||
            _audioSource->state() == AUMRendererAudioSource::Finished) {
            
            
            _audioFile = newFile;
            [self _rebufferAudioFileFromFrame:0];
            return;
        }
        
        
        // Otherwise indicate to our control loop to handle it once the source is paused...
        
        // Get the state to resume if we havent set it already in a very recent prior call (in which case it will always be QueuedToPause)
        // If its QueuedToPause then this took place immediately after a [pause] message.  Otherwise we were Playing and should resume as such
        if (!_audioFileChangeIsPending) {
            _sourceStatetoResumeAfterFileChange =
                (_audioSource->state() == AUMRendererAudioSource::QueuedToPause)
                    ? AUMRendererAudioSource::Paused
                    : AUMRendererAudioSource::Playing;
        }
        
        _audioSource->pause();  // WARNING: Doesn't happen straight away! Hence all this...
        _audioFileToChangeTo = newFile;
        _audioFileChangeIsPending = YES;
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)unloadAudioFile
{
    @synchronized(self) {
        _seekIsPending = NO; // just in case its possible
        _audioFileChangeIsPending = NO;
        
        // Pause and wait...
        if (_audioSource->state() != AUMRendererAudioSource::Paused &&
            _audioSource->state() != AUMRendererAudioSource::Finished) {
            
            _audioSource->pause();
            while (_audioSource->state() == AUMRendererAudioSource::QueuedToPause) {
                usleep(100);
            }
        }
        
        _audioFile = nil;
        _audioSource->reset();      // Reset volume etc too
        _sourcePosOffsetInFrames = 0;
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)play
{
    @synchronized(self) {
        if (!_audioFile) [NSException raise:NSInternalInconsistencyException format:@"File must be loaded first"];

        // If finished, rewind first
        if (_audioSource->state() == AUMRendererAudioSource::Finished) {
            [self seekToFrame:0];
        }
        
        _audioSource->play();
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)pause
{
    @synchronized(self) {
        if (!_audioFile) {
            MMLogWarn(@"Pause called when no file was loaded");
        }
        if (self.isPlaying) {
            _audioSource->pause();
        } else {
            MMLogWarn(@"Pause called when already paused/stopped on %@", self);
        }
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)stop
{
    @synchronized(self) {
        if (!_audioFile) [NSException raise:NSInternalInconsistencyException format:@"File must be loaded first"];

        if (self.isPlaying) {
            [self pause];
            [self seekToFrame:0];
        } else {
            MMLogWarn(@"Stop called when already paused/stopped on %@", self);
        }
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)rewind
{
    @synchronized(self) {
        [self seekToFrame:0];
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)seekToFrame:(NSUInteger)toFrame
{
    @synchronized(self) {
        if (!_audioFile) [NSException raise:NSInternalInconsistencyException format:@"File must be loaded first"];
        
        // Sanity check for file length
        if (toFrame >= _audioFile.lengthInFrames) {
            [NSException raise:NSRangeException format:@"Frame %u exceeds file's max length of %i", toFrame, _audioFile.lengthInFrames];
        }

        // If stopped then do it straight away
        if (_audioSource->state() == AUMRendererAudioSource::Paused ||
            _audioSource->state() == AUMRendererAudioSource::Finished) {
            
            [self _rebufferAudioFileFromFrame:toFrame];
            return;
        }
        
        // Otherwise indicate to our control loop to handle it once the source is paused...
        
        // Get the state to resume if we havent set it already in a very recent prior call (in which case it will always be QueuedToPause)
        // If its QueuedToPause then this took place immediately after a [pause] message.  Otherwise we were Playing and should resume as such
        if (!_seekIsPending) {
            _sourceStateToResumeAfterSeek =
            (_audioSource->state() == AUMRendererAudioSource::QueuedToPause)
            ? AUMRendererAudioSource::Paused
            : AUMRendererAudioSource::Playing;
        }

        _audioSource->pause();  // WARNING: Doesn't happen straight away! Hence all this...
        _seekToFrame = toFrame;
        _seekIsPending = YES;
    }

}


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMGeneratorRendererProtocol
/////////////////////////////////////////////////////////////////////////

/// Set the stream format for the input bus
- (void)willAttachToInputBus:(NSUInteger)anInputBusNum ofAUMUnit:(AUMUnitAbstract *)anAUMUnit
{
    [anAUMUnit setStreamFormat:_renderer->requiredAudioFormat() forInputBus:anInputBusNum];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////

- (void)_updateSource
{
    @synchronized(self) {
        [self _processPendingAudioFileChangeOperation];
        if (_audioFile) {
            [self _processPendingSeekOperation];
            [self _replenishSourceBuffer];
        }
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)_processPendingAudioFileChangeOperation
{
    if (!_audioFileChangeIsPending) return;
    
    // Sanity check.  Playing shouldnt be if _seekIsPending is true
    if (_audioSource->state() == AUMRendererAudioSource::Playing) {
        [NSException raise:NSInternalInconsistencyException format:@"Shouldn't be!"];
    }
    
    // If we're not yet paused then do nothing
    if (_audioSource->state() == AUMRendererAudioSource::QueuedToPause) return;
    
    // Otherwise (Paused or Finished) do the deed...
    // Rebuffer and play if we were before the call
    _audioFile = _audioFileToChangeTo;
    
    // Could be nil...
    if (_audioFile) {
        [self _rebufferAudioFileFromFrame:0];
    
        if (_sourceStatetoResumeAfterFileChange == AUMRendererAudioSource::Playing)
            _audioSource->play();
    }
    _audioFileChangeIsPending = NO;
}

/////////////////////////////////////////////////////////////////////////

/** \brief Handle outstanding seek request.
    Seeking first requires that the source be paused.  Thus we need to perform the actual seek operation on a subsequent update.  NOT Thread Safe.  Make sure this is called in the same thread as _replenishSourceBuffer
 */
- (void)_processPendingSeekOperation
{
    if (!_seekIsPending) return;
    
    // Sanity check.  Playing shouldnt be if _seekIsPending is true
    if (_audioSource->state() == AUMRendererAudioSource::Playing) {
        [NSException raise:NSInternalInconsistencyException format:@"Shouldn't be!"];
    }
    
    // If we're not yet paused then do nothing
    if (_audioSource->state() == AUMRendererAudioSource::QueuedToPause) return;
    
    // Otherwise (Paused or Finished) do the deed.  Update the frame positions and re-queue the buffer from disk

    // Rebuffer from the seek frame and play if required
    [self _rebufferAudioFileFromFrame:_seekToFrame];
    if (_sourceStateToResumeAfterSeek == AUMRendererAudioSource::Playing)
        _audioSource->play();
    _seekIsPending = NO;
}

/////////////////////////////////////////////////////////////////////////

- (void)_replenishSourceBuffer
{
    /////////////////////////////////////////
    // CHECK NO OP CASES
    /////////////////////////////////////////

    if (!_audioSource)  return;

    // Check that we're not finished
    if (_audioSource->state() == AUMRendererAudioSource::Finished) return;
    
    // File EOF AND buffer empty?  Set finished and return
    if (_audioFile.eof && _audioSource->framesRemainingInBuffer() == 0) {
        MMLogRealTime("Source %p: Finished playback.%@", _audioSource, _autoRewindOnFinished?@" Rewinding.":@" Not rewinding.");
        
        if (_autoRewindOnFinished) {
            [self rewind];
        } else {
            _audioSource->setFinished();
        }
        
        // Call the callback block
        if (_cbPlaybackFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cbPlaybackFinished(self);
            });
        }
        return;
    }
    
    // Exit if EOF and not looping
    if (_audioFile.eof && !_loop) {
        return;
    }
    
    /////////////////////////////////////////
    // CHECK FOR DEPLETED
    /////////////////////////////////////////
    
    // See if we have enough frames in the ring buffer already...
    NSUInteger framesRemainingInBuffer = _audioSource->framesRemainingInBuffer();
    // 1/2 for now...
    if (framesRemainingInBuffer > _audioSource->bufferSizeInFrames() / 2) { return; }
    
    
    /////////////////////////////////////////
    // READ FROM FILE
    /////////////////////////////////////////
    
    // Otherwise fill 'er up
    int32_t framesToLoad = _audioSource->bufferSizeInFrames() - framesRemainingInBuffer;
    
    // Get the buffer head and number of available bytes
    void *bufferHeadL;
    void *bufferHeadR;
    _audioSource->pointersToBufferHeads(&bufferHeadL, &bufferHeadR);
    
    NSUInteger framesLoaded = [_audioFile readFrames:framesToLoad
                                         intoBufferL:bufferHeadL
                                             bufferR:bufferHeadR];

    // Update streamFile read position and consume the bytes
    _audioSource->indicateFramesWrittenToBuffer(framesLoaded);
    
    // If less than requested and looping, the rewind and read some more
    if (_loop) {
        
        // Do this in a loop in case the sample is very small
        while (framesLoaded < framesToLoad) {
        
            NSUInteger addtFramesToLoad = framesToLoad - framesLoaded;
            [_audioFile seekToFrame:0];
            
            _audioSource->pointersToBufferHeads(&bufferHeadL, &bufferHeadR);
            
            NSUInteger addtFramesLoaded = [_audioFile readFrames:addtFramesToLoad
                                                     intoBufferL:bufferHeadL
                                                         bufferR:bufferHeadR];
            
            // Update streamFile read position and consume the bytes
            _audioSource->indicateFramesWrittenToBuffer(addtFramesLoaded);
            framesLoaded += addtFramesLoaded;
        }
    }
    
    // Are we at EOF?
    if (_audioFile.eof) {
        MMLogDetail("EOF reached in file %@ via source %p", _audioFile.fileURL.lastPathComponent, _audioSource);
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)_rebufferAudioFileFromFrame:(NSUInteger)theFrame
{
    _audioSource->clearBuffer();
    _sourcePosOffsetInFrames = theFrame;
    [_audioFile seekToFrame:theFrame];
    [self _replenishSourceBuffer];
}

/////////////////////////////////////////////////////////////////////////

- (void)_callPlaybackDidOccurCallback
{
    if ([self isPlaying]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cbPlaybackDidOccur(self, self.playheadPosFrames, self.playheadPosTime);
        });
    }
}

@end

/// @}