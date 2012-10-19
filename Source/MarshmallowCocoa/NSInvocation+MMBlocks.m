/**
 \addtogroup Marshmallows
 \author     Jonathan 'Wolf' Rentzsch, 2010 - http://github.com/rentzsch/NSInvocation-blocks.  Modified by Hari Karam Singh 2012
 \copyright  Copyright (c) 2010 Jonathan 'Wolf' Rentzsch: http://rentzsch.com. With Portions Copyright 2012 Club 15CC. License: http://opensource.org/licenses/mit-license.php.
 
 @{
 */

#import "NSInvocation+MMBlocks.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - MMInvocationGrabber
/////////////////////////////////////////////////////////////////////////

@interface MMInvocationGrabber : NSProxy {
    id _target;
}
@property (nonatomic, strong) NSInvocation *invocation;
@end

@implementation MMInvocationGrabber

- (id)initWithTarget:(id)aTarget {
    _target = aTarget;
    return self;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector {
    return [_target methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation*)anInvocation {
    [anInvocation setTarget:_target];
    _invocation = anInvocation;
}

@end


/////////////////////////////////////////////////////////////////////////
#pragma mark - NSInvocation (Blocks)
/////////////////////////////////////////////////////////////////////////

@implementation NSInvocation (MMBlocks)

+ (id)mm_invocationWithTarget:(id)aTarget block:(void (^)(id target))aBlock {
    MMInvocationGrabber *grabber = [[MMInvocationGrabber alloc] initWithTarget:aTarget];
    aBlock(grabber);
    return grabber.invocation;
}


@end

/// @}