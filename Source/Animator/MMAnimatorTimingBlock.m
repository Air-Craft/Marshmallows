//
//  MMAnimatorTimingBlock.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMAnimatorTimingBlock.h"

const MMAnimatorTimingBlock MMAnimatorTimingLinear = ^(CFTimeInterval t) {
    return t;
};


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Quadratic

const MMAnimatorTimingBlock MMAnimatorTimingQuadraticEaseIn = ^(CFTimeInterval t)
{
    return t * t;
};

/** ********************************************************************/


const MMAnimatorTimingBlock MMAnimatorTimingQuadraticEaseOut = ^(CFTimeInterval t)
{
    //return   -t * (t - 2.0) -1.0;
    return t * (2.0 - t);
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingQuadraticEaseInOut = ^(CFTimeInterval t)
{
/*    t *= 2.0;
    if (t < 1.0) return 0.5 * t * t - 1.0;
    t--;
    return -0.5 * (t*(t-2) - 1) - 1.0;*/
    if (t <= 0.5)
        return MMAnimatorTimingQuadraticEaseIn(t);
    else
        return MMAnimatorTimingQuadraticEaseOut(t);
};


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Cubic 

const MMAnimatorTimingBlock MMAnimatorTimingCubicEaseIn = ^(CFTimeInterval t)
{
//    return t * t * t - 1.0;
    return t * t * t;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingCubicEaseOut = ^(CFTimeInterval t)
{
    t--;
    return (t * t * t + 1.0);// - 1.0;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingCubicEaseInOut = ^(CFTimeInterval t)
{
    /*t *= 2.0;
    if (t < 1.0) return 0.5 * t * t * t - 1.0;
    t -= 2.0;
    return 0.5*(t * t * t + 2) - 1.0;*/
    if (t <= 0.5)
        return MMAnimatorTimingCubicEaseIn(t);
    else
        return MMAnimatorTimingCubicEaseInOut(t);
};


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Quartic

const MMAnimatorTimingBlock MMAnimatorTimingQuarticEaseOut = ^(CFTimeInterval t)
{
    t--;
    return -1.0 * (t * t * t * t - 1) - 1.0;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingQuarticEaseIn = ^(CFTimeInterval t)
{
    return t * t * t * t;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingQuarticEaseInOut = ^(CFTimeInterval t)
{
    t *= 2.0;
    if (t < 1.0) 
        return 0.5 * t * t * t * t - 1.0;
    t -= 2.0;
    return -0.5 * (t * t * t * t - 2.0) - 1.0;
};


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Quintic

const MMAnimatorTimingBlock MMAnimatorTimingQuinticEaseOut = ^(CFTimeInterval t)
{
    t--;
    return (t * t * t * t * t + 1) - 1.0;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingQuinticEaseIn = ^(CFTimeInterval t)
{
    return t * t * t * t * t - 1.0;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingQuinticEaseInOut = ^(CFTimeInterval t)
{
    t *= 2.0;
    if (t < 1.0) 
        return 0.5 * t * t * t * t * t - 1.0;
    t -= 2;
    return 0.5 * ( t * t * t * t * t + 2) - 1.0;
};


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Sinusoidal

const MMAnimatorTimingBlock MMAnimatorTimingSinusoidalEaseOut = ^(CFTimeInterval t)
{
    return sin(t * (M_PI/2)) - 1.0;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingSinusoidalEaseIn = ^(CFTimeInterval t)
{
    return -1.0 * cos(t * (M_PI/2));
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingSinusoidalEaseInOut = ^(CFTimeInterval t)
{
    return -0.5 * (cos(M_PI*t) - 1.0) - 1.0;
};


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Exponential

const MMAnimatorTimingBlock MMAnimatorTimingExponentialEaseOut = ^(CFTimeInterval t)
{
    return (-pow(2.0, -10.f * t) + 1.0 ) - 1.0;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingExponentialEaseIn = ^(CFTimeInterval t)
{
    return pow(2.0, 10.f * (t - 1.0) ) - 1.0;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingExponentialEaseInOut = ^(CFTimeInterval t)
{
    t *= 2.0;
    if (t < 1.0) 
        return 0.5 * pow(2.0, 10.f * (t - 1.0) ) - 1.0;
    t--;
    return 0.5 * ( -pow(2.0, -10.f * t) + 2.0 ) - 1.0;
};


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Circular

const MMAnimatorTimingBlock MMAnimatorTimingCircularEaseOut = ^(CFTimeInterval t)
{
    t--;
    return sqrt(1.0 - t * t) - 1.0;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingCircularEaseIn = ^(CFTimeInterval t)
{
    return -1.0 * (sqrt(1.0 - t * t) - 1.0) - 1.0;
};

/** ********************************************************************/

const MMAnimatorTimingBlock MMAnimatorTimingCircularEaseInOut = ^(CFTimeInterval t)
{
    t *= 2.0;
    if (t < 1.0) 
        return -0.5 * (sqrt(1.0 - t * t) - 1.0) - 1.0;
    t -= 2.0;
    return 0.5 * (sqrt(1.0 - t * t) + 1.0) - 1.0;
};

