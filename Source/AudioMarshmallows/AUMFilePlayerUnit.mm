/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import <tgmath.h>
#import "AUMFilePlayerUnit.h"

#import "MarshmallowCocoa.h"
#import "AUMAudioFileReader.h"
#import "AUMAudioSession.h"
#import "AUMAudioFileReader.h"
#import "Private/AUMFilePlayerUnitRenderer.h"
#import "Private/AUMRendererAudioSource.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMFilePlayerUnit
/////////////////////////////////////////////////////////////////////////

@implementation AUMFilePlayerUnit
{
    AUMRemoteIOUnit *_remoteIOUnit;     ///< Typed reference to _proxiedUnit for autocomplete convenience
    id <MCThreadProxyProtocol> _updateThread;
    
    AUMFilePlayerUnitRenderer *_renderer;
    AUMRendererAudioSource *_audioSource;
    AUMAudioFileReader *_audioFile;
    AudioStreamBasicDescription _internalStreamFormat;    ///< Interval ASBD for the RCB and audio source streams
    
    
    NSTimeInterval _sampleRate;
    NSUInteger _diskBufferSizeInFrames;
    
    /** The amount to add to the value reported by the source to determine the actual play position.  Set on seek when the source is reset to a non-zero starting point 
     
        A Float to correspond to RendererSource (as it can be a decimal with pitch scaled reads.)
     */
    Float32 _sourcePosOffsetInFrames;
    
    /** @name Seek state vars. Cache settings to process after source is paused */
    /// @{
    BOOL _seekIsPending;
    NSUInteger _seekToFrame;
    /// @}
    
    /** @name Seek state vars. Cache settings to process after source is paused */
    /// @{
    BOOL _audioFileChangeIsPending;
    AUMAudioFileReader *_audioFileToChangeTo;
    /// @}

}

@synthesize playheadPosTime=_playheadPosTime;
@synthesize playheadPosFrames=_playheadPosFrames;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

- (id)initWithDiskBufferSizeInFrame:(NSUInteger)aDiskBufferSizeInFrames
                       updateThread:(id<MCThreadProxyProtocol>)anUpdateThread updateInterval:(NSTimeInterval)anUpdateInterval
{
    // Get the params from AUMAudioSession
    NSTimeInterval sr = AUMAudioSession.currentHardwareSampleRate;
    NSTimeInterval ioBuff = AUMAudioSession.IOBufferDuration;
    
    // Does this indicate not currently set??
    if (sr == 0 || ioBuff == 0) {
        [NSException raise:NSInternalInconsistencyException format:@"Sample rate and IOBufferDuration must be set on Audio Session prior to using this initialiser"];
    }
    
    return [self initWithSampleRate:sr
              diskBufferSizeInFrame:aDiskBufferSizeInFrames
                   ioBufferDuration:ioBuff
                       updateThread:anUpdateThread
                     updateInterval:anUpdateInterval];
}

/////////////////////////////////////////////////////////////////////////

