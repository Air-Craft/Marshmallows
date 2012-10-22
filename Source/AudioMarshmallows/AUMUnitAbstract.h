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
 
 \p FEATURE: DEFAULTS TO E-Z CANONICAL STREAM FORMAT
 the kAUMUnitCanonicalStreamFormat is set to t
 
 \section DEV NOTES
 - _graphRed, _nodeRef, and, _audioUnitRef are set after the AUMUnit is added to the AUMGraph.  _nodeWasAddedToGraph is called immediately afterwards so use this method for late binding properties set prior to adding to graph.
 
 \todo Render Notify callbacks 
 */
@interface AUMUnitAbstract : NSObject <AUMUnitProtocol>
{
@protected
    BOOL _hasBeenAddedToGraph;      ///< Set to YES by _nodeWasAddedToGraph
    
    /// \name Property from AUMUnitProtocol ivars.  Allow them to be set by subclasses
    /// @{
    AUGraph _graphRef;
    AUNode _nodeRef;
    AudioUnit _audioUnitRef;
    AudioStreamBasicDescription _defaultInputStreamFormat;
    AudioStreamBasicDescription _defaultOutputStreamFormat;
    NSInteger _maxInputBusNum;
    NSInteger _maxOutputBusNum;
    /// @}
    
    
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

@property (nonatomic, readonly) NSTimeInterval sampleRate;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

/** Designated init.  Requests the sample rate to set io stream format mSampleRate if its not kAUMNoStreamFormat.  
 
 Not required technically but is quite convenient for most units to know about  */
- (id)initWithSampleRate:(NSTimeInterval)aSampleRate;

/////////////////////////////////////////////////////////////////////////

/** Attemptes to get the sample rate from AUMAudioSession. If session isnt set up yet then just use the designated init 
 \throws AUMException kAUMAudioUnitException if SR can't be retrieve (ie == 0)
 */
- (id)init;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////
/*
 REMOVED.  For simplicity, its better to set these when connecting busses or render callbacks. What cases does this leave outstanding?
 
 
- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forInputBus:(NSUInteger)aBusNum;

- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forOutputBus:(NSUInteger)aBusNum;
*/

/** Uses the defaultInputStreamFormat if specified */
- (void)setRenderCallback:(AURenderCallbackStruct)aRenderCallback forInputBus:(NSUInteger)aBusNum;



@end

/// @}