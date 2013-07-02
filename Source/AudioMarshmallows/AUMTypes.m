/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMTypes.h"
#import <CoreAudio/CoreAudioTypes.h>

/////////////////////////////////////////////////////////////////////////
#pragma mark - Stream Formats (ASBDs)
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


/////////////////////////////////////////////////////////////////////////
#pragma mark - File Formats - CAF
/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_16bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 16,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 16/8 * 2,
        .mBytesPerPacket = 16/8 * 2 * 1
        
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_24bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 24,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 24/8 * 2,
        .mBytesPerPacket = 24/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 32,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 32/8 * 2,
        .mBytesPerPacket = 32/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_16bit_Packed_SignedInt = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger,
        .mBitsPerChannel = 16,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 16/8 * 2,
        .mBytesPerPacket = 16/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_24bit_Packed_SignedInt = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger,
        .mBitsPerChannel = 24,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 24/8 * 2,
        .mBytesPerPacket = 24/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_SignedInt = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger,
        .mBitsPerChannel = 32,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 32/8 * 2,
        .mBytesPerPacket = 32/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_Float = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat,
        .mBitsPerChannel = 32,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 32/8 * 2,
        .mBytesPerPacket = 32/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_LPCM_Stereo_44_1_64bit_Packed_Float = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat,
        .mBitsPerChannel = 64,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 64/8 * 2,
        .mBytesPerPacket = 64/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};


/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_MPEG4AAC_Stereo_HardwareCodec = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleHardwareAudioCodecManufacturer,
    .extension = "caf\0"
};

/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_MPEG4AAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_IMA4_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatAppleIMA4,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_CAF_ALAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatAppleLossless,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};



/////////////////////////////////////////////////////////////////////////
#pragma mark - File Formats - AAC
/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_AAC_MPEG4AAC_Stereo_HardwareCodec = {
    .fileTypeId = kAudioFileAAC_ADTSType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleHardwareAudioCodecManufacturer,
    .extension = "aac\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_AAC_MPEG4AAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileAAC_ADTSType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aac\0"
};



/////////////////////////////////////////////////////////////////////////
#pragma mark - File Formats - M4A
/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_M4A_MPEG4AAC_Stereo_HardwareCodec = {
    .fileTypeId = kAudioFileM4AType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleHardwareAudioCodecManufacturer,
    .extension = "m4a\0"
};

/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_M4A_MPEG4AAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileM4AType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "m4a\0"
};

/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_M4A_ALAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileM4AType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatAppleLossless,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "m4a\0"
};


/////////////////////////////////////////////////////////////////////////
#pragma mark - AIFF
/////////////////////////////////////////////////////////////////////////

const AUMAudioFileFormatDescription kAUMFileFormat_AIFF_LPCM_Stereo_44_1_16bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileAIFFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 16,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 16/8 * 2,
        .mBytesPerPacket = 16/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aif\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_AIFF_LPCM_Stereo_44_1_24bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileAIFFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 24,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 24/8 * 2,
        .mBytesPerPacket = 24/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aif\0"
};

const AUMAudioFileFormatDescription kAUMFileFormat_AIFF_LPCM_Stereo_44_1_32bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileAIFFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 32,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 32/8 * 2,
        .mBytesPerPacket = 32/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aif\0"
};


/////////////////////////////////////////////////////////////////////////
#pragma mark - File Formats - AIFC (AIFF compressed)
/////////////////////////////////////////////////////////////////////////

/** AIFF plus compression.  You can still used the .aiff extension */
const AUMAudioFileFormatDescription kAUMFileFormat_AIFC_IM4_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileAIFCType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatAppleIMA4,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aif\0"
};


/////////////////////////////////////////////////////////////////////////



/// @}