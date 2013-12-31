//
//  NSDate+Marshmallows.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 05/07/2013.
//
//

#import "NSDate+Marshmallows.h"

@implementation NSDate (Marshmallows)

/////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
/////////////////////////////////////////////////////////////////////////

+ (NSInteger)currentHour
{
    return NSDate.date.hour;
}

//---------------------------------------------------------------------

+ (NSInteger)currentMinute
{
    return NSDate.date.minute;
}

//---------------------------------------------------------------------

+ (NSInteger)currentSecond
{
    return NSDate.date.second;
}

//---------------------------------------------------------------------

+ (NSString *)currentTimeOfDay
{
    return NSDate.date.timeOfDay;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Instance Methods
/////////////////////////////////////////////////////////////////////////

- (NSInteger)hour
{
    return [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:self].hour;
}

//---------------------------------------------------------------------

- (NSInteger)minute
{
    return [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:self].minute;
}


//---------------------------------------------------------------------

- (NSInteger)second
{
    return [[NSCalendar currentCalendar] components:NSSecondCalendarUnit fromDate:self].second;
}

//---------------------------------------------------------------------

/**
 Return the time of day as string with the algorithm as follows:
 6 - 11 Morning
 11 - 14 Midday
 14 - 17 Afternoon
 17 - 20 Evening
 20 - 23 Night
 23 - 4 Late Night
 4 - 6 Early Morning
 */
- (NSString *)timeOfDay
{
    NSInteger hour = [[self class] currentHour];
//    NSInteger minute = [[self class] currentMinute];
    
    if (hour >= 4 && hour < 6)  return NSLocalizedString(@"Early Morning", nil);
    else if (hour >= 6 && hour < 11)        return NSLocalizedString(@"Morning", nil);
    else if (hour >= 11 && hour < 14)  return NSLocalizedString(@"Midday", nil);
    else if (hour >= 14 && hour < 17)  return NSLocalizedString(@"Afternoon", nil);
    else if (hour >= 17 && hour < 20)  return NSLocalizedString(@"Evening", nil);
    else if (hour >= 20 && hour < 23)  return NSLocalizedString(@"Night", nil);
    else if (hour >= 23 || hour < 4)   return NSLocalizedString(@"Late Night", nil);
    else [NSException raise:NSInternalInconsistencyException format:@"Hour out of bounds for date: %i", hour];
    return nil;
}


@end
