//
//  MMSimplePinnedAnimator.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMSimplePinnedAnimator.h"

@implementation MMSimplePinnedAnimator

@synthesize pinValue, resetToPinValueOnFinish;


- (id)init {
    if (self = [super init]) {
        resetToPinValueOnFinish = YES;      // Default to YES
    }
    return self;
}


/**
 Tweaks to use the pinValue where appropriate
 */
- (CGFloat)currentValue
{
    CFTimeInterval t;
    
    switch (status) {
            
        case kMMAnimatorNotStarted:
            return pinValue;
            
        case kMMAnimatorFinished:
            return resetToPinValueOnFinish ? pinValue : super.currentValue;
            
        case kMMAnimatorRunning:
        case kMMAnimatorPaused:
        default:
            
            // Tweaks to use the pin value...
            
            t = CACurrentMediaTime() - startTime;
            if (t <= beginTimeOffset) {
                return pinValue;
            }
            
            t -= beginTimeOffset;
            
            // Past the duration => toValue
            // Set the status too
            if (t >= duration || duration == 0.0) {
                status = kMMAnimatorFinished;
                return resetToPinValueOnFinish ? pinValue : super.currentValue; 
            }
            
            // Otherwise do the calculation
            return super.currentValue;
    }
}

@end
