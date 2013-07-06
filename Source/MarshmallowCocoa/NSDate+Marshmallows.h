//
//  NSDate+Marshmallows.h
//  Marshmallows
//
//  Created by Hari Karam Singh on 05/07/2013.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (Marshmallows)

/////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
/////////////////////////////////////////////////////////////////////////

/// Current hour based on the current calendar
+ (NSInteger)currentHour;

/// Current minute based on the current calendar
+ (NSInteger)currentMinute;

/// Current minute based on the current calendar
+ (NSInteger)currentSecond;

/// Returns time of day for current time
/// @see timeOfDay
+ (NSString *)currentTimeOfDay;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Instance Methods
/////////////////////////////////////////////////////////////////////////

/// Shortcut to get the date's hour in the current calendar
- (NSInteger)hour;

/// Shortcut to get the date's minute in the current calendar
- (NSInteger)minute;

/// Shortcut to get the date's second in the current calendar
- (NSInteger)second;



/**
 Return the time of day as string with the algorithm as follows:
 6 - 11 Morning
 11 - 2 Midday
 2 - 5 Afternoon
 5 - 8 Evening
 8 - 11 Night
 11 - 4 Late Night
 4 - 6 Early Morning
 */
- (NSString *)timeOfDay;

/// one day maybe...
//- (NSString *)timeOfDayWithCustomIntervals:(NSDictionary *)customIntervals;



@end
