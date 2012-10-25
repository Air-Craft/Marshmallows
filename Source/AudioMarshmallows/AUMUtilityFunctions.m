/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 25/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMUtilityFunctions.h"


const BOOL AUM_isNoStreamFormat(AudioStreamBasicDescription testASBD)
{
    AudioStreamBasicDescription emptyASBD = {0};
    
    if (memcmp(&testASBD, &emptyASBD, sizeof(AudioStreamBasicDescription)) == 0) return YES;
    
    return NO;
}

/////////////////////////////////////////////////////////////////////////

void AUM_printAvailableStreamFormatsForId(AudioFileTypeID fileTypeID, UInt32 mFormatID)
{
    AudioFileTypeAndFormatID fileTypeAndFormat;
    fileTypeAndFormat.mFileType = fileTypeID;
    fileTypeAndFormat.mFormatID = mFormatID;
    UInt32 fileTypeIDChar = CFSwapInt32HostToBig(fileTypeID);
    UInt32 mFormatChar = CFSwapInt32HostToBig(mFormatID);
    
    OSStatus audioErr = noErr;
    UInt32 infoSize = 0;
    audioErr = AudioFileGetGlobalInfoSize(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
                                          sizeof (fileTypeAndFormat),
                                          &fileTypeAndFormat,
                                          &infoSize);
    if (audioErr != noErr) {
        UInt32 format4cc = CFSwapInt32HostToBig(audioErr);
        NSLog(@"-: fileTypeID: %4.4s, mFormatId: %4.4s, not supported (%4.4s)",
              //i,
              (char*)&fileTypeIDChar,
              (char*)&mFormatChar,
              (char*)&format4cc
              );
        
        return;
    }
    
    AudioStreamBasicDescription *asbds = malloc (infoSize);
    audioErr = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
                                      sizeof (fileTypeAndFormat),
                                      &fileTypeAndFormat,
                              	        &infoSize,
                                      asbds);
    if (audioErr != noErr) {
        UInt32 format4cc = CFSwapInt32HostToBig(audioErr);
        NSLog(@"-: fileTypeID: %4.4s, mFormatId: %4.4s, not supported (%4.4s)",
              //i,
              (char*)&fileTypeIDChar,
              (char*)&mFormatChar,
              (char*)&format4cc
              );

        return;
    }


    int asbdCount = infoSize / sizeof (AudioStreamBasicDescription);
    for (int i=0; i<asbdCount; i++) {
        UInt32 format4cc = CFSwapInt32HostToBig(asbds[i].mFormatID);

        NSLog(@"%d: fileTypeID: %4.4s, mFormatId: %4.4s, mFormatFlags: %ld, mBitsPerChannel: %ld",
              i,
              (char*)&fileTypeIDChar,
              (char*)&format4cc,
              asbds[i].mFormatFlags,
              asbds[i].mBitsPerChannel);
    }
    
    free (asbds);
}

/// @}