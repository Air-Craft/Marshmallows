/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 24/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file AUMProcessorRendererProtocol.h


#import <Foundation/Foundation.h>
#import "AUMRendererProtocolAbstract.h"

@class AUMUnitAbstract;

@protocol AUMProcessorRendererProtocol <AUMRendererProtocolAbstract>

@optional
- (void)willAddToAUMUnit:(AUMUnitAbstract *)anAUMInit;
- (void)didAddToAUMUnit:(AUMUnitAbstract *)anAUMInit;

@end


/// @}