//
//  MCMainThreadProxy.h
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 29/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCThreadProxyAbstract.h"
#import "MWeakKeyMutableDictionary.h"

/**
 \brief Uses NSTimer's to run task on the main thread
 
 \todo Must be run from the main thread at the moment.  Should fix this really.
 \todo Adding a new invocation to create a new timer if started
 */
@interface MCMainThreadProxy : MCThreadProxyAbstract 
{
    MWeakKeyMutableDictionary *invocationTimerDict;
}

@end
