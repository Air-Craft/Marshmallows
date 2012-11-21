#import "tgmath.h"  // type genericness
#import <Foundation/Foundation.h>

/**
 Function which maps 0..1 to 0..1 via a custom timing graph.
 */
typedef CFTimeInterval (^MMAnimatorTimingBlock)(CFTimeInterval);

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Function extern const ants

extern const  MMAnimatorTimingBlock MMAnimatorTimingLinear;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Quadratic

extern const  MMAnimatorTimingBlock MMAnimatorTimingQuadraticEaseOut;
extern const  MMAnimatorTimingBlock MMAnimatorTimingQuadraticEaseIn;
extern const  MMAnimatorTimingBlock MMAnimatorTimingQuadraticEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Cubic 

extern const  MMAnimatorTimingBlock MMAnimatorTimingCubicEaseOut ;
extern const  MMAnimatorTimingBlock MMAnimatorTimingCubicEaseIn;
extern const  MMAnimatorTimingBlock MMAnimatorTimingCubicEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Quartic

extern const  MMAnimatorTimingBlock MMAnimatorTimingQuarticEaseOut;
extern const  MMAnimatorTimingBlock MMAnimatorTimingQuarticEaseIn;
extern const  MMAnimatorTimingBlock MMAnimatorTimingQuarticEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Quintic

extern const  MMAnimatorTimingBlock MMAnimatorTimingQuinticEaseOut;
extern const  MMAnimatorTimingBlock MMAnimatorTimingQuinticEaseIn ;
extern const  MMAnimatorTimingBlock MMAnimatorTimingQuinticEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Sinusoidal

extern const  MMAnimatorTimingBlock MMAnimatorTimingSinusoidalEaseOut;
extern const  MMAnimatorTimingBlock MMAnimatorTimingSinusoidalEaseIn;
extern const  MMAnimatorTimingBlock MMAnimatorTimingSinusoidalEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Exponential

extern const  MMAnimatorTimingBlock MMAnimatorTimingExponentialEaseOut;
extern const  MMAnimatorTimingBlock MMAnimatorTimingExponentialEaseIn;
extern const  MMAnimatorTimingBlock MMAnimatorTimingExponentialEaseInOut;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Circular

extern const  MMAnimatorTimingBlock MMAnimatorTimingCircularEaseOut;
extern const  MMAnimatorTimingBlock MMAnimatorTimingCircularEaseIn;
extern const  MMAnimatorTimingBlock MMAnimatorTimingCircularEaseInOut;


