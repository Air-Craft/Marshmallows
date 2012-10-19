/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import "AUMFilePlayerUnit.h"

#import "MarshmallowCocoa.h"
#import "AUMAudioFile.h"
#import "AUMAudioSession.h"
#import "Private/AUMFilePlayerUnitRenderer.h"
#import "Private/AUMRendererAudioFileSource.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMFilePlayerUnit
/////////////////////////////////////////////////////////////////////////

@implementation AUMFilePlayerUnit
{
    AUMRemoteIOUnit *_remoteIOUnit;     ///< Typed reference to _proxiedUnit for autocomplete convenience
    id <MCThreadProxyProtocol> _updateThread;
    
    AUMFilePlayerUnitRenderer *_renderer;
    AUMRendererAudioFileSource *_audioSource;
    
    NSUInteger _diskBufferSizeInFrames;
}

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
    _volume = 1.0;
    _loop = NO;
    _playheadTime = 0.0;
    _remoteIOUnit = _proxiedUnit = [[AUMRemoteIOUnit alloc] init]; // strong type for 
 
    AURenderCallbackStruct rcb;
    NSUInteger ioBufferInFrames = ceil(theSampleRate * theIOBufferDuration);
    _renderer = new AUMFilePlayerUnitRenderer(theSampleRate, ioBufferInFrames);
    rcb.inputProc = &AUMFilePlayerUnitRenderer::renderCallback;
    rcb.inputProcRefCon = (void *)_renderer;
    [_remoteIOUnit setRenderCallback:rcb forInputBus:0];
    
    
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
    if (_renderer)
        delete _renderer;
    if (_audioSource)
        delete _audioSource;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Property Accessors
/////////////////////////////////////////////////////////////////////////

@synthesize loop=_loop;

- (void)setLoop:(BOOL)aBool
{
    if (_audioSource) {
        _audioSource->loop(aBool);
    }
    _loop = aBool;  // Keep track of the ivar too in case loop is set before the source is created (see loadAudioFileFromURL:
}

/////////////////////////////////////////////////////////////////////////

@synthesize volume=_volume;

- (void)setVolume:(AUMAudioControlParameter)volume
{
    if (_audioSource) {
        _audioSource->volume(volume);
    }
    _volume = volume;  // Keep track of the ivar too in case loop is set before the source is created (see loadAudioFileFromURL:
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)play
{
    @synchronized(self) {
        if (_audioSource) {
            _audioSource->play();
        }
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)loadAudioFileFromURL:(NSURL *)fileURL
{
    AUMAudioFile *audioFile = [AUMAudioFile audioFileForURL:fileURL];
    
    // Set the output format to the one used in the RCB
    audioFile.outFormat = _renderer->requiredAudioFormat();
    
    // Create the source
    _audioSource = new AUMRendererAudioFileSource(audioFile, _diskBufferSizeInFrames);
    
    _audioSource->loop(_loop);
    _audioSource->volume(_volume);
    
    _renderer->playbackSource(_audioSource);
    
    // Prevent threading collisions with _updateSource
    @synchronized(self) {

    }
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////

- (void)_updateSource
{
    @synchronized(self) {
        if (_audioSource)
            _audioSource->updateSource();
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMUnitProtocol Overrides
/////////////////////////////////////////////////////////////////////////

/** Disable input bus as this is output only */
- (const NSInteger)maxInputBusNum { return -1; }

/** Only one output at this time too */
- (const NSInteger)maxOutputBusNum { return 0; }

/** There are no inputs */
- (const AudioStreamBasicDescription)inputStreamFormat
{
    return kAUMUnitCanonicalStreamFormat;
}

/** Defined by the RCB in AUMFilePlayerUnitRenderer */
- (const AudioStreamBasicDescription)outputStreamFormat { return _renderer->requiredAudioFormat(); }


@end

/// @}