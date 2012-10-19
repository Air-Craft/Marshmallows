/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMFilePlayerUnitRenderer.h"
#import <Accelerate/Accelerate.h>

OSStatus AUMFilePlayerUnitRenderer::renderCallback(void                        *inRefCon,
                                                   AudioUnitRenderActionFlags  *ioActionFlags,
                                                   const AudioTimeStamp        *inTimeStamp,
                                                   UInt32                      inBusNumber,
                                                   UInt32                      inNumberFrames,
                                                   AudioBufferList             *ioData
                                                   )
{
    AUMFilePlayerUnitRenderer *renderer = (AUMFilePlayerUnitRenderer *)inRefCon;
    
    // Failsafe to prevent glitches when latency (and correlated output buffer chunk) is higher than anticipated when renderer was init'ed
    renderer->_ensureMinimumBufferSize(inNumberFrames);
    
    // If no source then return silence
    if (!renderer->_sourceIsSet) {
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        return noErr;
    }
    
    
    /////////////////////////////////////////
    // GRAB SOURCE PARAMETERS
    /////////////////////////////////////////
    
    AUMRendererAudioFileSource *source = renderer->_playbackSource;
    
    //  Init previous volume if required
    if (source->_previousVolume == -1) {
        source->_previousVolume = source->_volume;
    }
    AUMRendererAudioFileSource::State sourceState = source->state();
    AUMAudioControlParameter volume = source->_volume;
    AUMAudioControlParameter prevVolume = source->_previousVolume;
    
    
    // Additional bailout conditions: Not playing or volume 0
    if ( (sourceState != AUMRendererAudioFileSource::Playing and
          sourceState != AUMRendererAudioFileSource::QueuedToPause) or
         (volume == 0 && prevVolume == 0) ) {
        
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
    // Also don't do the fade if we're ended in a few frames anyway (rare)
    if ((sourceState == AUMRendererAudioFileSource::QueuedToPause &&
            sourceFramesRead >= AUMFilePlayerUnitRenderer::_FADE_FRAMES_ON_PAUSE) ||
        volume != prevVolume) {
        
        // Fade out if finished and set flag to clear
        if (sourceState == AUMRendererAudioFileSource::QueuedToPause) {

            // Make the fade out ramp
            float vInit = prevVolume;   // current volume if different doesnt matter as we're stopping
            float zero = 0;
            ::vDSP_vclr(volumeRampBuffer, 1, renderer->_volumeRampBuffer.size());
            
            ::vDSP_vgen(&vInit,
                        &zero,
                        volumeRampBuffer,
                        1,
                        AUMFilePlayerUnitRenderer::_FADE_FRAMES_ON_PAUSE);
            
            source->state(AUMRendererAudioFileSource::Finished);
            
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
    
    
    /////////////////////////////////////////
    // EOF CHECK
    /////////////////////////////////////////
    
    if (sourceFramesRead != outputFrames && source->_isEOF) {
        source->state(AUMRendererAudioFileSource::Finished);
    }
    
    return noErr;
 
}
    
/////////////////////////////////////////////////////////////////////////

const AudioStreamBasicDescription AUMFilePlayerUnitRenderer::requiredAudioFormat()
{
    return kAUMUnitCanonicalStreamFormat;
}

/////////////////////////////////////////////////////////////////////////

void AUMFilePlayerUnitRenderer::playbackSource(AUMRendererAudioFileSource *source)
{
    // Only allow is source is not set, or if it is, only if its not playing
    if (_sourceIsSet and
        (_playbackSource->state() == AUMRendererAudioFileSource::Playing or
        _playbackSource->state() == AUMRendererAudioFileSource::QueuedToPause)) {
        
        [NSException raise:NSInternalInconsistencyException format:@"Current source must be stopped before changing."];
    }
    
    _sourceIsSet = false;   // a simple atomic latch to prevent dirty states
    _playbackSource = source;
    
    // If non-NULL re-enable latch
    if (source) {
        _sourceIsSet = true;
    }
}

/////////////////////////////////////////////////////////////////////////

AUMRendererAudioFileSource* AUMFilePlayerUnitRenderer::playbackSource()
{
    return _playbackSource;
}



/// @}