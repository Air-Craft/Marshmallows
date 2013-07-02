/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AumTypes.h
 
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


/////////////////////////////////////////////////////////////////////////
#pragma mark - Basic Types
/////////////////////////////////////////////////////////////////////////

/** 
 Audio control parameters like volume, etc.  Not wave data
 
 Create our own for clarity
 */
typedef AudioUnitParameterValue AUMAudioControlParameter;

/////////////////////////////////////////////////////////////////////////

/**
 A way of encapsulating the various enums required to define an output file format.
 */
typedef struct {
    AudioFileTypeID fileTypeId;
    AudioStreamBasicDescription streamFormat;
    UInt32 codecManufacturer;
    char extension[5];      // 4 digits plus \0 null
} AUMAudioFileFormatDescription;



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



/////////////////////////////////////////////////////////////////////////
#pragma mark - Audio File Formats
/////////////////////////////////////////////////////////////////////////

/** @name File Formats
    \b Don't forget LPCM ones need a sample rate set
 */
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_16bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_24bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_16bit_Packed_SignedInt;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_24bit_Packed_SignedInt;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_SignedInt;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_Float;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_64bit_Packed_Float;


FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_MPEG4AAC_Stereo_HardwareCodec;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_MPEG4AAC_Stereo_SoftwareCodec;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_IMA4_Stereo_SoftwareCodec;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_CAF_ALAC_Stereo_SoftwareCodec;

FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_AAC_MPEG4AAC_Stereo_HardwareCodec;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_AAC_MPEG4AAC_Stereo_SoftwareCodec;

FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_M4A_MPEG4AAC_Stereo_HardwareCodec;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_M4A_MPEG4AAC_Stereo_SoftwareCodec;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_M4A_ALAC_Stereo_SoftwareCodec;

FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_AIFF_LPCM_Stereo_44_1_16bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_AIFF_LPCM_Stereo_44_1_24bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_AIFF_LPCM_Stereo_44_1_32bit_Packed_SignedInt_BigEndian;

/** AIFF plus compression.  You can still used the .aiff extension */
FOUNDATION_EXTERN const AUMAudioFileFormatDescription kAUMFileFormat_AIFC_IM4_Stereo_SoftwareCodec;

/// @}
/////////////////////////////////////////////////////////////////////////


/// @}