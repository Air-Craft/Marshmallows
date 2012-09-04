/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AUMProxyUnitAbstract.h
 
 
#import <Foundation/Foundation.h>
#import "AUMUnitProtocol.h"

/**
 \brief An AUMUnit proxy to another AUMUnit allowing extension without exposing the parent unit's API
 
 Subclasses are fulfledged AUMUnits (in that they fulfill AUMUnitProtocol).  To use set the protected _proxiedUnit ivar to an instantiation of the desired unit to proxy.  Be sure to call super on any overridden methods.
 */
@interface AUMProxyUnitAbstract : NSObject <AUMUnitProtocol>
{
@protected
    id<AUMUnitProtocol> _proxiedUnit;
}
@end

/// @}