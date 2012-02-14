//
//  MCMainThreadProxy.h
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 29/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCThreadProxyAbstract.h"
#import "MNSMutableObjectKeyDictionary.h"

@interface MCMainThreadProxy : MCThreadProxyAbstract 
{
    MNSMutableObjectKeyDictionary *invocationTimerDict;
}

@end
