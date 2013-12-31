//
//  MCMainThreadProxy.m
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 29/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCMainThreadProxy.h"

@implementation MCMainThreadProxy

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Lifecycle

/// Setup up our invoc-timer lookup dict
- (id)init 
{
    if (self = [super init]) {
        invocationTimerDict = [MWeakKeyMutableDictionary dictionary];
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////

/// Clear any latent timers
- (void)dealloc
{
    for (id key in invocationTimerDict) {
        [[invocationTimerDict objectForKey:key] invalidate];
        [invocationTimerDict removeObjectForKey:key];
    }
}


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Public API

/// Stop and remove any timers for the invocation
- (void)removeInvocation:(NSInvocation *)invocation
{
    @synchronized(invocationIntervalDict) {
        NSTimer *timer = [invocationTimerDict objectForKey:invocation];
        if (timer) {
            [timer invalidate];
            [invocationTimerDict removeObjectForKey:invocation];
        }
        [super removeInvocation:invocation];
    }
}

/////////////////////////////////////////////////////////////////////////

/// Schedule timers on the main thread for the invocations
- (void)start
{   
    //MCLOG("MCMainThreadProxy starting...");
    @synchronized(invocationIntervalDict) {
        for (NSInvocation *invoc in invocationIntervalDict) {
            
            // Get the interval value 
            NSTimeInterval ti;
            [(NSValue *)[invocationIntervalDict objectForKey:invoc] getValue:&ti];
            
            NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:ti invocation:invoc repeats:YES];
            [invocationTimerDict setObject:t forKey:invoc];
        }
    }
}

/////////////////////////////////////////////////////////////////////////

/// Stop by invalidating and dealloc'ing all the timers
- (void)cancel
{
    @synchronized(invocationIntervalDict) {
        //MCLOG("MCMainThreadProxy ending...");
        for (id key in invocationTimerDict) {
            [[invocationTimerDict objectForKey:key] invalidate];
            [invocationTimerDict removeObjectForKey:key];
        }
    }
}

/////////////////////////////////////////////////////////////////////////

/// Just cancel as I don't think you can pause a time and 
/// its pretty low overhead re-creating them anyway
- (void)pause
{
    [self cancel];
}



@end
