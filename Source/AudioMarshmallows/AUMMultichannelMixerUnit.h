/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */
/// \file AUMMultichannelMixerUnit.h

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import "AUMTypes.h"
#import "AUMUnitAbstract.h"

/**
 \brief The Apple Multichannel Mixer
 
 \todo Metering support for ins and outs
 */
@interface AUMMultichannelMixerUnit : AUMUnitAbstract


/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

/** Override to allow user setting.  Defaults to 0 and must be set after instantiation.
 \throws kAUMAudioUnitException on set if error */
@property (nonatomic, readwrite) NSInteger inputBusCount;

@property (nonatomic) AUMAudioControlParameter volume;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

/** Designated Init. Sample rate needed by the AU */
- (id)initWithSampleRate:(NSTimeInterval)aSampleRate;

/** Tries to get the sample rate from the AUMAudioSession 
 \throws NSInteralInconsistencyException if SR == 0 (ie not set) */
- (id)init;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)setEnabled:(BOOL)isEnabled onBus:(NSUInteger)aBusNum;
- (void)setVolume:(AUMAudioControlParameter)newVolume onBus:(NSUInteger)aBusNum;
- (void)setPan:(AUMAudioControlParameter)newPan onBus:(NSUInteger)aBusNum;

- (BOOL)isEnabledBus:(NSUInteger)aBusNum;
- (AUMAudioControlParameter)volumeOfBus:(NSUInteger)aBusNum;
- (AUMAudioControlParameter)panOfBus:(NSUInteger)aBusNum;

	

@end

/// @}