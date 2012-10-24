/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 24/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file NSString+Marshmallows.h

#import <Foundation/Foundation.h>


@interface NSString (Marshmallows)

/** Convert an OSStatus number to its 4 char code as an NSString, or to a string of the number if it isn't a char code */
+ (NSString *)mm_ErrorCodeStringFromOSStatus:(OSStatus)anOSStatus;



@end
/// @}