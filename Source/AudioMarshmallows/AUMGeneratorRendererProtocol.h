/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 24/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file AUMGeneratorRendererProtocol.h


#import <Foundation/Foundation.h>
#import "AUMRendererProtocolAbstract.h"

@class AUMUnitAbstract;

@protocol AUMGeneratorRendererProtocol <AUMRendererProtocolAbstract>

@optional
- (void)willAttachToInputBus:(NSUInteger)anInputBusNum ofAUMUnit:(AUMUnitAbstract *)anAUMUnit;
- (void)didAttachToInputBus:(NSUInteger)anInputBusNum ofAUMUnit:(AUMUnitAbstract *)anAUMUnit;

@end


/// @}