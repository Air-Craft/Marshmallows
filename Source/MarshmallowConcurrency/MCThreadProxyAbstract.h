//
//  MCMainThreadProxy.h
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 29/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MThreadProtocol.h"
#import "MWeakKeyMutableDictionary.h"

@interface MCThreadProxyAbstract : NSObject <MThreadProtocol> 
{
    MWeakKeyMutableDictionary *invocationIntervalDict;
}

@end
