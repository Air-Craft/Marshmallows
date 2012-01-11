//
//  MMAnimation.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 10/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMAnimator.h"

@implementation MMAnimator

@synthesize timingFunction, beginTimeOffset, duration, currentValue, status;


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Class Methods

+ (id)animator
{
    return [[self alloc] init];
}


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Life Cycle

- (id)init 
{
    if (self = [super init]) {
        
        // Set default properties
        timingFunction = MMAnimatorTimingLinear;
        status = kMMAnimatorNotStarted;
        
        // 0 or NO for everything else.
    }
    return self;
}


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Getter/Setters

- (BOOL)hasFinished { return status == kMMAnimatorFinished; }

- (BOOL)hasStarted { return (status == kMMAnimatorPaused || status == kMMAnimatorRunning); }


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Public API

- (void)start 
{ 
    startTime = CACurrentMediaTime();
    status = kMMAnimatorRunning;
}

/** ********************************************************************/

@end