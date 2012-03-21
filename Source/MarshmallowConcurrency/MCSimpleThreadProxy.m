//
//  MCSimpleThread.m
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 29/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCSimpleThreadProxy.h"

@implementation MCSimpleThreadProxy

@synthesize paused, running;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Class Methods

+ (id<MCThreadProxyProtocol>)thread
{
    return [[self alloc] init];
}

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Life Cycle

- (id)init 
{
    if (self = [super init]) {
        invocationIntervalDict = [MNSMutableObjectKeyDictionary dictionary];
        invocationCallCountDict = [MNSMutableObjectKeyDictionary dictionary];
    }
    return self;
}

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark MCThreadProtocol API

- (void)addInvocation:(NSInvocation *)invocation desiredInterval:(NSTimeInterval)timeInterval
{
    @synchronized(invocationIntervalDict) {

        [invocationIntervalDict setObject:[NSValue value:(void *)&timeInterval withObjCType:@encode(NSTimeInterval)] forKey:invocation];
        
        // Init the call count to 0
        [invocationCallCountDict setObject:[NSNumber numberWithUnsignedInteger:0u] forKey:invocation];
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)removeInvocation:(NSInvocation *)invocation
{
    // Remove directly if thread isn't running.
    // Otherwise store to have the run loop handle it
    if (self.isCancelled || self.paused) {
        @synchronized(invocationIntervalDict) {
            [invocationIntervalDict removeObjectForKey:invocation];
            [invocationCallCountDict removeObjectForKey:invocation];
        }
    } else {
        @synchronized(invocationsToRemove) {
            [invocationsToRemove addObject:invocation];
        }
    }
}


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Main Loop

- (void)main
{
    startTime = CACurrentMediaTime();

    while (!self.isCancelled) {
        // Paused?
        if (self.paused) {
            [[self class] sleepForTimeInterval:0.05];
            continue;
        }
        
        @autoreleasepool {
            
            // Loop through the invocations and call if time interval has lapsed
            @synchronized(invocationIntervalDict) {

                for (NSInvocation *invoc in invocationIntervalDict) {
                    
                    NSUInteger prevCallCount = [[invocationCallCountDict objectForKey:invoc] unsignedIntegerValue];
                    NSTimeInterval interval;
                    [[invocationIntervalDict objectForKey:invoc] getValue:&interval];
                    
                    NSTimeInterval nowTime = CACurrentMediaTime();
                    NSUInteger currInterval = floor((nowTime - startTime) / interval);
                    
                    if ( currInterval > prevCallCount ) {
                        // Update the call count dict.
                        // Currently skips any dropped intervals.  Change to prevCallCount++ 
                        // to have a "catch up" paradigm
                        [invocationCallCountDict setObject:[NSNumber numberWithUnsignedInteger:currInterval] forKey:invoc];
                        
                        [invoc invoke];
                    }
                } // for
                
                // Remove any invocations which have been removed while in the run loop
                @synchronized(invocationsToRemove) {
                    [invocationCallCountDict removeObjectsForKeys:invocationsToRemove];
                    [invocationIntervalDict removeObjectsForKeys:invocationsToRemove];
                    [invocationsToRemove removeAllObjects];
                }            
            } // synchro
        } // @autorelease
    } // while (run loop)
}

/////////////////////////////////////////////////////////////////////////

/// Resume if pause, otherwise call NSThread's start
- (void)start
{
    NSAssert(paused || !running, @"Start not allow on running unpaused thread proxy.");
             
    // Resume
    if (paused) {
        self.paused = NO;       // property accessor to ensure thread safety
        return;
    }
    [super start];
    
    running = YES;
}
/////////////////////////////////////////////////////////////////////////

- (void)pause
{
    self.paused = YES;      
}

/////////////////////////////////////////////////////////////////////////

- (void)cancel
{
    [super cancel];
    running = NO;
}

@end
