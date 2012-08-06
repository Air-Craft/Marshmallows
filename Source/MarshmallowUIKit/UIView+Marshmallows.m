/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 06/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{
 */

#import "UIView+Marshmallows.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - UIView (Marshmallows)
/////////////////////////////////////////////////////////////////////////

@implementation UIView (Marshmallows)

- (void)moveByDeltaX:(CGFloat)delX deltaY:(CGFloat)delY
{
    self.frame = CGRectMake(
                            self.frame.origin.x +delX,
                            self.frame.origin.y + delY,
                            self.frame.size.width,
                            self.frame.size.height
                            );
}

////////////////////////////////////////////////////////////////////////////

- (void)moveOriginToX:(CGFloat)theX
{
    self.frame = CGRectMake(
                            theX,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height
                            );
}

/////////////////////////////////////////////////////////////////////////


- (void)moveOriginToY:(CGFloat)theY
{
    self.frame = CGRectMake(
                            self.frame.origin.x,
                            theY,
                            self.frame.size.width,
                            self.frame.size.height
                            );
}

/////////////////////////////////////////////////////////////////////////

- (void)moveOriginToX:(CGFloat)theX y:(CGFloat)theY
{
    self.frame = CGRectMake(
                            theX,
                            theY,
                            self.frame.size.width,
                            self.frame.size.height
                            );
}

@end

/// @}