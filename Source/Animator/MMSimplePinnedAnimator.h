//
//  MMSimplePinnedAnimator.h
//  Marshmallows
//
//  Created by Hari Karam Singh on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMSimpleAnimator.h"

/**
 An extension to MMSimpleAnimator which "pins" the animation to an initial value (distinct from "fromValue") and optionally immediately reverts back to that value at the end of the animation.
 */
@interface MMSimplePinnedAnimator : MMSimpleAnimator

/** The value of the animation (ie currentValue) before the animation begins (start + offsetTime) and to which is immediately springs back if resetToPinValueOnFinish == YES */
@property (atomic) CGFloat pinValue; 

/** NO == Stay on toValue.  YES == revert to pinValue.  Defaults to YES. */
@property (atomic) BOOL resetToPinValueOnFinish;
 


@end
