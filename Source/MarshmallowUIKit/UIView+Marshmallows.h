/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 06/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{
 */
/// \file UIView+Marshmallows.h

#import <UIKit/UIKit.h>

/**
 \brief 
 */
@interface UIView (Marshmallows)

/** @name Positioning convenience methods */
- (void)moveByDeltaX:(CGFloat)delX deltaY:(CGFloat)delY;
- (void)moveOriginToX:(CGFloat)theX;
- (void)moveOriginToY:(CGFloat)theY;
- (void)moveOriginToX:(CGFloat)theX y:(CGFloat)theY;
/// *}


//- (void)dumpViewHierarchy;


@end
/// @}