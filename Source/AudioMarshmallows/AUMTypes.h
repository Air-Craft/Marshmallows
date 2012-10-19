/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AumTypes.h
 
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/** Audio control parameters like volume, etc.  Not wave data */
typedef Float32 AUMAudioControlParameter;

/**
 Default ASBD's for AUMUnit I/O busses to use. Currently both are PCM/Non-Interleaved/Native/Packed/Float/stereo/16bit/44.1kHz
 */
FOUNDATION_EXTERN const AudioStreamBasicDescription kAUMUnitCanonicalStreamFormat;


/// @}