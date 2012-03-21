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
 */
@interface MCSimpleThreadProxy : NSThread <MCThreadProxyProtocol>
{
    MNSMutableObjectKeyDictionary *invocationIntervalDict;
    MNSMutableObjectKeyDictionary *invocationCallCountDict;
    NSTimeInterval startTime;
}

/// Setting is synonymous with calling [self pause] but used for convenient TS access
@property (atomic) BOOL paused;

/// YES after start and YES when paused.  NO prior to start and after cancel.
@property (nonatomic) BOOL running;

@end
