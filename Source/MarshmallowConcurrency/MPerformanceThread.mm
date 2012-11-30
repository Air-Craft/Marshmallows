/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 29/01/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */


#import "MPerformanceThread.h"
#include <unordered_map>        // same as hash_map
#include <unordered_set>


/////////////////////////////////////////////////////////////////////////
#pragma mark - Types
/////////////////////////////////////////////////////////////////////////

typedef struct {
    NSTimeInterval interval;
    NSUInteger callCount;
} _MPerformanceThreadInvocParams;


/// Custom hasher & equals for NSInvocation
struct _MPerformanceThreadMapHash {
    size_t operator()(const NSInvocation *s1) const { return (size_t)s1; }
};
struct _MPerformanceThreadMapEqual {
    size_t operator()(const NSInvocation *a, const NSInvocation *b) const { return a==b; }
};


/////////////////////////////////////////////////////////////////////////
#pragma mark - MPerformanceThread
/////////////////////////////////////////////////////////////////////////

@implementation MPerformanceThread
{
    std::unordered_map<NSInvocation *, _MPerformanceThreadInvocParams, _MPerformanceThreadMapHash, _MPerformanceThreadMapEqual>_invocationsDict; ///< The time repeat interval which to call the methods.  One of these needs to be retains to why not this one
    
    std::unordered_map<NSInvocation *, NSTimeInterval, _MPerformanceThreadMapHash, _MPerformanceThreadMapEqual>_invocationsToAddDict;
    
    std::unordered_set<NSInvocation *, _MPerformanceThreadMapHash> _invocationsToRemoveSet; ///< Temp hold invokes sent to removeInvocation to remove when run loop is finished

    /// ObjC mutex locks for @synchro
    id _invocationsDictMutex;
    id _invocationsToAddDictMutex;
    id _invocationsToRemoveSetMutex;

    
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


/////////////////////////////////////////////////////////////////////////
#pragma mark - MCThreadProtocol API
/////////////////////////////////////////////////////////////////////////

- (void)addInvocation:(NSInvocation *)invocation desiredInterval:(NSTimeInterval)timeInterval
{
    // Prevent mutation errors with delayed adding
    // Note just because it's benn recently _paused doesn't mean the loop has finished its final iteration!
    
    if (self.isExecuting && (!self.paused || runLoopCoreIsExecuting)) {
        // If running then queue to add via the run loop
        @synchronized(_invocationsToAddDictMutex) {
            
            _invocationsToAddDict[invocation] = timeInterval;
            
        }
        
    } else {
        
        // Else add now...
        @synchronized(_invocationsDictMutex) {
            _MPerformanceThreadInvocParams tmp = {0};
            tmp.interval = timeInterval;
            tmp.callCount = 0;
            _invocationsDict[invocation] = tmp;
        }
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)removeInvocation:(NSInvocation *)invocation
{
    // Remove directly if thread isn't _running.
    // Otherwise store to have the run loop handle it
    if (self.isExecuting && (!self.paused || runLoopCoreIsExecuting)) {
        @synchronized(_invocationsToRemoveSetMutex) {
            _invocationsToRemoveSet.insert(invocation);
        }
    } else {
        @synchronized(_invocationsDictMutex) {
            _invocationsDict.erase(invocation);
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
        if (self.paused) {
            [[self class] sleepForTimeInterval:0.05];
            continue;
        }
        
        @autoreleasepool {
            runLoopCoreIsExecuting = YES;   // mark beginning of active run loop
            
            @synchronized(_invocationsDictMutex) {
                
                /////////////////////////////////////////
                // LAZY ADD/REMOVE INVOCATIONS
                /////////////////////////////////////////

                // Remove any invocations which have been removed while in the run loop
                @synchronized(_invocationsToRemoveSetMutex) {
                    if (not _invocationsToRemoveSet.empty()) {
                        for (const auto& invoc :_invocationsToRemoveSet) {
                            _invocationsDict.erase(invoc);
                        }
                        _invocationsToRemoveSet.clear();
                    }
                }            
                
                // Add any additional
                @synchronized(_invocationsToAddDictMutex) {
                    if (not _invocationsToAddDict.empty()) {
                        for (const auto& entry: _invocationsToAddDict) {
                            _MPerformanceThreadInvocParams tmp = {0};
                            tmp.interval = entry.second;
                            tmp.callCount = 0;
                            _invocationsDict[entry.first] = tmp;
                        }
                        
                        _invocationsToAddDict.clear();
                    }
                }
                
                /////////////////////////////////////////
                // PROCESSING
                /////////////////////////////////////////

                for (auto& entry: _invocationsDict) {
                    NSInvocation *invoc = entry.first;
                    NSUInteger prevCallCount = entry.second.callCount;
                    NSTimeInterval interval = entry.second.interval;
                    
                    NSTimeInterval nowTime = CACurrentMediaTime();
                    NSUInteger currInterval = floor((nowTime - startTime) / interval);
                    
                    if ( currInterval > prevCallCount ) {
                        // Update the call count dict.
                        // Currently skips any dropped intervals.  Change to prevCallCount++ 
                        // to have a "catch up" paradigm
                        entry.second.callCount = currInterval;
                        
                        // Check that another thread hasn't added it for removal in the meantime as it may no longer exist as a method
                        @synchronized(_invocationsToRemoveSetMutex) {
                            // Additional _paused check in case thread has been _paused during run loop
                            if (not self.paused and invoc and not _invocationsToRemoveSet.count(invoc)) {
                                    [invoc invoke];

                            }
                        }
                    }
                } // for
                
            } // synchro
            
            runLoopCoreIsExecuting = NO;        // mark end of the active (un_paused) run loop
            
            if (_timingResolution) {
                [[self class] sleepForTimeInterval:_timingResolution];
            }
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
        self.paused = NO;       // property accessor to ensure thread safety
        return;
    }
    [super start];
    
    _running = YES;
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
    _running = NO;
}

@end

/// @}