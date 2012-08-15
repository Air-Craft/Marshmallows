/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import "AUMGraph.h"
#import "AUMTypes.h"
#import "AUMUnitProtocol.h"
#import "AUMErrorChecking.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMGraph
/////////////////////////////////////////////////////////////////////////



@implementation AUMGraph


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

/**
 \throws kAUMAudioGraphException
 */
- (id)init
{
    if (self = [super init]) {
        _(NewAUGraph(&_graphRef), @"NewAUGraph() failed.");
        _(AUGraphOpen(_graphRef), @"AUGraphOpen() failed.");
        _(AUGraphInitialize(_graphRef), @"AUGraphInitialize() failed.");
    }
    return self;
}

/** Dispose of the graph.  No error checking */
- (void)dealloc
{
    // Skip error checking here (?)
    DisposeAUGraph(_graphRef);
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Accessor Methods
/////////////////////////////////////////////////////////////////////////

- (BOOL)isInitialized
{
    Boolean result;
    _(AUGraphIsInitialized(_graphRef, &result), @"AUGraphIsInitialized() failed");
    return (BOOL)result;
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)isRunning
{
    Boolean result;
    _(AUGraphIsRunning(_graphRef, &result), @"AUGraphIsRunning() failed");
    return (BOOL)result;
}

/////////////////////////////////////////////////////////////////////////

- (Float32)cpuLoad
{
    Float32 result;
    _(AUGraphGetCPULoad(_graphRef, &result), @"AUGraphGetCPULoad() failed");
    return result;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)addUnit:(id<AUMUnitProtocol>)anAUMUnit
{
    
    AUNode node;
    AudioUnit unit;
    AudioComponentDescription desc = anAUMUnit._audioComponentDescription;
    
    _(AUGraphAddNode(_graphRef, &desc, &node), [NSString stringWithFormat:@"Failed to add node %@", anAUMUnit]);
    anAUMUnit._nodeRef = node;
    
    // Set the graph ref too
    anAUMUnit._graphRef = _graphRef;
    
    // Get the AudioUnit ref
    AudioComponentDescription desc2;
    _(AUGraphNodeInfo(_graphRef, node, &desc2, &unit), @"AUGraphNodeInfo() failed.");
    anAUMUnit._audioUnitRef = unit;
    
    // Notify the Unit so it can do any additional setup required
    SEL call = @selector(_nodeWasAddedToGraph);
    if ([anAUMUnit respondsToSelector:call]) {
        [anAUMUnit _nodeWasAddedToGraph];
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)removeUnit:(id<AUMUnitProtocol>)anAUMUnit
{
    _(AUGraphRemoveNode(_graphRef, anAUMUnit._nodeRef), @"AUGraphRemoveNode() failed.");
}

/////////////////////////////////////////////////////////////////////////

- (void)connectOutputBus:(NSUInteger)anOutputBusNum ofUnit:(id<AUMUnitProtocol>)anOutputUnit toInputBus:(NSUInteger)anInputBusNum ofUnit:(id<AUMUnitProtocol>)anInputUnit
{
    _(AUGraphConnectNodeInput(
                              _graphRef,
                              anOutputUnit._nodeRef,
                              anOutputBusNum,
                              anInputUnit._nodeRef,
                              anInputBusNum
                              ),
      [NSString stringWithFormat:@"Failed to connect output bus %i of %@ to input bus %i of %@", anOutputBusNum, anOutputUnit, anInputBusNum, anInputUnit]);
    
    // DONT UPDATE:  Let the user do it in case they wish to make multiple changes
    ///if (self.isInitialized) {
    //    [self update];
    //}
}

/////////////////////////////////////////////////////////////////////////

- (void)connectOutputBus:(NSUInteger)anOutputBusNum
                  ofUnit:(id<AUMUnitProtocol>)anOutputUnit
              toInputBus:(NSUInteger)anInputBusNum
                  ofUnit:(id<AUMUnitProtocol>)anInputUnit
  withSharedStreamFormat:(AudioStreamBasicDescription)aSharedStreamFormat
{
    // Set the input unit's bus's format
    _(AudioUnitSetProperty(anInputUnit._audioUnitRef,
                           kAudioUnitProperty_StreamFormat,
                           kAudioUnitScope_Input,
                           anInputBusNum,
                           &aSharedStreamFormat,
                           sizeof(aSharedStreamFormat)),
      [NSString stringWithFormat:@"Failed to set stream format on input bus %i of %@", anInputBusNum, anInputUnit]);

    // Set the output unit's bus's format
    _(AudioUnitSetProperty(anOutputUnit._audioUnitRef,
                           kAudioUnitProperty_StreamFormat,
                           kAudioUnitScope_Output,
                           anOutputBusNum,
                           &aSharedStreamFormat,
                           sizeof(aSharedStreamFormat)),
      [NSString stringWithFormat:@"Failed to set stream format on output bus %i of %@", anOutputBusNum, anOutputUnit]);

    // Call the straight connect method
    [self connectOutputBus:anOutputBusNum ofUnit:anOutputUnit toInputBus:anInputBusNum ofUnit:anInputUnit];
}

/////////////////////////////////////////////////////////////////////////

- (void)disconnectInputBus:(NSUInteger)aBusNum ofUnit:(id<AUMUnitProtocol>)aUnit
{
    _(AUGraphDisconnectNodeInput(_graphRef, aUnit._nodeRef, aBusNum), [NSString stringWithFormat:@"Failed to disconnect bus %i from %@", aBusNum, aUnit]);
}

/////////////////////////////////////////////////////////////////////////

- (void)clearAllConnections
{
    _(AUGraphClearConnections(_graphRef), @"AUGraphClearConnections() failed.");
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)update
{
    Boolean result;
    _(AUGraphUpdate(_graphRef, &result), @"AUGraphUpdate() failed");
    
    return (BOOL)result;
}

/////////////////////////////////////////////////////////////////////////

- (void)initialize
{
    _(AUGraphInitialize(_graphRef), @"AUGraphInitialize() failed");
}

- (void)uninitialize
{
    _(AUGraphUninitialize(_graphRef), @"AUGraphUninitialize() failed");
}

- (void)start
{
    _(AUGraphStart(_graphRef), @"AUGraphStart() failed");
}

- (void)stop
{
    _(AUGraphStop(_graphRef), @"AUGraphStop() failed");
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}