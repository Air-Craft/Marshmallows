/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 15/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */
/// \file AUMUnitAbstract.h
 
 
#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AUMUnitProtocol.h"


/**
 \brief Base class to cover the operations common to most Audio Units and custom AU requirements.
 
 \p FEATURE: ARBITRARY SETUP ORDER
 Allows properties like stream formats and render callbacks to be set earlier, prior to adding to the graph.  These are then set on the underlying AU when added to the graph via the callback in AUMUnitProtocol.
 
 \todo Render Notify callbacks 
 */
@interface AUMUnitAbstract : NSObject <AUMUnitProtocol>
{
@protected
    BOOL _hasBeenAddedToGraph;      ///< Set to YES by _nodeWasAddedToGraph
    
    /// \name Private instance vars
    /// These are used to store info for late binding of variuous AU properties
    /// The dict key is the bus number.  They are emptied after the Unit is added to the graph
@private
    NSMutableDictionary *_inputStreamFormatsQueue;
    NSMutableDictionary *_outputStreamFormatsQueue;
    NSMutableDictionary *_renderCallbacksQueue;
    /// @}

}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////
/*
- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forInputBus:(NSUInteger)aBusNum;

- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forOutputBus:(NSUInteger)aBusNum;
*/

- (void)setRenderCallback:(AURenderCallbackStruct)aRenderCallback forInputBus:(NSUInteger)aBusNum;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}