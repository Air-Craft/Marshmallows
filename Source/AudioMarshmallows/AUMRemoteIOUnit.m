/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import "AUMRemoteIOUnit.h"
#import "AUMTypes.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMRemoteIOUnit
/////////////////////////////////////////////////////////////////////////

@implementation AUMRemoteIOUnit


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (id)init
{
    if (self = [super init]) {
        // Default our i/o formats to canonical for easy user setup
        _inputBusCount = 2;
        _outputBusCount = 2;
    }
    return self;
}

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