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



/////////////////////////////////////////////////////////////////////////
#pragma mark - Resizing Methods
/////////////////////////////////////////////////////////////////////////

- (void)resizeByWidth:(CGFloat)deltaW height:(CGFloat)deltaH
{
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width + deltaW,
                            self.frame.size.height + deltaH);
}

/////////////////////////////////////////////////////////////////////////

- (void)resizeToWidth:(CGFloat)aWidth height:(CGFloat)aHeight
{
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            aWidth,
                            aHeight);
}

/////////////////////////////////////////////////////////////////////////

- (void)resizeToWidth:(CGFloat)aWidth
{
    [self resizeToWidth:aWidth height:self.frame.size.height];
}

/////////////////////////////////////////////////////////////////////////

- (void)resizeToHeight:(CGFloat)aHeight
{
    [self resizeToWidth:self.frame.size.width height:aHeight];
}

/////////////////////////////////////////////////////////////////////////





/*- (void)dumpViewHierarchy
{
    [self _dumpViewHierarchyForViewSelfWithIndent:@""];
}
- (void)_dumpViewHierarchyForView:(UIView *)aView withIndent:(NSString *)indent
{
    NSLog(@"%@%@", indent, self);      // dump this view
    
    if (aView.subviews.count > 0) {
        NSString* subIndent = [[NSString alloc] initWithFormat:@"%@%@",
                               indent, ([indent length]/2)%2==0 ? @"| " : @": "];
        for (UIView* aSubview in aView.subviews) dumpView( aSubview, subIndent );
        [subIndent release];
    }
}*/
@end

/// @}