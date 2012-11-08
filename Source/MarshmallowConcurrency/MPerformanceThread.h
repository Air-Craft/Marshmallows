/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 29/01/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file MPerformanceThread.h

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <tgmath.h>
#import "MThreadProtocol.h"



/**
 \brief A simple thread with a manual run loop for mega-efficient/time sensitive threading for background method calls (via NSInvocation).  Does NOT inherit from MCThreadProxyAbstract.
 
 \section UPDATE October 2012
 - Rewritten in C++ as the dictionaries' objectForKey: was the biggest expense.  Added time resolution to allow throttling as realtime is rarely needed and just hogs resources.
 
 \section dv DEV NOTES
 @synchro's only work if coming from separate threads, otherwise they are recursive.  This is an issue if an invocation's method, which is called on this thread, removes itself.  This would normally cause a mutation error but we've implemented delayed adding/removal.  The danger here, with removal at least, is that the method is destroyed between the loop start and the time it is invoked - like within a dealloc on another thread.  I think we've covered it with the additional synchro around the `invoke` which should work since a dealloc caused by the invocation method would not logically happen until the invocation's method has been invoc'ed (duh?). BUT it could still be a problem...maybe...
 */
@interface MPerformanceThread : NSThread <MThreadProtocol>

/// Setting is synonymous with calling [self pause] but used for convenient TS access
/// Be careful as the run loop will finish it's iteration before this takes affect
@property (atomic) BOOL paused;

/// YES after start and YES when paused.  NO prior to start and after cancel.
@property (nonatomic) BOOL running;

/** The time which the thread will pause between run loop iterations effectively setting the average deviation from the scheduled time which an invocation will be called.  Set to 0 to have maximum resolution at the cost of resources.  A good value is about 0.01 to 0.5 of the shortest interval expected to be used.  Defaults to 0.
 */
@property (atomic) NSTimeInterval timingResolution;

@end

/// @}