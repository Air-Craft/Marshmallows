/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMTypes.h"
#import <CoreAudio/CoreAudioTypes.h>


const AudioStreamBasicDescription kAUMUnitCanonicalStreamFormat = {
    .mFormatID = kAudioFormatLinearPCM,
    .mFormatFlags = kAudioFormatFlagsNativeFloatPacked |kAudioFormatFlagIsNonInterleaved,
    .mSampleRate = 44100.0,
    .mChannelsPerFrame = 2,
    .mBitsPerChannel = 8 * sizeof(Float32),
    .mFramesPerPacket = 1,
    .mBytesPerFrame = sizeof(Float32) * 1,
    .mBytesPerPacket = sizeof(Float32) * 1
};


/// @}