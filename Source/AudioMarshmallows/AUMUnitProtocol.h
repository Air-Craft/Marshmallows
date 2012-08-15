/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012. All rights reserved.
 @{
 */
/// \file AUMUnitProtocol.h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


/** \brief Semi-private protocol for AUMUnits.  Used internally and for those wishing to make custom AUMUnits. Should be THREAD SAFE
 */
@protocol AUMUnitProtocol <NSObject>

@required

@property (atomic) AUGraph _graphRef;       ///< The containing graph
@property (atomic) AUNode _nodeRef;         ///< The node in the graph
@property (atomic) AudioUnit _audioUnitRef; ///< The audio unit opened from the graph

//@property (atomic, readonly) NSUInteger _inputBusCount;
//@property (atomic, readonly) NSUInteger _outputBusCount;
@property (atomic, readonly) AudioComponentDescription _audioComponentDescription;


/*@property (atomic) AUNode _nodeRef;
@property (atomic) AudioUnit *_audioUnitRef;
*/

@optional

/** Event notification called by AUMGraph when added to the graph.  At this point, _nodeReg and _audioUnitRef have been set */
- (void)_nodeWasAddedToGraph;


@end

/// @}