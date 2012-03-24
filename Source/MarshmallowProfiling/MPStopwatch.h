/** 
 \ingroup    SoundWand
 
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

/// Starts the timer as well.
- (id)init;

/// \brief Pauses timer, excluding this time period from reported durations. Returns the time since start or last pause or 0 is already paused
- (NSTimeInterval)pause;

/// Resume the timer and return the time for which it was paused.  Returns 0 if timer was not paused.
- (NSTimeInterval)resume;

- (BOOL)isPaused;

/// \brief Set a "lap" marker and return the time since the last lap marker or start time if none.
/// \throws NSInvalidArgumentException if timer doesn't exist
- (NSTimeInterval)mark;

/// Time since the last mark or start time minus any paused time
- (NSTimeInterval)runningTimeSinceLastMark;

/// Excludes all paused time
- (NSTimeInterval)runningTimeSinceStart;




@end
