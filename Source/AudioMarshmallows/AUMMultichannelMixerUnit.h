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

/** Get/set the input bus count.  Set anytime after init.  Defaults to 2. = maxInputBusNum + 1
 \throws kAUMAudioUnitException on set if error */
@property (nonatomic) NSUInteger busCount;

@property (nonatomic) AUMAudioControlParameter volume;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

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