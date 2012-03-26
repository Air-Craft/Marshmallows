//
//  MCSimpleThreadProxy.h
/// \ingroup Marshmallows
//
//  Created by Hari Karam Singh on 29/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <tgmath.h>
#import "MCThreadProxyProtocol.h"
#import "MNSMutableObjectKeyDictionary.h"


/**
 \brief A simple thread with a manual run loop.  Does NOT inherit from MCThreadProxyAbstract.
 
 \section dv DEV NOTES
 @synchro's only work if coming from separate threads, otherwise they are recursive.  This is an issue if an invocation's method, which is called on this thread, removes itself.  This would normally cause a mutation error but we've implemented delayed adding/removal.  The danger here, with removal at least, is that the method is destroyed between the loop start and the time it is invoked - like within a dealloc on another thread.  I think we've covered it with the additional synchro around the `invoke` which should work since a dealloc caused by the invocation method would not logically happen until the invocation's method has been invoc'ed (duh?). BUT it could still be a problem...maybe...
 */
@interface MCSimpleThreadProxy : NSThread <MCThreadProxyProtocol>
{
    MNSMutableObjectKeyDictionary *invocationIntervalDict;
    MNSMutableObjectKeyDictionary *invocationCallCountDict;
    NSMutableArray *invocationsToRemove;    ///< Temp hold invokes sent to removeInvocation to remove when run loop is finished

    MNSMutableObjectKeyDictionary *invocationsToAddIntervalDict;    ///< Expedites the ease of delayed adding via the run loop
    MNSMutableObjectKeyDictionary *invocationsToAddCallCountDict;
    
    BOOL runLoopCoreIsExecuting;     ///< Internal flag to determine whether pause stats have come into affect yet
    
    NSTimeInterval startTime;
}

/// Setting is synonymous with calling [self pause] but used for convenient TS access
/// Be careful as the run loop will finish it's iteration before this takes affect
@property (atomic) BOOL paused;

/// YES after start and YES when paused.  NO prior to start and after cancel.
@property (nonatomic) BOOL running;

@end
