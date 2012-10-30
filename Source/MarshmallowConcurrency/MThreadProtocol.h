//
//  MCThreadProtocol.h
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 29/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MThreadProtocol <NSObject>

+ (id<MThreadProtocol>)thread;

- (void)addInvocation:(NSInvocation *)invocation desiredInterval:(NSTimeInterval)timeInterval;

- (void)removeInvocation:(NSInvocation *)invocation;

/**
 Starts the thread proxy.  Also should resume when paused.
 */
- (void)start;

/**
 Cancel and break down the thread
 */
- (void)cancel;

/**
 Pause execution of the thread.  Resume with [start].
 */
- (void)pause;

@end
