/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AUMFilePlayerUnitRCB.h
 
#import <vector>
#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import "MarshmallowDebug.h"
#import "AUMAtomicType.h"
#import "AUMRendererAudioFileSource.h"


using namespace std;

/** \brief Container for sources and rendering buffers for the RCB (also contained as a static)
 
 \section Usage & Threading Notes
 playbackSource may only be set if the source is not playing (=Playing, QueuedToPause). It's not entirely thread safe to set this attribute on a different thread that controls it's play/pause/etc methods.
 */
class AUMFilePlayerUnitRenderer
{

public:
    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Static
/////////////////////////////////////////////////////////////////////////
    
    /** The RCB for the FilePlayerUnit . Friend of AUMRendererAudioFileSource 
     \param inRefCon    An instance of this class as set in the AUMFilePlayerUnit
     */
    static OSStatus renderCallback(void                        *inRefCon,
                                   AudioUnitRenderActionFlags  *ioActionFlags,
                                   const AudioTimeStamp        *inTimeStamp,
                                   UInt32                      inBusNumber,
                                   UInt32                      inNumberFrames,
                                   AudioBufferList             *ioData
                                   );

/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////

    /**
     \param callbackOutputSizeInFrames  Used to preinitialise the working buffers to the proper size.  The RCB checks and adjusts at the beginning just in case but this is bad form so ensure its big enough
     */
    AUMFilePlayerUnitRenderer(NSUInteger callbackOutputSizeInFrames, NSTimeInterval theSampleRate) :
        _sourceIsSet(false),
        _playbackSource(NULL),
        _sampleRate(theSampleRate)
    {
        _volumeRampBuffer = vector<float>(callbackOutputSizeInFrames, 0);
    }
    
    /////////////////////////////////////////////////////////////////////////

    ~AUMFilePlayerUnitRenderer() { _playbackSource = NULL; }
    
    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////
    
    /** R/O Input/output format used by the RCB (their the same here) */
    const AudioStreamBasicDescription requiredAudioFormat();
    
    void playbackSource(AUMRendererAudioFileSource *);
    AUMRendererAudioFileSource* playbackSource();
    
    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////
    
private:
    static const NSUInteger _FADE_FRAMES_ON_PAUSE = 220;       // ~4ms at 44.1
    
    NSTimeInterval _sampleRate;
    
    /** Flag to ensure no fuzzy states with setting/getting _playbackSounce */
    AUM::AtomicBool _sourceIsSet;
    AUMRendererAudioFileSource *_playbackSource;
    
    /** Used to hold values which are multiplied against samples set to stop to do a smooth fade out */
    vector<float> _volumeRampBuffer;

    /**
     Called via RCB in case the buffer size is larger than expected (ie the latency was increased by the hardware)
     */
    inline void _ensureMinimumBufferSize(NSUInteger sizeInFrames)
    {
        // Resize if needed
        if (sizeInFrames > _volumeRampBuffer.size()) {
            
            MMLogWarn("WARNING: Buffers to small!  Resizing %lu => %u frames", _volumeRampBuffer.size(), sizeInFrames);
            
            _volumeRampBuffer.resize(sizeInFrames, 0);
        }

    }
    
};
/// @}