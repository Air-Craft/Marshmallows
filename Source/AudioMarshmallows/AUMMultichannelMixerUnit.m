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
    /** Used for late binding of AU parameters */
    NSMutableDictionary *_inputBussesEnableStateDict;
    NSMutableDictionary *_inputBussesVolumeDict;
    NSMutableDictionary *_inputBussesPanDict;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

- (id)initWithSampleRate:(NSTimeInterval)aSampleRate
{
    if (self = [super initWithSampleRate:aSampleRate]) {
        _maxInputBusNum = 1;    // Default to 2 input busses.
        _maxOutputBusNum = 1;   // One output bus only
        _volume = 1.0;
        
        _inputBussesEnableStateDict = [NSMutableDictionary new];
        _inputBussesVolumeDict = [NSMutableDictionary new];
        _inputBussesPanDict = [NSMutableDictionary new];
    }
    return self;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

- (NSUInteger)busCount { return _maxInputBusNum + 1; }

- (void)setBusCount:(NSUInteger)newBusCount
{
    _maxInputBusNum = newBusCount - 1;
    
    // Set property if ready...
    if (_hasBeenAddedToGraph) {
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
    _volume = newVolume;
    
    // Set if added to graph
    if (_hasBeenAddedToGraph) {
        _(AudioUnitSetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Volume,
                                kAudioUnitScope_Output,
                                0,  // output bus
                                _volume,
                                0),
          kAUMAudioUnitException,
          @"Error setting output volume to %f on AUMMultichannelMixerUnit %@", _volume, self);
    }
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

/////////////////////////////////////////////////////////////////////////

- (void)_nodeWasAddedToGraph
{
    /////////////////////////////////////////
    // LATE BIND PROPERTIES & PARAMETERS
    /////////////////////////////////////////

    // BUS COUNT
    UInt32 busCnt = self.busCount;
    _(AudioUnitSetProperty(_audioUnitRef,
                           kAudioUnitProperty_ElementCount,
                           kAudioUnitScope_Input,
                           0,
                           &busCnt,
                           sizeof(busCnt)
                           ),
      kAUMAudioUnitException,
      @"Error setting input bus count to %u on AUMMultiChannelMixerUnit %@", busCnt, self);
    
    // OUTPUT VOLUME
    _(AudioUnitSetParameter(_audioUnitRef,
                            kMultiChannelMixerParam_Volume,
                            kAudioUnitScope_Output,
                            0,  // output bus
                            _volume,
                            0),
      kAUMAudioUnitException,
      @"Error setting output volume to %f on AUMMultichannelMixerUnit %@", _volume, self);
    
    // INPUT ENABLES
    for (NSNumber *key in _inputBussesVolumeDict) {
        UInt32 bus = key.unsignedIntegerValue;
        AudioUnitParameterValue enabled = [_inputBussesVolumeDict[key] floatValue];
        _(AudioUnitSetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Enable,
                                kAudioUnitScope_Input,
                                bus,
                                enabled,
                                0),
          kAUMAudioUnitException,
          @"Error %@abling bus %u on unit %@", enabled?@"en":@"dis", bus, self);
    }
    [_inputBussesEnableStateDict removeAllObjects];
    
    // INPUT BUS VOLUMES
    for (NSNumber *key in _inputBussesVolumeDict) {
        UInt32 bus = key.unsignedIntegerValue;
        AudioUnitParameterValue vol = [_inputBussesVolumeDict[key] floatValue];
        _(AudioUnitSetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Volume,
                                kAudioUnitScope_Input,
                                bus,
                                vol,
                                0),
          kAUMAudioUnitException,
          @"Error setting volume to %f on bus %u on unit %@", vol, bus, self);
    }
    [_inputBussesVolumeDict removeAllObjects];
    
    // INPUT BUS PANNINGS
    for (NSNumber *key in _inputBussesVolumeDict) {
        UInt32 bus = key.unsignedIntegerValue;
        AudioUnitParameterValue pan = [_inputBussesVolumeDict[key] floatValue];
        _(AudioUnitSetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Pan,
                                kAudioUnitScope_Input,
                                bus,
                                pan,
                                0),
          kAUMAudioUnitException,
          @"Error setting pan to %f on bus %u on unit %@", pan, bus, self);
    }
    [_inputBussesPanDict removeAllObjects];
}

