/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file AUMErrorChecking.h

#import "AUMTypes.h"
#import "AUMException.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - Error checking convenience function
/////////////////////////////////////////////////////////////////////////

/** Basic function for others to call.  Don't use in client */
static inline void _(OSStatus err, NSString *exceptionName, NSString *format, ...)
{
    if (err == 0)  return;

    va_list args;
    va_start(args, format);
    [AUMException raise:exceptionName OSStatus:err format:format arguments:args];
    va_end(args);
}

/////////////////////////////////////////////////////////////////////////

