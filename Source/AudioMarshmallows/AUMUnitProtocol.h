/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012. All rights reserved.
 @{
 */
/// \file AUMUnitProtocol.h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


/** \brief Minimum requirement for AUMUnits which wishes to use the AUMGraph.  AUMUnitAbstract fulfills this and adds additional features.
 
 Underscore props are considered AUM Lib package scope, which includes if you subclass but doesnt include client public access.
 */
@protocol AUMUnitProtocol <NSObject>

@required

@property (nonatomic, setter=_setGraphRef:) AUGraph _graphRef;       ///< The containing graph
@property (nonatomic, setter=_setNodeRef:) AUNode _nodeRef;         ///< The node in the graph
@property (nonatomic, setter=_setAudioUnitRef:) AudioUnit _audioUnitRef; ///< The audio unit opened from the graph

/// \name AUcompDesc Unit Component Description consts
/// @{

@property (nonatomic, readonly) const AudioComponentDescription _audioComponentDescription;

/** Number of the max bus. ie 0 for 1 bus, 9 for 10 busses.  -1 for none (eg an AU with external no input) */
@property (nonatomic, readonly) NSInteger inputBusCount;
@property (nonatomic, readonly) NSInteger outputBusCount;

/// @}


@optional

/** Event notification called by AUMGraph when added to the graph.  At this point, _nodeReg and _audioUnitRef have been set */
- (void)_nodeWasAddedToGraph;


@end

/// @}