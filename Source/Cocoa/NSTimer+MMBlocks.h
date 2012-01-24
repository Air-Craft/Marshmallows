//
//  NSTimer+Blocks.h
//
//  Created by Jiva DeVoe on 1/14/11.
//  Copyright 2011 Random Ideas, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (MMBlocks)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void (^)(void))aBlock repeats:(BOOL)doesRepeat;

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti block:(void (^)(void))aBlock repeats:(BOOL)doesRepeat;

@end
