//
//  MCSimpleThread.m
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 29/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MPerformanceThread.h"
#include <hash_map.h>

/////////////////////////////////////////////////////////////////////////
#pragma mark - MPerformanceThread
/////////////////////////////////////////////////////////////////////////

@implementation MPerformanceThread
{
    MNSMutableObjectKeyDictionary *invocationIntervalDict;
    MNSMutableObjectKeyDictionary *invocationCallCountDict;
    NSMutableArray *invocationsToRemove;    ///< Temp hold invokes sent to removeInvocation to remove when run loop is finished

    MNSMutableObjectKeyDictionary *invocationsToAddIntervalDict;    ///< Expedites the ease of delayed adding via the run loop
    MNSMutableObjectKeyDictionary *invocationsToAddCallCountDict;

    BOOL runLoopCoreIsExecuting;     ///< Internal flag to determine whether pause stats have come into affect
    
    NSTimeInterval startTime;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
/////////////////////////////////////////////////////////////////////////


+ (id<MThreadProtocol>)thread
{
    return [[self alloc] init];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////


- (id)init 
{
    if (self = [super init]) {
        invocationIntervalDict = [MNSMutableObjectKeyDictionary dictionary];
        invocationCallCountDict = [MNSMutableObjectKeyDictionary dictionary];
        invocationsToAddIntervalDict = [MNSMutableObjectKeyDictionary dictionary];
        invocationsToAddCallCountDict = [MNSMutableObjectKeyDictionary dictionary];
        invocationsToRemove = [NSMutableArray array];
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - MCThreadProtocol API
/////////////////////////////////////////////////////////////////////////

- (void)addInvocation:(NSInvocation *)invocation desiredInterval:(NSTimeInterval)timeInterval
{
    // Prevent mutation errors with delayed adding
    // Note just because it's benn recently _paused doesn't mean the loop has finished its final iteration!
    if (self.isExecuting && (!self._paused || runLoopCoreIsExecuting)) {
        @synchronized(invocationsToAddIntervalDict) {
            [invocationsToAddIntervalDict setObject:[NSValue value:(void *)&timeInterval withObjCType:@encode(NSTimeInterval)] forKey:invocation];
            [invocationsToAddCallCountDict setObject:[NSNumber numberWithUnsignedInteger:0u] forKey:invocation];
            
        } 
    } else {
        @synchronized(invocationIntervalDict) {
            [invocationIntervalDict setObject:[NSValue value:(void *)&timeInterval withObjCType:@encode(NSTimeInterval)] forKey:invocation];
            
            // Init the call count to 0
            [invocationCallCountDict setObject:[NSNumber numberWithUnsignedInteger:0u] forKey:invocation];
        }
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)removeInvocation:(NSInvocation *)invocation
{
    // Remove directly if thread isn't _running.
    // Otherwise store to have the run loop handle it
    if (self.isExecuting && (!self._paused || runLoopCoreIsExecuting)) {
        @synchronized(invocationsToRemove) {
            [invocationsToRemove addObject:invocation];
        }
    } else {
        @synchronized(invocationIntervalDict) {
            [invocationIntervalDict removeObjectForKey:invocation];
            [invocationCallCountDict removeObjectForKey:invocation];
        }
    }
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Main Run Loop
/////////////////////////////////////////////////////////////////////////

- (void)main
{
    startTime = CACurrentMediaTime();

    while (!self.isCancelled) {
        // Paused?
        if (self._paused) {
            [[self class] sleepForTimeInterval:0.05];
            continue;
        }
        
        @autoreleasepool {
        
            runLoopCoreIsExecuting = YES;   // mark beginning of active run loop
            
            @synchronized(invocationIntervalDict) {
                
                /////////////////////////////////////////
                // LAZY ADD/REMOVE INVOCATIONS
                /////////////////////////////////////////

                // Remove any invocations which have been removed while in the run loop
                @synchronized(invocationsToRemove) {
                    if ([invocationsToRemove count]) {
                        [invocationCallCountDict removeObjectsForKeys:invocationsToRemove];
                        [invocationIntervalDict removeObjectsForKeys:invocationsToRemove];
                        [invocationsToRemove removeAllObjects];
                    }
                }            
                
                // Add any additional
                @synchronized(invocationsToAddIntervalDict) {
                    if ([invocationsToAddIntervalDict count]) {
                        [invocationIntervalDict addEntriesFromObjectKeyDictionary:invocationsToAddIntervalDict];
                        [invocationCallCountDict addEntriesFromObjectKeyDictionary:invocationsToAddCallCountDict];
                        [invocationsToAddIntervalDict removeAllObjects];
                        [invocationsToAddCallCountDict removeAllObjects];
                    }
                }
                
                /////////////////////////////////////////
                // PROCESSING
                /////////////////////////////////////////

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
                        
                        // Check that another thread hasn't added it for removal in the meantime as it may no longer exist as a method
                        @synchronized(invocationsToRemove) {
                            // Additional _paused check in case thread has been _paused during run loop
                            if (!self._paused && invoc && ![invocationsToRemove containsObject:invoc]) {
                                [invoc invoke];
                            }
                        }
                    }
                } // for
                
            } // synchro
            
            runLoopCoreIsExecuting = NO;        // mark end of the active (un_paused) run loop
            
        } // @autorelease
    } // while (run loop)
}

/////////////////////////////////////////////////////////////////////////

/// Resume if pause, otherwise call NSThread's start
- (void)start
{
    if (!_paused && _running) {
        [NSException raise:NSInternalInconsistencyException format:@"Start not allow on _running un_paused thread proxy."];
    }
    
    // Resume
    if (_paused) {
        self._paused = NO;       // property accessor to ensure thread safety
        return;
    }
    [super start];
    
    _running = YES;
}
/////////////////////////////////////////////////////////////////////////

- (void)pause
{
    self._paused = YES;              
}

/////////////////////////////////////////////////////////////////////////

- (void)cancel
{
    [super cancel];
    _running = NO;
}

@end
