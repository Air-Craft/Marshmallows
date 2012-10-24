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
#import "AUMRendererAudioSource.h"


/** \brief Container for sources and rendering buffers for the RCB (also contained as a static)
 
 \section Usage & Threading Notes
 audioSource may only be set if the source is not playing (=Playing, QueuedToPause). It's not entirely thread safe to set this attribute on a different thread that controls it's play/pause/etc methods.
 */
class AUMFilePlaybackGeneratorRCB
{

public:
    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Static
/////////////////////////////////////////////////////////////////////////
    
    /** The RCB for the FilePlayerUnit . Friend of AUMRendererAudioSource 
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
    AUMFilePlaybackGeneratorRCB(NSUInteger callbackOutputSizeInFrames, NSTimeInterval theSampleRate) :
        _sampleRate(theSampleRate)
    {
        _volumeRampBuffer = std::vector<float>(callbackOutputSizeInFrames, 0);
        
        // Create the single audio source.
        // Nevermind.  It's on the stack
//        _audioSource = new AUMRendererAudioSource();
    }
    
    /////////////////////////////////////////////////////////////////////////

    ~AUMFilePlaybackGeneratorRCB() {}
    
    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////
    
    /** R/O Input/output format used by the RCB (their the same here) */
    const AudioStreamBasicDescription requiredAudioFormat();
    
    /** R/O.  Created at init.  Its buffer must be initialised by the client */
    AUMRendererAudioSource* audioSource() { return &_audioSource; };
    
    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////
    
private:
    static const NSUInteger _FADE_FRAMES_ON_PAUSE = 220;       // ~4ms at 44.1
    
    NSTimeInterval _sampleRate;
    
    AUMRendererAudioSource _audioSource;
    
    /** Used to hold values which are multiplied against samples set to stop to do a smooth fade out */
    std::vector<float> _volumeRampBuffer;

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