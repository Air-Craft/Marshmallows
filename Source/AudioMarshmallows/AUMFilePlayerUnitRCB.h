/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AUMFilePlayerUnitRCB.h
 
 
#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

OSStatus AUMFilePlayerUnitRCB (void                        *inRefCon,
                               AudioUnitRenderActionFlags  *ioActionFlags,
                               const AudioTimeStamp        *inTimeStamp,
                               UInt32                      inBusNumber,
                               UInt32                      inNumberFrames,
                               AudioBufferList             *ioData
                               );

/// @}