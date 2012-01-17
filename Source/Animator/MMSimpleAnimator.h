//
//  MMBasicAnimator.h
//  Marshmallows
//
//  Created by Hari Karam Singh on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MMAnimator.h"


/**
 Concrete subclass of MMAnimator for passive animation between a start and end value.
 
 To use, create an object and customise properties as required.  Set "fromValue", "toValue" and "duration" to > 0.0.  Call "start" and read "currentValue" as required.  "finished" can be used to detect completion.
 */
@interface MMSimpleAnimator : MMAnimator 
{
    CGFloat fromValue;
    CGFloat toValue;
}

/** The value of the animation (ie currentValue) immediately after a call to start.  Also the value prior to starting if resetToInitValueOnFinish is NO */
@property (atomic) CGFloat fromValue;

/** The value of the animation at the exact end of the duration.  Also the value after the end if resetToInitValueOnFinish is NO */
@property (atomic) CGFloat toValue;


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Class Methods

+ (id)animatorFromValue:(CGFloat)theFromValue toValue:(CGFloat)theToValue;


@end
