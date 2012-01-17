//
//  MMAnimation.h
//  Marshmallows
//
//  Created by Hari Karam Singh on 10/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MMAnimatorTimingBlock.h"

/**
 The running status of the animation
 */
typedef enum {
    kMMAnimatorNotStarted,
    kMMAnimatorRunning,
    kMMAnimatorPaused,
    kMMAnimatorFinished
} MMAnimatorStatus;


/**
 An abstract base class for animating values.  
 
 This class defines the base for passive animation which interpolates between given values using the supplied CAMediatTimingFunction.  See MMBasicAnimator for usage details.  
 
 This class can be subclassed for adding functionality that connects it to properties and integrates it with a run loop.  It loosely follows the CAAnimation construct implicitly incorporating most of  CAMediaTimingProtocol (a seperate protocol isn't really needed here) and leaves the animation endpoints to be handled by concrete subclasses.  The main difference with CAAnimation is that it is designed to be useful for animating arbitrary parameters.
 
 To subclass, implement the public methods and a getters where required.
 
 @par FUTURE
 MMBasicPropertyAnimator:MMBasicAnimator <MMAnimatorEventsDelegate>
 @delegate
 @target
 @keypath
 @inSeperateThread - create a new runloop thread
 @inRunLoop: - uses specified runloop
 - uses CADisplayLink and run loop + optional seperate threads
 - events are sent to delegate
 
 @abstract 
 */
@interface MMAnimator : NSObject 
{
    CFTimeInterval startTime;
    
    // Property ivar declared explicitly for subclasses to have access to
    MMAnimatorTimingBlock timingFunction;
    CFTimeInterval beginTimeOffset;
    CFTimeInterval duration;
    CGFloat currentValue;
    MMAnimatorStatus status;
}


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Properties

/** A block based timing function defining the pacing of the animation. Defaults to nil indicating linear pacing. */
@property (atomic, strong) MMAnimatorTimingBlock timingFunction;

/** Time to wait from call to start in order to actually bgin the animation. Defaults to 0. */
@property (atomic) CFTimeInterval beginTimeOffset;

/** The animation duration. Defaults to 0. Total time = beginTimeOffset + duration. */
@property CFTimeInterval duration;

/** @abstract The current value given the time the animation has been running.  MUST be handled by the subclass */
@property (atomic, readonly) CGFloat currentValue;

/** The running status of the animation.  See \link MMAnimatorStatus enum. */
@property (atomic, readonly) MMAnimatorStatus status;

/** Convenient property/method for checking status */
@property (atomic, readonly, getter=hasFinished) BOOL finished;

/** Convenient property/method.  True if status == running or paused */
@property (atomic, readonly, getter=hasStarted) BOOL started;


/** 
 The repeat count of the object. May be fractional. Defaults to 0. 
 
 If repeat count and repeat duration are both set then the result is undefined.
 @todo To be implemented...
 */
//@property float repeatCount;

/** The repeat duration of the object. Defaults to 0. @todo To be implemented...*/
//@property CFTimeInterval repeatDuration;

/** When true, the object plays backwards after playing forwards. Defaults to false. @todo To be implemented...*/
//@property BOOL autoreverses;


// @property (atomic, readonly) MMAnimatorRunningStatus runningStatus;


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Class Methods

/** Creates a new animation object. */
+ (MMAnimator *)animator;


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Public Methods

/**
 Sets the start time and begins the animation. Also works as a restart for running animations.
 
 Marks the start time ivar.  No need to override in subclass unless requried for specific implementation reasons.  
 */
- (void)start;

//- (void)pause;


@end
