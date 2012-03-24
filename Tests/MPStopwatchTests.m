#import "MarshmallowsTests.h"
#if DO_MPStopwatchTests == 1
/** 
 \addtogroup MarshmallowsTests
 \author     Created by  on 24/03/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */


#import "MPStopwatchTests.h"
#import "Marshmallows.h"

@interface MPStopwatchTests() {
    NSTimeInterval testTimeInterval;
    NSTimeInterval accuracy;
    MPStopwatch *stopwatch;
    
}
@end

@implementation MPStopwatchTests

- (void)setUp
{
    testTimeInterval = 0.3;
    accuracy = testTimeInterval * 5.0/100;     // 5%
    
    // Start the timer
    stopwatch = [[MPStopwatch alloc] init];
}

/// Run and check running times
- (void)testBasic
{
    NSTimeInterval val;

    // Test 0 @ start
    val = [stopwatch runningTimeSinceStart];
    STAssertEqualsWithAccuracy(val, 0.0, accuracy, @"Time lapsed at start should be 0!");
    
    // Run for test time period
    usleep(testTimeInterval * 1e6);
    
    // Check time lapsed
    val = [stopwatch runningTimeSinceStart];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Plain vanilla runningTimeSinceStart fails");

    // Mark should be the same here
    val = [stopwatch runningTimeSinceLastMark];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Plain vanilla runningTimeSinceLastMark fails");    
}

/// Checks with pauses
- (void)testPause
{
    NSTimeInterval val;
    usleep(testTimeInterval * 1e6);     // Running time 1x time interval
    
    // Check running time reported correctly
    val = [stopwatch pause];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Running time not reported correctly at first pause!");
    
    usleep(testTimeInterval * 1e6);     // Running time 1x time interval
    
    // Check pause works
    val = [stopwatch runningTimeSinceStart];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Time continued while paused!");
    
    // Check pause time reported correctly
    val = [stopwatch resume];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Paused time reported incorrectly at first resume!");
    
    
    // Check continuity on resume
    val = [stopwatch runningTimeSinceStart];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Time jumped upon resume!");
    
    // Wait some more and then check
    usleep(testTimeInterval * 1e6);     // Running time 2x time interval
    
    val = [stopwatch runningTimeSinceStart];
    STAssertEqualsWithAccuracy(val, 2*testTimeInterval, accuracy, @"Issue when resuming after first pause!");
    
    // Check subsequent pauses
    val = [stopwatch pause];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Running time not reported correctly at subsequent pause!");

    usleep(testTimeInterval * 1e6);     // Running time 2x time interval
    
    val = [stopwatch resume];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Paused time not reported correctly at subsequent resume!");

    usleep(testTimeInterval * 1e6);     // Running time 3x time interval
    
    val = [stopwatch runningTimeSinceStart];
    STAssertEqualsWithAccuracy(val, 3*testTimeInterval, accuracy, @"Issue when resuming after subsequent pauses!");
}

- testMarks
{
    NSTimeInterval val;
    usleep(testTimeInterval * 1e6);     // Running time 1x time interval
    
    // First mark
    val = [stopwatch mark];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"First mark reported incorrectly");
    
    usleep(testTimeInterval * 1e6);     // Running time 2x time interval
    
    // Second mark
    val = [stopwatch mark];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Second mark reported incorrectly");
    
    // Marks within a pause
    usleep(testTimeInterval * 1e6);     // Running time since last mark = 1x
    [stopwatch pause];
    usleep(testTimeInterval * 1e6);     // Running time since last mark = 1x
    val = [stopwatch mark];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Mark at mid-pause reported incorrectly");
    
    val = [stopwatch mark];             // Running time since last mark = 0
    STAssertEqualsWithAccuracy(val, 0, accuracy, @"2nd mark at mid-pause reported incorrectly");
    
    [stopwatch resume];
    usleep(testTimeInterval * 1e6);     // Running time since last mark = 1x
    val = [stopwatch mark];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Mark after pause resume but with previous mark within the pause, reported incorrectly!");
    

    // Marks after previous pause
    usleep(testTimeInterval * 1e6);     // Running time since last mark = 1x
    val = [stopwatch mark];
    STAssertEqualsWithAccuracy(val, testTimeInterval, accuracy, @"Mark after pause resume with previous mark also after pause resume, reported incorrectly!");
    
    // Marks surrounding a pause window
    usleep(testTimeInterval * 1e6);     // Running time since last mark = 1x
    [stopwatch pause];
    usleep(testTimeInterval * 1e6);     // Running time since last mark = 1x
    [stopwatch resume];
    usleep(testTimeInterval * 1e6);     // Running time since last mark = 2x
    val = [stopwatch mark];
    STAssertEqualsWithAccuracy(val, 2*testTimeInterval, accuracy, @"Marks surrounding pause window, reported incorrectly!");
}

@end

/// @}
#endif
