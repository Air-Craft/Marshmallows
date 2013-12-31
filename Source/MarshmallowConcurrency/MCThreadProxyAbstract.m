//
//  MCMainThreadProxy.m
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 29/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCThreadProxyAbstract.h"

@implementation MCThreadProxyAbstract

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Init

+ (id<MThreadProtocol>)thread
{
    return [[self alloc] init];
}

/////////////////////////////////////////////////////////////////////////

- (id)init 
{
    if (self = [super init]) {
        invocationIntervalDict = [MWeakKeyMutableDictionary dictionary];
    }
    return self;
    
}

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark MCThreadProtocol API

- (void)addInvocation:(NSInvocation *)invocation desiredInterval:(NSTimeInterval)timeInterval
{
    @synchronized(invocationIntervalDict) {
        [invocationIntervalDict setObject:[NSValue value:(void *)&timeInterval withObjCType:@encode(NSTimeInterval)]forKey:invocation];
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)removeInvocation:(NSInvocation *)invocation
{
    @synchronized(invocationIntervalDict) {
        [invocationIntervalDict removeObjectForKey:invocation];
    }
}

/////////////////////////////////////////////////////////////////////////

/// @abstract
- (void)start { [NSException raise:NSDestinationInvalidException format:@"Must be overridden in subclass."]; }

/////////////////////////////////////////////////////////////////////////

/// @abstract
- (void)cancel { [NSException raise:NSDestinationInvalidException format:@"Must be overridden in subclass."]; }

/////////////////////////////////////////////////////////////////////////

/// @abstract
- (void)pause { [NSException raise:NSDestinationInvalidException format:@"Must be overridden in subclass."]; }

@end
