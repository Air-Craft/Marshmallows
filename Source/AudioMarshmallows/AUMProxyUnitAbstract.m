/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMProxyUnitAbstract.h"



/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMProxyUnitAbstract
/////////////////////////////////////////////////////////////////////////

@implementation AUMProxyUnitAbstract

/** \abstract */
- (id)init
{
    self = [super init];
    if (self) {
        [NSException raise:NSInternalInconsistencyException format:@"Init is abstract must be overriden and must set _proxiedUnit to an AUMUnit instance"];
        return nil;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMUnitProtocol Fulfillment
/////////////////////////////////////////////////////////////////////////
/** @name  AUMUnitProtocol Fulfillment
 Proxy properties and methods to the underlying unit
 */

- (AUGraph)_graphRef {  return _proxiedUnit._graphRef; }
- (AUNode)_nodeRef {  return _proxiedUnit._nodeRef; }
- (AudioUnit)_audioUnitRef {  return _proxiedUnit._audioUnitRef; }

- (void)_setGraphRef:(AUGraph)_graphRef { _proxiedUnit._graphRef = _graphRef; }
- (void)_setNodeRef:(AUNode)_nodeRef { _proxiedUnit._nodeRef = _nodeRef; }
- (void)_setAudioUnitRef:(AudioUnit)_audioUnitRef { _proxiedUnit._audioUnitRef = _audioUnitRef; }

- (AudioComponentDescription)_audioComponentDescription
{
    return _proxiedUnit._audioComponentDescription;
}

- (void)_nodeWasAddedToGraph
{
    [_proxiedUnit _nodeWasAddedToGraph];
}

/// @}


@end

/// @}