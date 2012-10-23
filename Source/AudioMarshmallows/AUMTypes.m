/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMTypes.h"
#import <CoreAudio/CoreAudioTypes.h>


const AUMAudioFileFormatDescription kAUMFileFormat_AIFF_IM4_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileAIFFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatAppleIMA4,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer
};

/////////////////////////////////////////////////////////////////////////


const AudioStreamBasicDescription kAUMStreamFormatAUMUnitCanonical = {
    .mFormatID = kAudioFormatLinearPCM,
    .mFormatFlags = kAudioFormatFlagsNativeFloatPacked |kAudioFormatFlagIsNonInterleaved,
    .mSampleRate = kAudioStreamAnyRate,
    .mChannelsPerFrame = 2,
    .mBitsPerChannel = 8 * sizeof(Float32),
    .mFramesPerPacket = 1,
    .mBytesPerFrame = sizeof(Float32) * 1,
    .mBytesPerPacket = sizeof(Float32) * 1
};


/////////////////////////////////////////////////////////////////////////

const AudioStreamBasicDescription kAUMNoStreamFormat = {0};

/// @}