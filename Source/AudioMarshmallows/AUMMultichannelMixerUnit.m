/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import "AUMMultichannelMixerUnit.h"

#import <AudioUnit/AudioUnit.h>
#import "Private/AUMErrorChecking.h"
#import "AUMException.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMMultichannelMixerUnit
/////////////////////////////////////////////////////////////////////////

@implementation AUMMultichannelMixerUnit
{
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

- (id)initWithSampleRate:(NSTimeInterval)aSampleRate
{
    if (self = [super init]) {
        _inputBusCount = 0;    // Set to 0 to enforce setting after instantiation
        _outputBusCount = 1;   // Fixed. One output bus only
        _volume = 1.0;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////

- (id)init
{
    [NSException raise:NSInternalInconsistencyException format:@"Use designated initWithSampleRate: instead"];
    return nil;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

- (void)setInputBusCount:(NSInteger)newBusCount
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to setting this property"];
    }
    
    _inputBusCount = newBusCount;
    
    // Set property if ready...
    if (_audioUnitRef) {
        UInt32 busCnt = newBusCount;
        _(AudioUnitSetProperty(_audioUnitRef,
                               kAudioUnitProperty_ElementCount,
                               kAudioUnitScope_Input,
                               0,
                               &busCnt,
                               sizeof(busCnt)
                               ),
          kAUMAudioUnitException,
          @"Error setting input bus count to %u on AUMMultiChannelMixerUnit %@", busCnt, self);
    }
}

/////////////////////////////////////////////////////////////////////////

@synthesize volume=_volume;

- (void)setVolume:(AUMAudioControlParameter)newVolume
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    
    _volume = newVolume;
    
    // Set if added to graph
    _(AudioUnitSetParameter(_audioUnitRef,
                            kMultiChannelMixerParam_Volume,
                            kAudioUnitScope_Output,
                            0,  // output bus
                            _volume,
                            0),
      kAUMAudioUnitException,
      @"Error setting output volume to %f on AUMMultichannelMixerUnit %@", _volume, self);
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMUnitAbstract Fulfillment & Overrides
/** @name  AUMUnitAbstract Fulfillment & Overrides */
/////////////////////////////////////////////////////////////////////////


- (AudioComponentDescription)_audioComponentDescription
{
    AudioComponentDescription desc;
    desc.componentType          = kAudioUnitType_Mixer;
    desc.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    desc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    desc.componentFlags         = 0;
    desc.componentFlagsMask     = 0;
    
    return desc;
}

/// @}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)setEnabled:(BOOL)isEnabled onBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    
    AudioUnitParameterValue isEn = isEnabled ? 1.0 : 0.0;
    _(AudioUnitSetParameter(_audioUnitRef,
                            kMultiChannelMixerParam_Enable,
                            kAudioUnitScope_Input,
                            aBusNum,
                            isEn,
                            0),
      kAUMAudioUnitException,
      @"Error %@abling bus %u on unit %@", isEnabled?@"en":@"dis", aBusNum, self);
}

- (BOOL)isEnabledBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    
    AudioUnitParameterValue isEn;
    
    _(AudioUnitGetParameter(_audioUnitRef,
                            kMultiChannelMixerParam_Enable,
                            kAudioUnitScope_Input,
                            aBusNum,
                            &isEn),
      kAUMAudioUnitException,
      @"Error getting enabled state of bus %u on unit %@", aBusNum, self);
    
    return (BOOL)isEn;
}

/////////////////////////////////////////////////////////////////////////

- (void)setVolume:(AUMAudioControlParameter)newVolume onBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    
    _(AudioUnitSetParameter(_audioUnitRef,
                            kMultiChannelMixerParam_Volume,
                            kAudioUnitScope_Input,
                            aBusNum,
                            newVolume,
                            0),
      kAUMAudioUnitException,
      @"Error setting volume to %f on bus %u on unit %@", newVolume, aBusNum, self);
}

- (AUMAudioControlParameter)volumeOfBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    
    AudioUnitParameterValue vol;
    
    _(AudioUnitGetParameter(_audioUnitRef,
                            kMultiChannelMixerParam_Volume,
                            kAudioUnitScope_Input,
                            aBusNum,
                            &vol),
      kAUMAudioUnitException,
      @"Error getting volume on bus %u on unit %@", aBusNum, self);
    
    return vol;
}

/////////////////////////////////////////////////////////////////////////

- (void)setPan:(AUMAudioControlParameter)newPan onBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    
    _(AudioUnitSetParameter(_audioUnitRef,
                            kMultiChannelMixerParam_Pan,
                            kAudioUnitScope_Input,
                            aBusNum,
                            newPan,
                            0),
      kAUMAudioUnitException,
      @"Error setting pan to %f on bus %u on unit %@", newPan, aBusNum, self);
}

- (AUMAudioControlParameter)panOfBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    
    AudioUnitParameterValue pan;
    
    _(AudioUnitGetParameter(_audioUnitRef,
                            kMultiChannelMixerParam_Pan,
                            kAudioUnitScope_Input,
                            aBusNum,
                            &pan),
      kAUMAudioUnitException,
      @"Error getting volume on bus %u on unit %@", aBusNum, self);
    
    return pan;
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}