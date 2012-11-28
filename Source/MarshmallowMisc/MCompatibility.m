/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 28/11/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */


#import "MCompatibility.h"
#import <UIKit/UIKit.h>

@implementation MCompatibility

+ (BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.f);
}


+ (BOOL)isRetina4
{
    return [self isRetina] && [UIScreen mainScreen].bounds.size.height == 568.f;
}

@end

/// @}