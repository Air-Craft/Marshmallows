//
//  MPStopwatch.m
//  Marshmallows
//
//  Created by  on 23/03/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#import "MPStopwatch.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - MPStopwatch()
/////////////////////////////////////////////////////////////////////////

@interface MPStopwatch() 
{
    NSDate *startTime;   
    NSDate *lastMarkTime;
    NSMutableArray *pauseOnTimes;      ///< NSArray => NSDate's
    NSMutableArray *pauseOffTimes;     ///< NSArray => NSDate's
}


/// Returns unpaused time from the specified date until now
- (NSTimeInterval)runningTimeSinceDate:(NSDate *)fromDate;

@end



/////////////////////////////////////////////////////////////////////////
#pragma mark - MPStopwatch
/////////////////////////////////////////////////////////////////////////

@implementation MPStopwatch

- (MPStopwatch *)init 
{
    if (self = [super init]) {
        pauseOnTimes = [NSMutableArray array];
        pauseOffTimes = [NSMutableArray array];
        startTime = nil;
        lastMarkTime = nil;
    }
    return self;
}
/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (MPStopwatch *)start
{
    if (nil != startTime) [NSException raise:NSInternalInconsistencyException format:@"MPStopwatch: Already started!"];
    
    startTime = [NSDate date];
    return self;
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)isStarted
{
    return (startTime != nil);
}

/////////////////////////////////////////////////////////////////////////

- (void)restart
{
    if (nil == startTime) [NSException raise:NSInternalInconsistencyException format:@"MPStopwatch: Must call 'start' first!"];
    
    pauseOnTimes = [NSMutableArray array];
    pauseOffTimes = [NSMutableArray array];
    lastMarkTime = nil;
    startTime = [NSDate date];    
}

/////////////////////////////////////////////////////////////////////////

- (NSTimeInterval)pause
{
    if (nil == startTime) [NSException raise:NSInternalInconsistencyException format:@"MPStopwatch: Must call 'start' first!"];

    // Paused already?  Do nothing
    if ([self isPaused]) {
        return 0.0;
    }
    
    // Add the current timer to the paused dict
    NSDate *lastResumeOrStart;
    if (![pauseOnTimes count]) {
        lastResumeOrStart = startTime;
    } else {
        lastResumeOrStart = [pauseOnTimes lastObject];  // can be assumed to exist with above conditions
    }
    [pauseOnTimes addObject:[NSDate date]];
    
    return [self runningTimeSinceDate:lastResumeOrStart];
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)isPaused
{   
    if (nil == startTime) [NSException raise:NSInternalInconsistencyException format:@"MPStopwatch: Must call 'start' first!"];

    // We'll rely on the consistency in the pause dict's
    if (!pauseOnTimes) {                 // = no entry
        return NO;
    } else if (!pauseOffTimes) {         // = one pause with no resume
        return YES;
    } else if ([pauseOnTimes count] == [pauseOffTimes count]) {       // even stevens
        return NO;
    } else if ([pauseOnTimes count] == (1 + [pauseOffTimes count])) {   // paused
        return YES;
    } else {
        NSAssert(false, @"This shouldn't be!  Pause arrays out of sync == BUG!");
        return NO;
    }
}

/////////////////////////////////////////////////////////////////////////

- (NSTimeInterval)resume
{
    if (nil == startTime) [NSException raise:NSInternalInconsistencyException format:@"MPStopwatch: Must call 'start' first!"];

    if (![self isPaused]) {
        return 0.0;
    }
    
    NSTimeInterval timePaused = -[(NSDate *)[pauseOnTimes lastObject] timeIntervalSinceNow];
    
    // Add to the resumed dict
    [pauseOffTimes addObject:[NSDate date]];
    
    return timePaused;
}

/////////////////////////////////////////////////////////////////////////

- (NSTimeInterval)mark
{
    if (nil == startTime) [NSException raise:NSInternalInconsistencyException format:@"MPStopwatch: Must call 'start' first!"];

    // Get the time since previous mark first
    NSTimeInterval timeSinceLastMark = [self runningTimeSinceLastMark];
    
    // Add mark to the dict
    lastMarkTime = [NSDate date];
    
    return timeSinceLastMark;
}

/////////////////////////////////////////////////////////////////////////

- (NSTimeInterval)runningTimeSinceLastMark
{
    if (nil == startTime) [NSException raise:NSInternalInconsistencyException format:@"MPStopwatch: Must call 'start' first!"];

    // Get the time since last mark excluding any paused periods

    // Get the last mark time or start time if none
    NSDate *lastMarkOrStartTime = lastMarkTime;
    if (!lastMarkOrStartTime) {
        lastMarkOrStartTime = startTime;
    }
    
    return [self runningTimeSinceDate:lastMarkOrStartTime];
}

/////////////////////////////////////////////////////////////////////////

- (NSTimeInterval)runningTimeSinceStart
{
    if (nil == startTime) [NSException raise:NSInternalInconsistencyException format:@"MPStopwatch: Must call 'start' first!"];

    return [self runningTimeSinceDate:startTime];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////

- (NSTimeInterval)runningTimeSinceDate:(NSDate *)fromDate
{
    if (nil == startTime) [NSException raise:NSInternalInconsistencyException format:@"MPStopwatch: Must call 'start' first!"];

    // Start with the time plus pauses (negate to get positive time)
    NSTimeInterval totalTime = -[fromDate timeIntervalSinceNow];
    
    // Loop through paused periods and subtract if within mark time window
    
    for (int i=0; i < [pauseOnTimes count]; i++) {
        // Extract the on off times for this segment
        NSDate *pauseOn, *pauseOff;
        pauseOn = [pauseOnTimes objectAtIndex:i];
        if ([pauseOffTimes count] > i) {
            pauseOff = [pauseOffTimes objectAtIndex:i];
        } 
        
        // NOTE: Below uses "+=" because the times are negative wrt NOW
        
        // Case 1: Still paused and fromTime is before pause on = subtract current pause time
        if (!pauseOff && [fromDate compare:pauseOn] == NSOrderedAscending) {
            totalTime += [pauseOn timeIntervalSinceNow];
            
        // Case 2: Still pause and fromTime is *after* pause on.  = subtract from fromDate to now
        } else if (!pauseOff ) {
            totalTime += [fromDate timeIntervalSinceNow];
            
        // Case 3:  Pause window is entirely *before* fromDate.  Ignore.
        } else if ([pauseOff compare:fromDate] == NSOrderedAscending) {
            
        // Case 4: Pause window is entirely after fromDate.  Subtract entire range
        } else if ([fromDate compare:pauseOn] == NSOrderedAscending) {
            totalTime += [pauseOn timeIntervalSinceDate:pauseOff];
            
        // Case 5: Pause window began before time and completed after = subtract (pause off - fromTime)
        } else if ([fromDate compare:pauseOff] == NSOrderedAscending) {
            totalTime += [fromDate timeIntervalSinceDate:pauseOff];
        }
        else {
            [NSException raise:NSInternalInconsistencyException format:@"This MPMultiTimer case should not exist!"];
        }
    }
    
    return totalTime;
}

@end
