/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 18/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AUMAudioSession.h
 
 
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


/**
 \brief A wrapper for AVAudioSession which uses our AUMExceptions to handle errors, avoids the singleton instance method, and picks up some parameters still only available in the C function paradigm.
 
 \section Exceptions
 Unless otherwise specified, these throw a AUMException:kAUMAudioSessionException
 */
@interface AUMAudioSession : NSObject

+ (void)setCategory:(NSString *)category;
+ (void)setPreferredHardwareSampleRate:(NSTimeInterval)aSampleRate;
+ (void)setPreferredIOBufferDuration:(NSTimeInterval)aBufferDuration;
+ (void)setMixWithOthers:(BOOL)allowMix;
+ (void)setActive:(BOOL)beActive;

+ (NSTimeInterval)currentHardwareSampleRate;
+ (NSTimeInterval)IOBufferDuration;

@end

/// @}