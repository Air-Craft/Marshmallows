//
//  NSTimer+Blocks.m
//
//  Created by Jiva DeVoe on 1/14/11.
//  Copyright 2011 Random Ideas, LLC. All rights reserved.
//

#import "NSTimer+MMBlocks.h"

@implementation NSTimer (MMBlocks)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void (^)(void))aBlock repeats:(BOOL)doesRepeat
{
    return [self scheduledTimerWithTimeInterval:ti target:self selector:@selector(_executeBlock:) userInfo:[aBlock copy] repeats:doesRepeat];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti block:(void (^)(void))aBlock repeats:(BOOL)doesRepeat
{
    return [self timerWithTimeInterval:ti target:self selector:@selector(_executeBlock:) userInfo:[aBlock copy] repeats:doesRepeat];
}

+(void)_executeBlock:(NSTimer *)inTimer;
{
    if([inTimer userInfo])
    {
        void (^block)() = (void (^)())[inTimer userInfo];
        block();
    }
}

@end
