/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */
/// \file AUMGraph.h
 
 
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AUMUnitProtocol.h"

/**
 \brief 
 
 \section aumg_err Error handling
 Most if not all methods potentially throws and exception with value kAUMException and 
 and underlying userInfo with the OSStatus as an NSNumber in the kAUMOSStatusCodeKey key.
 
 \todo Protocol method for when unit is removed from graph?
 */
@interface AUMGraph : NSObject
{
@protected
    AUGraph _graphRef;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

@property (atomic, readonly) BOOL isInitialized;
@property (atomic, readonly) BOOL isRunning;
@property (atomic, readonly) Float32 cpuLoad;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

/** Calls CAShow on the underlying graph to get some info */
- (void)printInfo;

/** Add the AUMUnit to the graph. Sets the AUMUnit's _nodeRef and _audioUnitRef properties and cals the _nodeWasAddedToGraph method if defined.  Retains the AUMUnit so no need to keep a ref if you dont want to.
 
    \throws kAUMAudioUnitException
 */
- (void)addUnit:(id<AUMUnitProtocol>)anAUMUnit;

/** Remove the unit and its corresponding node from the graph.  Does NOT clear AUMUnit's _nodeRef or _audioUnitRef properties */
- (void)removeUnit:(id<AUMUnitProtocol>)anAUMUnit;

/////////////////////////////////////////////////////////////////////////

/** Connect two arbitrary busses of two AUMUnits.  If the graph has been init'ed you'll need to call 'update' too (when done changing connections).
 \throws NSRangeException on bus number exceeds possible range
 \throws NSInternalInconsistencyException if both units are not added to the same graph prior to call
 \throws kAUMAudioUnitException on any Core Audio errors
 */
- (void)connectOutputBus:(NSUInteger)anOutputBusNum
                  ofUnit:(id<AUMUnitProtocol>)anOutputUnit
              toInputBus:(NSUInteger)anInputBusNum
                  ofUnit:(id<AUMUnitProtocol>)anInputUnit;

/** Disconnect a node's input. If the graph has been init'ed you'll need to call 'update' too (when done changing connections).
 \throws kAUMGraphException
 */
- (void)disconnectInputBus:(NSUInteger)aBusNum ofUnit:(id<AUMUnitProtocol>)aUnit;

/** Disconnect all connections.  If the graph has been init'ed you'll need to call 'update' too (when done changing connections).
 \throws kAUMGraphException
 */
- (void)clearAllConnections;

/** Attempts to update the graph asynch
    \return Returns the boolean result indicating whether the changes took effect immediately (or will queue for later?)
 */
- (BOOL)update;

/////////////////////////////////////////////////////////////////////////

/** @name These call the associated AUGraph method, throwing an exception if error 
    \throws kAUMGraphException
 */
- (void)initialize;
- (void)uninitialize;
- (void)start;
- (void)stop;
/// @}

@end

/// @}