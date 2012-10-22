/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMProxyUnitAbstract.h"
#import "AUMTypes.h"


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

/////////////////////////////////////////////////////////////////////////

- (const AudioComponentDescription)_audioComponentDescription
{
    return _proxiedUnit._audioComponentDescription;
}

- (const NSInteger)maxInputBusNum { return _proxiedUnit.maxInputBusNum; }
- (const NSInteger)maxOutputBusNum { return _proxiedUnit.maxOutputBusNum; }

- (AudioStreamBasicDescription)defaultInputStreamFormat { return _proxiedUnit.defaultInputStreamFormat; }
- (AudioStreamBasicDescription)defaultOutputStreamFormat { return _proxiedUnit.defaultOutputStreamFormat; }
- (void)setDefaultInputStreamFormat:(AudioStreamBasicDescription)aFormat { _proxiedUnit.defaultInputStreamFormat = aFormat; }
- (void)setDefaultOutputStreamFormat:(AudioStreamBasicDescription)aFormat { _proxiedUnit.defaultOutputStreamFormat = aFormat; }


/////////////////////////////////////////////////////////////////////////

- (void)_nodeWasAddedToGraph
{
    [_proxiedUnit _nodeWasAddedToGraph];
}

/// @}


@end

/// @}