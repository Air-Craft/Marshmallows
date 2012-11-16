/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/11/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
#import "MarshmallowsTests.h"
#if DO_MarshmallowMathsTests == 1

#import "MarshmallowMathTests.h"
#import "MarshmallowMath.h"

using namespace Marshmallows;

@implementation MarshmallowMathTests

- (void)testRunningAverageAggregator
{
    NSUInteger SIZE = 4;
    RunningAverageAggregator<float> averager = RunningAverageAggregator<float>(SIZE);
    STAssertEquals(averager.currentValue(), 0.0f, @"Should be 0.0, %f reported", averager.currentValue());
    
    averager.add(10);
    averager.add(10);
    averager.add(10);
    averager.add(10);
    
    STAssertEquals(averager.currentValue(), 10.0f, @"Average should be 10.0, %f reported", averager.currentValue());
    
    averager.add(-10);
    averager.add(-10);
    
    STAssertEquals(averager.currentValue(), 0.0f, @"Average should be 0.0, %f reported", averager.currentValue());
    
}

@end

#endif

/// @}