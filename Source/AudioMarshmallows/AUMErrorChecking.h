/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file AUMErrorChecking.h

#import "AUMTypes.h"

/**  Error checking convenience function */
static inline void _(OSStatus err, NSString *reason)
{
    if (err == 0)  return;
    NSDictionary *userInfo = @{ kAUMOSStatusCodeKey : @(err) };
    @throw [NSException exceptionWithName:kAUMException reason:reason userInfo:userInfo];
}

/// @}