/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 25/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AUMUtilityFunctions.h
 
 
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#ifdef __cplusplus
extern "C" {
#endif
    
/** Used to test a stream format for being equal to kAUMNoStreamFormat; */
const BOOL AUM_isNoStreamFormat(AudioStreamBasicDescription testASBD);

/** NSLog a list of supported mFormatFlahs and other info for the given container and audio data format 
 
 Special thx to Learning Core Audio: http://www.amazon.co.uk/Learning-Core-Audio-Hands-Programming/dp/0321636848
 */
void AUM_printAvailableStreamFormatsForId(AudioFileTypeID fileTypeID, UInt32 mFormatID);


#ifdef __cplusplus
}
#endif
    
/// @}