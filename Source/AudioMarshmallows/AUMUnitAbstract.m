/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 15/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import "AUMUnitAbstract.h"
#import "MarshmallowCocoa.h"
#import "AUMErrorChecking.h"
#import "AUMException.h"
#import "AUMTypes.h"
#import "AUMAudioSession.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMUnitAbstract
/////////////////////////////////////////////////////////////////////////

@implementation AUMUnitAbstract


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

- (id)init
{
    if (self.class == AUMUnitAbstract.class) {
        [NSException raise:NSInternalInconsistencyException format:@"Abstract class cannot be instantiated directly."];
    }
    
    self = [super init];
    if (self) {
        _graphRef = NULL;           // Used to test whether graph was used
        _nodeRef = 0;
        _audioUnitRef = NULL;       // Used to test whether setup
        
        // Default to no stream format so the AUGraph uses its defaults
        _inputBusCount = NSIntegerMax;
        _outputBusCount = NSIntegerMax;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////

- (void)dealloc
{
    // Destroy manually if not in the graph
    if (!_graphRef) {
        AudioComponentInstanceDispose(_audioUnitRef);
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

@synthesize inputBusCount=_inputBusCount;
@synthesize outputBusCount=_outputBusCount;



/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)instantiateWithoutGraph
{
    AudioComponentDescription desc = self._audioComponentDescription;
    AudioComponent comp = AudioComponentFindNext(NULL, &desc);
    _(AudioComponentInstanceNew(comp,
                                &_audioUnitRef),
      kAUMAudioUnitException,
      @"Error creating new instance (no graph)");

    _(AudioUnitInitialize(_audioUnitRef),
      kAUMAudioUnitException,
      @"Error initialising new unit instance (no graph)");
}

/////////////////////////////////////////////////////////////////////////
 
- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forInputBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    _(AudioUnitSetProperty(_audioUnitRef,
                           kAudioUnitProperty_StreamFormat,
                           kAudioUnitScope_Input,
                           aBusNum,
                           &aStreamFormat,
                           sizeof(aStreamFormat)),
      kAUMAudioUnitException,
      @"Failed to set stream format on input bus %i of %@", aBusNum, self);
}

/////////////////////////////////////////////////////////////////////////

- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forOutputBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    // If added to the graph already then set the AU property...
    _(AudioUnitSetProperty(_audioUnitRef,
                           kAudioUnitProperty_StreamFormat,
                           kAudioUnitScope_Output,
                           aBusNum,
                           &aStreamFormat,
                           sizeof(aStreamFormat)),
      kAUMAudioUnitException,
      @"Failed to set stream format on output bus %i of %@", aBusNum, self);
}

/////////////////////////////////////////////////////////////////////////

- (void)setRenderCallback:(AURenderCallbackStruct)aRenderCallback forInputBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    
    // RCB
    _(AudioUnitSetProperty(_audioUnitRef,
                           kAudioUnitProperty_SetRenderCallback,
                           kAudioUnitScope_Input,
                           aBusNum,
                           &aRenderCallback,
                           sizeof(aRenderCallback)),
      kAUMAudioUnitException,
      @"Failed to set render callback on input bus %i of %@", aBusNum, self);
}

/////////////////////////////////////////////////////////////////////////

- (void)setRenderCallback:(AURenderCallbackStruct)aRenderCallback forOutputBus:(NSUInteger)aBusNum
{
    if (!_audioUnitRef) {
        [NSException raise:NSInternalInconsistencyException format:@"AUMUnit must be added to graph or instantiateWithoutGraph called prior to this method"];
    }
    
    // RCB
    _(AudioUnitSetProperty(_audioUnitRef,
                           kAudioUnitProperty_SetRenderCallback,
                           kAudioUnitScope_Output,
                           aBusNum,
                           &aRenderCallback,
                           sizeof(aRenderCallback)),
      kAUMAudioUnitException,
      @"Failed to set render callback on input bus %i of %@", aBusNum, self);
}

/////////////////////////////////////////////////////////////////////////

- (void)connectRenderer:(id<AUMRendererProtocol>)anAUMRenderer toInputBus:(NSUInteger)aBusNum
{
    [self setStreamFormat:anAUMRenderer.renderCallbackStreamFormat forInputBus:aBusNum];
    [self setRenderCallback:anAUMRenderer.renderCallbackStruct forInputBus:aBusNum];
}

/////////////////////////////////////////////////////////////////////////

- (void)connectRenderer:(id<AUMRendererProtocol>)anAUMRenderer toOutputBus:(NSUInteger)aBusNum
{
    [self setStreamFormat:anAUMRenderer.renderCallbackStreamFormat forOutputBus:aBusNum];
    [self setRenderCallback:anAUMRenderer.renderCallbackStruct forOutputBus:aBusNum];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMUnitProtocol Fulfillment
/////////////////////////////////////////////////////////////////////////
/** @name  AUMUnitProtocol Fulfillment */

@synthesize _graphRef=_graphRef;
@synthesize _nodeRef=_nodeRef;
@synthesize _audioUnitRef=_audioUnitRef;

/////////////////////////////////////////////////////////////////////////

/** Subclasses must define this method to indicate the kind of AU component they are
    \abstract */
- (const AudioComponentDescription)_audioComponentDescription
{
    AudioComponentDescription r;
    [NSException raise:NSInternalInconsistencyException format:@"Abstract method must be overridden by subclass."];
    return r;
}

    
/// @}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}