/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMFilePlaybackGeneratorRCB.h"
#import <Accelerate/Accelerate.h>

OSStatus AUMFilePlaybackGeneratorRCB::renderCallback(void                        *inRefCon,
                                                   AudioUnitRenderActionFlags  *ioActionFlags,
                                                   const AudioTimeStamp        *inTimeStamp,
                                                   UInt32                      inBusNumber,
                                                   UInt32                      inNumberFrames,
                                                   AudioBufferList             *ioData
                                                   )
{
    AUMFilePlaybackGeneratorRCB *renderer = (AUMFilePlaybackGeneratorRCB *)inRefCon;
    
    // Failsafe to prevent glitches when latency (and correlated output buffer chunk) is higher than anticipated when renderer was init'ed
    renderer->_ensureMinimumBufferSize(inNumberFrames);
    
    /////////////////////////////////////////
    // GRAB SOURCE PARAMETERS
    /////////////////////////////////////////
    
    AUMRendererAudioSource *source = &renderer->_audioSource;
    
    //  Init previous volume if required
    if (source->_previousVolume == -1) {
        source->_previousVolume = source->_volume;
    }
    AUMRendererAudioSource::State sourceState = source->state();
    AUMAudioControlParameter volume = source->_volume;
    AUMAudioControlParameter prevVolume = source->_previousVolume;
    
    
    /////////////////////////////////////////
    // BAILOUT CONDITIONS
    /////////////////////////////////////////
    
    // Not playing or volume 0
    if ( sourceState == AUMRendererAudioSource::Paused or
         sourceState == AUMRendererAudioSource::Finished or
         (volume == 0 and prevVolume == 0) ) {
        
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        return noErr;
    }
    
    
    /////////////////////////////////////////
    // SETUP BUFFERS
    /////////////////////////////////////////
    
    // Output vars
    Float32 *outputBufferL = (Float32 *)ioData->mBuffers[0].mData;
    Float32 *outputBufferR = (Float32 *)ioData->mBuffers[1].mData;
    UInt32 outputBytes = ioData->mBuffers[0].mDataByteSize;
    UInt32 outputFrames = inNumberFrames; // For clarity.  Note "1 frame" === "1 interleaved L/R sample"
    
    Float32 *volumeRampBuffer = renderer->_volumeRampBuffer.data();
    
    // Zero out the output buffer in case we dont have enough source audio to fill it
    ::vDSP_vclr(outputBufferL, 1, outputBytes);
    ::vDSP_vclr(outputBufferR, 1, outputBytes);
    

    /////////////////////////////////////////
    // READ SOURCE
    /////////////////////////////////////////
    
    Float32 sourceFramesRead = source->_readFramesFromBuffer((void *)outputBufferL, (void *)outputBufferR, outputFrames);
    
    // Nothing read? Buffer underrun. Return silence
    if (not sourceFramesRead) {
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        return noErr;
    }
    
    /////////////////////////////////////////
    // VOLUME RAMP
    // - for volume param updates and stopped samples
    /////////////////////////////////////////
    
    // if stopping, generate buffer from prev vol to 0
    // if vol is diff generate ramp from prev to vol
    // if either, vector mult
    // else scalar mult

    
    // If vol has changed or we're stopping then generate a volume ramp and vector multiply
    // Otherwise do a scalar multiply for the current (& prev) volume
    // Also don't do the fade if we're ending in a few frames anyway (rare)
    if ((sourceState == AUMRendererAudioSource::QueuedToPause and
            sourceFramesRead >= AUMFilePlaybackGeneratorRCB::_FADE_FRAMES_ON_PAUSE) ||
        volume != prevVolume) {
        
        // Fade out if finished and set flag to clear
        if (sourceState == AUMRendererAudioSource::QueuedToPause) {

            // Make the fade out ramp
            float vInit = prevVolume;   // current volume if different doesnt matter as we're stopping
            float zero = 0;
            ::vDSP_vclr(volumeRampBuffer, 1, renderer->_volumeRampBuffer.size());
            
            ::vDSP_vgen(&vInit,
                        &zero,
                        volumeRampBuffer,
                        1,
                        AUMFilePlaybackGeneratorRCB::_FADE_FRAMES_ON_PAUSE);
            
            source->_setPausedState();
            
        } else if (volume != prevVolume) {
            
            // Create a smooth ramp change between the 2 volumes
            // Do the whole length even if we're stopping short as to not create artificially strong volume gradients if playback is finishing
            ::vDSP_vgen(&prevVolume, &volume, volumeRampBuffer, 1, outputFrames);
            
            // Update the previous volume
            // No need for atomics as this func is the only getter and setter of prevVol
            source->_previousVolume = volume;
        }
        
        // Vector Multiply over available output
        ::vDSP_vmul(volumeRampBuffer, 1, outputBufferL, 1, outputBufferL, 1, sourceFramesRead);
        ::vDSP_vmul(volumeRampBuffer, 1, outputBufferR, 1, outputBufferR, 1, sourceFramesRead);
        
    } else {    // Volume hasn't changed and not pausing
        
        // Scalar multiply
        ::vDSP_vsmul(outputBufferL, 1, &volume, outputBufferL, 1, sourceFramesRead);
        ::vDSP_vsmul(outputBufferR, 1, &volume, outputBufferR, 1, sourceFramesRead);
    }
    
    // All done!
    return noErr;
}
    
/////////////////////////////////////////////////////////////////////////

const AudioStreamBasicDescription AUMFilePlaybackGeneratorRCB::requiredAudioFormat()
{
    // Set the sample rate to the actual one
    AudioStreamBasicDescription asbd = kAUMStreamFormatAUMUnitCanonical;
    asbd.mSampleRate = _sampleRate;
    return asbd;
}




/// @}