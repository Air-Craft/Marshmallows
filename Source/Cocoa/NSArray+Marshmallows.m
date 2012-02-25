//
//  NSArray+Marshmallows.m
//  SoundWand
//
//  Created by  on 24/02/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#import "NSArray+Marshmallows.h"

@implementation NSArray (Marshmallows)

- (void)unpackInto:(__strong id *)obj1, ...
{
    __strong id *idPtr;
    va_list args;
    va_start(args, obj1);

    idPtr = obj1;
    NSUInteger idx = 0;
    NSUInteger count = [self count];
    while (idPtr != NULL && idx < count) {
        *idPtr = [self objectAtIndex:idx];
        
        // Increment the args and idx count
        idx++;
        idPtr = va_arg(args, __strong id *);
    }
}

@end
