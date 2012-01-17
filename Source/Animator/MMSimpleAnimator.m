//
//  MMBasicAnimator.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMSimpleAnimator.h"

@implementation MMSimpleAnimator

@synthesize fromValue, toValue;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Initialization

+ (id)animatorFromValue:(CGFloat)theFromValue toValue:(CGFloat)theToValue
{
    MMSimpleAnimator *anim = [[self alloc] init];
    if (anim != nil) {
        anim.fromValue = theFromValue;
        anim.toValue = theToValue;
    }
    return anim;
}


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Abstract Methods from MMAnimator

- (CGFloat)currentValue
{
    CFTimeInterval t;
    
    switch (status) {
            
        case kMMAnimatorNotStarted:
            return fromValue;
            
        case kMMAnimatorFinished:
            return toValue;
            
        case kMMAnimatorRunning:
        case kMMAnimatorPaused:
        default:
            
            // If not passed the offset time then send the start value
            t = CACurrentMediaTime() - startTime;
            if (t <= beginTimeOffset) {
                return fromValue;
            }

            // adjust for offset time
            t -= beginTimeOffset;

            // Past the duration => toValue
            // Set the status too
            if (t >= duration || duration == 0.0) {
                status = kMMAnimatorFinished;
                return toValue;
            }
            
            // Otherwise do the calculation
            return fromValue + (toValue - fromValue) * self.timingFunction(t / self.duration);
    }
}

/** ********************************************************************/

- (MMAnimatorStatus)status 
{
    // Call currentValue to update
    [self currentValue];
    return status;
}

@end