/// @}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)setEnabled:(BOOL)isEnabled onBus:(NSUInteger)aBusNum
{
    AudioUnitParameterValue isEn = isEnabled ? 1.0 : 0.0;
    if (_hasBeenAddedToGraph) {
        _(AudioUnitSetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Enable,
                                kAudioUnitScope_Input,
                                aBusNum,
                                isEn,
                                0),
          kAUMAudioUnitException,
          @"Error %@abling bus %u on unit %@", isEnabled?@"en":@"dis", aBusNum, self);
    } else {
        
        // Store for late binding
        _inputBussesEnableStateDict[@(aBusNum)] = @(isEn);  // iOS 5 doesn't like @(BOOL)
    }
}

- (BOOL)isEnabledBus:(NSUInteger)aBusNum
{
    AudioUnitParameterValue isEn;
    
    if (_hasBeenAddedToGraph) {
        _(AudioUnitGetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Enable,
                                kAudioUnitScope_Input,
                                aBusNum,
                                &isEn),
          kAUMAudioUnitException,
          @"Error getting enabled state of bus %u on unit %@", aBusNum, self);
    } else {
        
        // Store for late binding
        isEn = [_inputBussesEnableStateDict[@(aBusNum)] floatValue];
    }
    
    return (BOOL)isEn;
}

/////////////////////////////////////////////////////////////////////////

- (void)setVolume:(AUMAudioControlParameter)newVolume onBus:(NSUInteger)aBusNum
{
    if (_hasBeenAddedToGraph) {
        _(AudioUnitSetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Volume,
                                kAudioUnitScope_Input,
                                aBusNum,
                                newVolume,
                                0),
          kAUMAudioUnitException,
          @"Error setting volume to %f on bus %u on unit %@", newVolume, aBusNum, self);
    } else {
        
        // Store for late binding
        _inputBussesVolumeDict[@(aBusNum)] = @(newVolume);
    }
}

- (AUMAudioControlParameter)volumeOfBus:(NSUInteger)aBusNum
{
    AudioUnitParameterValue vol;
    
    if (_hasBeenAddedToGraph) {
        _(AudioUnitGetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Volume,
                                kAudioUnitScope_Input,
                                aBusNum,
                                &vol),
          kAUMAudioUnitException,
          @"Error getting volume on bus %u on unit %@", aBusNum, self);
    } else {
        
        // Store for late binding
        vol = [_inputBussesVolumeDict[@(aBusNum)] floatValue];
    }
    
    return vol;
}

/////////////////////////////////////////////////////////////////////////

- (void)setPan:(AUMAudioControlParameter)newPan onBus:(NSUInteger)aBusNum
{
    if (_hasBeenAddedToGraph) {
        _(AudioUnitSetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Pan,
                                kAudioUnitScope_Input,
                                aBusNum,
                                newPan,
                                0),
          kAUMAudioUnitException,
          @"Error setting pan to %f on bus %u on unit %@", newPan, aBusNum, self);
    } else {
        
        // Store for late binding
        _inputBussesVolumeDict[@(aBusNum)] = @(newPan);
    }
}

- (AUMAudioControlParameter)panOfBus:(NSUInteger)aBusNum
{
    AudioUnitParameterValue pan;
    
    if (_hasBeenAddedToGraph) {
        _(AudioUnitGetParameter(_audioUnitRef,
                                kMultiChannelMixerParam_Pan,
                                kAudioUnitScope_Input,
                                aBusNum,
                                &pan),
          kAUMAudioUnitException,
          @"Error getting volume on bus %u on unit %@", aBusNum, self);
    } else {
        
        // Store for late binding
        pan = [_inputBussesVolumeDict[@(aBusNum)] floatValue];
    }
    
    return pan;
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}