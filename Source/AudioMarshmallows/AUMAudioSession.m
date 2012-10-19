/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 18/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMAudioSession.h"
#import "AUMException.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMAudioSession
/////////////////////////////////////////////////////////////////////////

@implementation AUMAudioSession

+ (void)setCategory:(NSString *)category
{
    NSError *err;
    [[AVAudioSession sharedInstance] setCategory:category error:&err];
    [self _checkError:err];
}

/////////////////////////////////////////////////////////////////////////

+ (void)setPreferredHardwareSampleRate:(NSTimeInterval)aSampleRate
{
    NSError *err;
    [[AVAudioSession sharedInstance] setPreferredHardwareSampleRate:aSampleRate error:&err];
    [self _checkError:err];
}

/////////////////////////////////////////////////////////////////////////

+ (void)setPreferredIOBufferDuration:(NSTimeInterval)aBufferDuration
{
    NSError *err;
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:aBufferDuration error:&err];
    [self _checkError:err];

}

/////////////////////////////////////////////////////////////////////////

+ (void)setMixWithOthers:(BOOL)allowMix
{
    UInt32 allowMixUInt = allowMix;
    OSStatus osErr = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixUInt), &allowMixUInt);

    if (osErr != noErr) {
        [AUMException raise:kAUMAudioSessionException OSStatus:osErr format: @"Error setting MixWithOthers Override Category"];
    }
}

/////////////////////////////////////////////////////////////////////////

+ (void)setActive:(BOOL)beActive
{
    NSError *err;
    [[AVAudioSession sharedInstance] setActive:beActive error:&err];
    [self _checkError:err];
}

/////////////////////////////////////////////////////////////////////////

+ (NSTimeInterval)currentHardwareSampleRate
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    return session.currentHardwareSampleRate;
}

/////////////////////////////////////////////////////////////////////////

+ (NSTimeInterval)IOBufferDuration
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // New in iOS6
    if ([session respondsToSelector:@selector(IOBufferDuration)])
        return session.IOBufferDuration;
    else {
        Float32 d;
        UInt32 s = sizeof(d);
        AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &s, &d);
        return d;
    }
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////


/** Private method to throw exception if the NSError object is set 
    \throws AUMExeption::kAUMAudioSessionException */
+ (void)_checkError:(NSError *)anError
{
    if (anError) {
        [AUMException raise:kAUMAudioSessionException format:@"%@ (%i)", anError.localizedDescription, anError.code];
    }
}

/////////////////////////////////////////////////////////////////////////


@end

/// @}