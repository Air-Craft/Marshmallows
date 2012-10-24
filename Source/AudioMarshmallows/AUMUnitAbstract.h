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
#import "AUMRendererProtocol.h"


/**
 \brief Base class to cover the operations common to most Audio Units and custom AU requirements.
 
 
 \section DEV NOTES
 - _graphRed, _nodeRef, and, _audioUnitRef are set after the AUMUnit is added to the AUMGraph.  
 
 \todo Render Notify callbacks 
 */
@interface AUMUnitAbstract : NSObject <AUMUnitProtocol>
{
@protected
    /// \name Property from AUMUnitProtocol ivars.  Allow them to be set by subclasses
    /// @{
    AUGraph _graphRef;
    AUNode _nodeRef;
    AudioUnit _audioUnitRef;
    NSInteger _inputBusCount;
    NSInteger _outputBusCount;
    /// @}

}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

/** Must be overriden by subclass and _inputBusCount and _OutputBusCount set
 */
- (id)init;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

/** Allow instantiating an AUMUnit without a graph */
- (void)instantiateWithoutGraph;


- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forInputBus:(NSUInteger)aBusNum;

- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forOutputBus:(NSUInteger)aBusNum;

- (AudioStreamBasicDescription)streamFormatForInputBus:(NSUInteger)aBusNum;
- (AudioStreamBasicDescription)streamFormatForOutputBus:(NSUInteger)aBusNum;


- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forOutputBus:(NSUInteger)aBusNum;

- (void)setRenderCallback:(AURenderCallbackStruct)aRenderCallback forInputBus:(NSUInteger)aBusNum;

- (void)setRenderCallback:(AURenderCallbackStruct)aRenderCallback forOutputBus:(NSUInteger)aBusNum;

/** \throws kAUMAudioUnitException on error */
- (void)addRenderNotifyWithCallback:(AURenderCallback)theCallback userDataPtr:(void *)inProcUserData;

/** Attach a Renderer as a RenderNotify callback.  Be sure to manually set he stream format on the input or output bus(ses) depending on which (Pre or PostRender) side your RCB will operate. */
- (void)attachRenderer:(id<AUMRendererProtocol>)anAUMRenderer;

/** Convenience methods to connect an AUMRenderer to a bus.  Sets the stream format on the AUMUnit bus automatically
 */
- (void)attachRenderer:(id<AUMRendererProtocol>)anAUMRenderer toInputBus:(NSUInteger)aBusNum;

- (void)attachRenderer:(id<AUMRendererProtocol>)anAUMRenderer toOutputBus:(NSUInteger)aBusNum;

@end

/// @}