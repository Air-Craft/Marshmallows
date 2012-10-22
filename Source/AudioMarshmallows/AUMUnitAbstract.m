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

- (id)initWithSampleRate:(NSTimeInterval)aSampleRate
{
    if (self.class == AUMUnitAbstract.class) {
        [NSException raise:NSInternalInconsistencyException format:@"Abstract class cannot be instantiated directly."];
    }
    
    self = [super init];
    if (self) {
        _sampleRate = aSampleRate;
        _inputStreamFormatsQueue = [NSMutableDictionary new];
        _outputStreamFormatsQueue = [NSMutableDictionary new];
        _renderCallbacksQueue = [NSMutableDictionary new];
        
        // Default to no stream format so the AUGraph uses its defaults
        _defaultInputStreamFormat = kAUMNoStreamFormat;
        _defaultOutputStreamFormat = kAUMNoStreamFormat;
        _maxInputBusNum = NSIntegerMax;
        _maxOutputBusNum = NSIntegerMax;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////

- (id)init
{
    NSTimeInterval sr = AUMAudioSession.currentHardwareSampleRate;
    if (!sr) {
        [AUMException raise:kAUMAudioUnitException format:@"Sample rate could not be retrieved from the audio session.  Set via AUMAudioSession first or use initWithSampleRate:"];
    }
    
    return [self initWithSampleRate:sr];
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

@synthesize maxInputBusNum=_maxInputBusNum;
@synthesize maxOutputBusNum=_maxOutputBusNum;

/////////////////////////////////////////////////////////////////////////

@synthesize defaultInputStreamFormat=_defaultInputStreamFormat;
- (AudioStreamBasicDescription)defaultInputStreamFormat
{
    // Set the sample rate if this isn't the empty stream format
    if (!AUM_isNoStreamFormat(&_defaultInputStreamFormat)) {
        _defaultInputStreamFormat.mSampleRate = _sampleRate;
    }
    return _defaultInputStreamFormat;
}

/////////////////////////////////////////////////////////////////////////

@synthesize defaultOutputStreamFormat=_defaultOutputStreamFormat;
- (AudioStreamBasicDescription)defaultOutputStreamFormat
{
    // Set the sample rate if this isn't the empty stream format
    if (!AUM_isNoStreamFormat(&_defaultOutputStreamFormat)) {
        _defaultOutputStreamFormat.mSampleRate = _sampleRate;
    }
    return _defaultOutputStreamFormat;
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////
/*
REMOVED.  For simplicity, its better to set these when connecting busses or render callbacks. 
 
- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forInputBus:(NSUInteger)aBusNum
{
    // If added to the graph already then set the AU property...
    if (_hasBeenAddedToGraph) {
        _xAU(AudioUnitSetProperty(_audioUnitRef,
                               kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Input,
                               aBusNum,
                               &aStreamFormat,
                               sizeof(aStreamFormat)),
          [NSString stringWithFormat:@"Failed to set stream format on input bus %i of %@", aBusNum, self]);
    } else {
        // Add it to our dictionary
        NSValue *asValue = [NSValue value:&aStreamFormat withObjCType:@encode(AudioStreamBasicDescription)];
        _inputStreamFormatsQueue[@(aBusNum)] = asValue;
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)setStreamFormat:(AudioStreamBasicDescription)aStreamFormat forOutputBus:(NSUInteger)aBusNum
{
    // If added to the graph already then set the AU property...
    if (_hasBeenAddedToGraph) {
        _xAU(AudioUnitSetProperty(_audioUnitRef,
                               kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Output,
                               aBusNum,
                               &aStreamFormat,
                               sizeof(aStreamFormat)),
          [NSString stringWithFormat:@"Failed to set stream format on output bus %i of %@", aBusNum, self]);
    } else {
        
        // Add it to our dictionary
        NSValue *asValue = [NSValue value:&aStreamFormat withObjCType:@encode(AudioStreamBasicDescription)];
        _outputStreamFormatsQueue[@(aBusNum)] = asValue;
    }
}*/

/////////////////////////////////////////////////////////////////////////

- (void)setRenderCallback:(AURenderCallbackStruct)aRenderCallback forInputBus:(NSUInteger)aBusNum
{
    // Get the input stream format
    AudioStreamBasicDescription asbd = self.defaultInputStreamFormat;
    
    // If added to the graph already then set the AU property...
    if (_hasBeenAddedToGraph) {
        
        // Stream format if set
        if (!AUM_isNoStreamFormat(&asbd)) {
            _(AudioUnitSetProperty(_audioUnitRef,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Input,
                                   aBusNum,
                                   &asbd,
                                   sizeof(AudioStreamBasicDescription)),
              kAUMAudioUnitException,
              @"Failed to set stream format (for render callback) on input bus %i of %@", aBusNum, self);
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
        
    } else {
        
        // Add Stream Format to our dictionary
        if (!AUM_isNoStreamFormat(&asbd)) {
            NSValue *asbdValue = [NSValue value:&asbd withObjCType:@encode(AudioStreamBasicDescription)];
            _inputStreamFormatsQueue[@(aBusNum)] = asbdValue;
        }
        
        // Add RCB to our dictionary
        NSValue *rcbValue = [NSValue value:&aRenderCallback withObjCType:@encode(AURenderCallbackStruct)];
        _renderCallbacksQueue[@(aBusNum)] = rcbValue;
    }
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

/////////////////////////////////////////////////////////////////////////

/** Handles late binding of stream formats and callbacks.  Subclasses should call super */
- (void)_nodeWasAddedToGraph
{
    // Indicate
    _hasBeenAddedToGraph = YES;
    
    // Loop through our queues and set the AU properties
    
    // INPUT STREAM FORMATS
    
    for (NSNumber *key in _inputStreamFormatsQueue) {
        
        // Unwrap values
        NSInteger busNum = [key integerValue];
        AudioStreamBasicDescription format;
        [(NSValue *)_inputStreamFormatsQueue[key] getValue:&format];
        
        _(AudioUnitSetProperty(_audioUnitRef,
                               kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Input,
                               busNum,
                               &format,
                               sizeof(format)),
          kAUMAudioUnitException,
          [NSString stringWithFormat:@"Failed to set stream format on input bus %i of %@", busNum, self]);
    }
    [_inputStreamFormatsQueue removeAllObjects];     // Clear the queue
    
    // OUTPUT STREAM FORMATS
    for (NSNumber *key in _outputStreamFormatsQueue) {
        
        // Unwrap values
        NSUInteger busNum = [key unsignedIntegerValue];
        AudioStreamBasicDescription format;
        [(NSValue *)_outputStreamFormatsQueue[key] getValue:&format];
        
        _(AudioUnitSetProperty(_audioUnitRef,
                               kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Output,
                               busNum,
                               &format,
                               sizeof(format)),
          kAUMAudioUnitException,
          [NSString stringWithFormat:@"Failed to set stream format on output bus %i of %@", busNum, self]);
    }
    [_outputStreamFormatsQueue removeAllObjects];     // Clear the queue

    // INPUT RENDER CALLBACKS
    for (NSNumber *key in _renderCallbacksQueue) {
        
        // Unwrap values
        NSUInteger busNum = [key unsignedIntegerValue];
        AURenderCallbackStruct callback;
        [(NSValue *)_renderCallbacksQueue[key] getValue:&callback];
        
        _(AudioUnitSetProperty(_audioUnitRef,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               busNum,
                               &callback,
                               sizeof(callback)),
          kAUMAudioUnitException,
          [NSString stringWithFormat:@"Failed to set render callback on input bus %i of %@", busNum, self]);
    }
    [_renderCallbacksQueue removeAllObjects];     // Clear the queue
}

/// @}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}