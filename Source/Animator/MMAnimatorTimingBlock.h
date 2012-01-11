#import "tgmath.h"  // type genericness
#import <Foundation/Foundation.h>

/**
 Function which maps 0..1 to 0..1 via a custom timing graph.
 */
typedef CFTimeInterval (^MMAnimatorTimingBlock)(CFTimeInterval);



/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Function constants

const MMAnimatorTimingBlock MMAnimatorTimingLinear;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Quadratic

const MMAnimatorTimingBlock MMAnimatorTimingQuadraticEaseOut;
const MMAnimatorTimingBlock MMAnimatorTimingQuadraticEaseIn;
const MMAnimatorTimingBlock MMAnimatorTimingQuadraticEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Cubic 

const MMAnimatorTimingBlock MMAnimatorTimingCubicEaseOut ;
const MMAnimatorTimingBlock MMAnimatorTimingCubicEaseIn;
const MMAnimatorTimingBlock MMAnimatorTimingCubicEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Quartic

const MMAnimatorTimingBlock MMAnimatorTimingQuarticEaseOut;
const MMAnimatorTimingBlock MMAnimatorTimingQuarticEaseIn;
const MMAnimatorTimingBlock MMAnimatorTimingQuarticEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Quintic

const MMAnimatorTimingBlock MMAnimatorTimingQuinticEaseOut;
const MMAnimatorTimingBlock MMAnimatorTimingQuinticEaseIn ;
const MMAnimatorTimingBlock MMAnimatorTimingQuinticEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Sinusoidal

const MMAnimatorTimingBlock MMAnimatorTimingSinusoidalEaseOut;
const MMAnimatorTimingBlock MMAnimatorTimingSinusoidalEaseIn;
const MMAnimatorTimingBlock MMAnimatorTimingSinusoidalEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Exponential

const MMAnimatorTimingBlock MMAnimatorTimingExponentialEaseOut;
const MMAnimatorTimingBlock MMAnimatorTimingExponentialEaseIn;
const MMAnimatorTimingBlock MMAnimatorTimingExponentialEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Circular

const MMAnimatorTimingBlock MMAnimatorTimingCircularEaseOut;
const MMAnimatorTimingBlock MMAnimatorTimingCircularEaseIn;
const MMAnimatorTimingBlock MMAnimatorTimingCircularEaseInOut;
