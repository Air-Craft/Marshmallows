/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 24/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file AUMCapturerRenderer.h


#import <Foundation/Foundation.h>

#import "AUMRendererProtocolAbstract.h"

@class AUMUnitAbstract;
@protocol AUMCapturerRendererProtocol <AUMRendererProtocolAbstract>

@optional
- (void)willAttachToOutputBus:(NSUInteger)anOutputBusNum ofAUMUnit:(AUMUnitAbstract *)anAUMUnit;
- (void)didAttachToOutputBus:(NSUInteger)anOutputBusNum ofAUMUnit:(AUMUnitAbstract *)anAUMUnit;


@end


/// @}