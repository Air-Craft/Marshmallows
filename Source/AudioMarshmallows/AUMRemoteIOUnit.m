/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import "AUMRemoteIOUnit.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMRemoteIOUnit
/////////////////////////////////////////////////////////////////////////

@implementation AUMRemoteIOUnit


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

/** Convenience method for setting input bus 0 as it's the only one to that can be assigned 
    \throws kAUMException
 
-(void)setInputRenderCallback:(AURenderCallbackStruct)aRenderCallback withStreamFormat:(AudioStreamBasicDescription)aStreamFormat
{
    [self setRenderCallback:aRenderCallback forInputBus:0];
    [self setStreamFormat:aStreamFormat forInputBus:0];
}
 */


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMUnitAbstract Fulfillment
/////////////////////////////////////////////////////////////////////////
/** @name  AUMUnitAbstract Fulfillment */

- (AudioComponentDescription)_audioComponentDescription
{
    AudioComponentDescription desc;
    desc.componentType          = kAudioUnitType_Output;
    desc.componentSubType       = kAudioUnitSubType_RemoteIO;
    desc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    desc.componentFlags         = 0;
    desc.componentFlagsMask     = 0;
    
    return desc;
}


/// @}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}