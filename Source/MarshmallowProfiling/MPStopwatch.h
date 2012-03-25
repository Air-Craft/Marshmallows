/** 
 \ingroup    Marshmallows
 
 MPStopwatch.h
 
 \author     Created by  on 23/03/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 
 */

#import <Foundation/Foundation.h>

/**
 \brief 
 */
@interface MPStopwatch : NSObject 

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (MPStopwatch *)init;

/// Call to start the timer.  Must be called after init and before other methods.
/// \throws NSInternalInconsistencyException if already started
/// \return Returns self to allow for chaining with alloc/init
- (MPStopwatch *)start;

/// Clears out marks and pauses and restarts the timer.
- (void)restart;

- (BOOL)isStarted;

/// \brief Pauses timer, excluding this time period from reported durations. Returns the time since start or last pause or 0 if already paused
- (NSTimeInterval)pause;

/// Resume the timer and return the time for which it was paused.  Returns 0 if timer was not paused.
- (NSTimeInterval)resume;

- (BOOL)isPaused;

/// \brief Set a "lap" marker and return the time since the last lap marker or start time if none.
- (NSTimeInterval)mark;

/// Time since the last mark or start time minus any paused time
- (NSTimeInterval)runningTimeSinceLastMark;

/// Excludes all paused time
- (NSTimeInterval)runningTimeSinceStart;




@end