/** Create an underlying RemoteIO unit and set our callback to it */
- (id)initWithSampleRate:(Float64)theSampleRate
   diskBufferSizeInFrame:(NSUInteger)aDiskBufferSizeInFrames
        ioBufferDuration:(NSTimeInterval)theIOBufferDuration
            updateThread:(id<MCThreadProxyProtocol>)anUpdateThread
          updateInterval:(NSTimeInterval)anUpdateInterval
{
    /////////////////////////////////////////
    // SETUP REMOTEIO UNIT
    /////////////////////////////////////////
    _diskBufferSizeInFrames = aDiskBufferSizeInFrames;
    _audioSource = NULL;
    _loop = NO;
    _sourcePosOffsetInFrames = 0;
    _playheadPosTime = 0.0;
    _playheadPosFrames = 0.0;
    _seekIsPending = NO;
    _remoteIOUnit = _proxiedUnit = [[AUMRemoteIOUnit alloc] initWithSampleRate:theSampleRate]; // strong type for convenience
    _sampleRate = theSampleRate;
 
    AURenderCallbackStruct rcb;
    NSUInteger ioBufferInFrames = ceil(theSampleRate * theIOBufferDuration);
    _renderer = new AUMFilePlayerUnitRenderer(theSampleRate, ioBufferInFrames);
    rcb.inputProc = &AUMFilePlayerUnitRenderer::renderCallback;
    rcb.inputProcRefCon = (void *)_renderer;
    
    _internalStreamFormat = _renderer->requiredAudioFormat();
    
    // Set the remote IO's format to match ours and 
    _remoteIOUnit.defaultInputStreamFormat = _internalStreamFormat;
    [_remoteIOUnit setRenderCallback:rcb forInputBus:0];
    
    // Grab the audioSource from the renderer and initialise its buffer
    _audioSource = _renderer->audioSource();
    _audioSource->initializeBuffer(_diskBufferSizeInFrames, _internalStreamFormat.mBytesPerFrame);
    
    
    
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
#pragma mark - AUMUnitProtocol Overrides
/////////////////////////////////////////////////////////////////////////

/** Disable input bus as this is output only */
- (const NSInteger)maxInputBusNum { return -1; }

/** Only one output at this time too */
- (const NSInteger)maxOutputBusNum { return 1; }



/////////////////////////////////////////////////////////////////////////
#pragma mark - Property Accessors
/////////////////////////////////////////////////////////////////////////

- (void)setVolume:(AUMAudioControlParameter)volume
{
    _audioSource->volume(volume);
}

- (AUMAudioControlParameter)volume
{
    return _audioSource->volume();
}

/////////////////////////////////////////////////////////////////////////

- (NSUInteger)playheadPosFrames
{
    return round(_sourcePosOffsetInFrames + _audioSource->playheadPosInFrames());
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
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)loadAudioFileFromURL:(NSURL *)fileURL
{
    // Load the file
    AUMAudioFileReader *newFile = [AUMAudioFileReader audioFileForURL:fileURL];
    newFile.outFormat = _internalStreamFormat;

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
        _audioSource->pause();  // WARNING: Doesn't happen straight away! Hence all this...
        _audioFileToChangeTo = newFile;
        _audioFileChangeIsPending = YES;
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)play
{
    @synchronized(self) {
        if (!_audioFile) [NSException raise:NSInternalInconsistencyException format:@"File must be loaded first"];
        
        _audioSource->play();
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)pause
{
    @synchronized(self) {
        if (!_audioFile) [NSException raise:NSInternalInconsistencyException format:@"File must be loaded first"];
        
        _audioSource->pause();
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
        _audioSource->pause();  // WARNING: Doesn't happen straight away! Hence all this...
        _seekToFrame = toFrame;
        _seekIsPending = YES;
    }

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
    // Rebuffer and play (If we weren't playing before, we wouldn't be here)
    [self _rebufferAudioFileFromFrame:0];
    _audioSource->play();
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

    // Rebuffer from the seek frame and play
    [self _rebufferAudioFileFromFrame:_seekToFrame];
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
        _audioSource->setFinished();
        MMLogRealTime("Source %p: Finished playback.", _audioSource);
        return;
    }
    
    
    // See if we have enough frames in the ring buffer already...
    NSUInteger framesRemainingInBuffer = _audioSource->framesRemainingInBuffer();
    // 1/2 for now...
    if (framesRemainingInBuffer > _audioSource->bufferSizeInFrames() / 2) { return; }
    
    
    // Otherwise fill 'er up
    int32_t framesToLoad = _audioSource->bufferSizeInFrames() - framesRemainingInBuffer;
    
    // Get the buffer head and number of available bytes
    void *bufferHeadL;
    void *bufferHeadR;
    _audioSource->pointersToBufferHeads(&bufferHeadL, &bufferHeadR);
    
    NSUInteger framesLoaded = [_audioFile readFrames:framesToLoad intoBufferL:bufferHeadL bufferR:bufferHeadR];
    
    // Update streamFile read position and consume the bytes
    _audioSource->indicateFramesWrittenToBuffer(framesLoaded);
    
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


@end

/// @}