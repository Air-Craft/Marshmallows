/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AumTypes.h
 
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/** 
 Audio control parameters like volume, etc.  Not wave data
 
 Create our own for clarity
 */
typedef AudioUnitParameterValue AUMAudioControlParameter;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Audio File Format Types & Constants
/////////////////////////////////////////////////////////////////////////

/**
 A way of encapsulating the various enums required to define an output file format.
 */
typedef struct {
    AudioFileTypeID fileTypeId;
    AudioStreamBasicDescription streamFormat;
    UInt32 codecManufacturer;  
} AUMAudioFileFormatDescription;


FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_AIFF_IM4_Stereo_SoftwareCodec;



/////////////////////////////////////////////////////////////////////////
#pragma mark - Audio Stream Formats
/////////////////////////////////////////////////////////////////////////

/**
 Useful default for the cleanest Render callback code.  non-interleaved, stereo, Float32. Need to explicitly set the mSampleRate as it defaults to kAudioStreamAnyRate (0)
 */
FOUNDATION_EXTERN const AudioStreamBasicDescription kAUMStreamFormatAUMUnitCanonical;

/////////////////////////////////////////////////////////////////////////

/** Use to specify no explicit stream format in the AUMUnitProtocol implementations */
FOUNDATION_EXTERN const AudioStreamBasicDescription kAUMNoStreamFormat;

/** Used to test a stream format for being equal to kAUMNoStreamFormat; */
static inline const BOOL AUM_isNoStreamFormat(AudioStreamBasicDescription *testASBD)
{
    AudioStreamBasicDescription emptyASBD = {0};
    
    if (memcmp(testASBD, &emptyASBD, sizeof(AudioStreamBasicDescription)) == 0) return YES;
    
    return NO;
}

/////////////////////////////////////////////////////////////////////////


/// @}