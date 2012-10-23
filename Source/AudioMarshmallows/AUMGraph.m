/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import "AUMGraph.h"
#import "AUMTypes.h"
#import "AUMUnitProtocol.h"
#import "Private/AUMErrorChecking.h"
#import "AUMException.h"

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
        _(NewAUGraph(&_graphRef), kAUMAudioUnitException, @"NewAUGraph() failed.");
        _(AUGraphOpen(_graphRef), kAUMAudioUnitException, @"AUGraphOpen() failed.");
        _(AUGraphInitialize(_graphRef), kAUMAudioUnitException, @"AUGraphInitialize() failed.");
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
    _(AUGraphIsInitialized(_graphRef, &result), kAUMAudioUnitException, @"AUGraphIsInitialized() failed");
    return (BOOL)result;
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)isRunning
{
    Boolean result;
    _(AUGraphIsRunning(_graphRef, &result), kAUMAudioUnitException, @"AUGraphIsRunning() failed");
    return (BOOL)result;
}

/////////////////////////////////////////////////////////////////////////

- (Float32)cpuLoad
{
    Float32 result;
    _(AUGraphGetCPULoad(_graphRef, &result), kAUMAudioUnitException, @"AUGraphGetCPULoad() failed");
    return result;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)printInfo
{
    CAShow(_graphRef);
}

/////////////////////////////////////////////////////////////////////////

- (void)addUnit:(id<AUMUnitProtocol>)anAUMUnit
{
    
    AUNode node;
    AudioUnit unit;
    AudioComponentDescription desc = anAUMUnit._audioComponentDescription;
    
    _(AUGraphAddNode(_graphRef, &desc, &node),
      kAUMAudioUnitException,
      @"Failed to add node %@", anAUMUnit);
    anAUMUnit._nodeRef = node;
    
    // Set the graph ref too
    anAUMUnit._graphRef = _graphRef;
    
    // Get the AudioUnit ref
    AudioComponentDescription desc2;
    _(AUGraphNodeInfo(_graphRef, node, &desc2, &unit), kAUMAudioUnitException, @"AUGraphNodeInfo() failed.");
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
    _(AUGraphRemoveNode(_graphRef, anAUMUnit._nodeRef), kAUMAudioUnitException, @"AUGraphRemoveNode() failed.");
}


/////////////////////////////////////////////////////////////////////////

- (void)connectOutputBus:(NSUInteger)anOutputBusNum
                  ofUnit:(id<AUMUnitProtocol>)anOutputUnit
              toInputBus:(NSUInteger)anInputBusNum
                  ofUnit:(id<AUMUnitProtocol>)anInputUnit
{
    [anInputUnit connectToInputBus:anInputBusNum AUMUnit:anOutputUnit outputBus:anOutputBusNum];
}

/////////////////////////////////////////////////////////////////////////

- (void)disconnectInputBus:(NSUInteger)aBusNum ofUnit:(id<AUMUnitProtocol>)aUnit
{
    _(AUGraphDisconnectNodeInput(_graphRef, aUnit._nodeRef, aBusNum),
      kAUMAudioUnitException,
      @"Failed to disconnect bus %i from %@", aBusNum, aUnit);
}

/////////////////////////////////////////////////////////////////////////

- (void)clearAllConnections
{
    _(AUGraphClearConnections(_graphRef), kAUMAudioUnitException, @"AUGraphClearConnections() failed.");
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)update
{
    Boolean result;
    _(AUGraphUpdate(_graphRef, &result), kAUMAudioUnitException, @"AUGraphUpdate() failed");
    
    return (BOOL)result;
}

/////////////////////////////////////////////////////////////////////////

- (void)initialize
{
    _(AUGraphInitialize(_graphRef), kAUMAudioUnitException, @"AUGraphInitialize() failed");
}

- (void)uninitialize
{
    _(AUGraphUninitialize(_graphRef), kAUMAudioUnitException, @"AUGraphUninitialize() failed");
}

- (void)start
{
    _(AUGraphStart(_graphRef), kAUMAudioUnitException, @"AUGraphStart() failed");
}

- (void)stop
{
    _(AUGraphStop(_graphRef), kAUMAudioUnitException, @"AUGraphStop() failed");
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}