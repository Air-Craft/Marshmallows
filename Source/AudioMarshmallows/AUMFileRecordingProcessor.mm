/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 23/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import <unistd.h>
#import "AUMFileRecordingProcessor.h"
#import "Private/AUMErrorChecking.h"
#import "MarshmallowCocoa.h"
#import "MarshmallowDebug.h"
#import "AUMAudioSession.h"
#import "AUMUnitAbstract.h"
#import "AUMUtilityFunctions.h"
#import "Private/AUMAtomicType.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - RCB
/////////////////////////////////////////////////////////////////////////
static OSStatus AUMFileRecordingProcessorRCB(void *							inRefCon,
                                             AudioUnitRenderActionFlags *	ioActionFlags,
                                             const AudioTimeStamp *			inTimeStamp,
                                             UInt32							inBusNumber,
                                             UInt32							inNumberFrames,
                                             AudioBufferList *				ioData)
{
    // Only do post render
    if (*ioActionFlags & kAudioUnitRenderAction_PreRender or inBusNumber != 0) {
        return noErr;
    }
    
    AUMFileRecordingProcessor *THIS = (__bridge AUMFileRecordingProcessor *)inRefCon;
    
    if (not THIS->_isRecording)
        return noErr;

    OSStatus res = ExtAudioFileWriteAsync(THIS->_fileRef, inNumberFrames, ioData);
    
    if (res != noErr) {
        MMLogRealTime(@"%@", [NSString mm_ErrorCodeStringFromOSStatus:res]);
    }
    
    // All done, so disable recording if requested
    if (THIS->_stopRequestFlag) {
        THIS->_stopRequestFlag = false;
        THIS->_isRecording = false;
    }
    
    return res;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMFileRecordingProcessor
/////////////////////////////////////////////////////////////////////////

@implementation AUMFileRecordingProcessor

/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////

- (id)init
{
    self = [super init];
    if (self) {
        _fileRef = NULL;    // Init just to be sure
        _inputStreamFormat = kAUMNoStreamFormat;
        _stopRequestFlag = false;
        _isRecording = false;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////

- (void)dealloc
{
    if (_isRecording) [self stop];  // Disposes of the ExtAudioFile as well
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

@synthesize inputStreamFormat=_inputStreamFormat;
@synthesize outputFileURL=_outputFileURL;

- (void)setInputStreamFormat:(AudioStreamBasicDescription)aFormat
{
    if (aFormat.mSampleRate == kAudioStreamAnyRate) {
        [NSException raise:NSInvalidArgumentException format:@"Format must have the sample rate explicitly set."];
    }
    _inputStreamFormat = aFormat;
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)isRecording
{
    // This is a C++ AtomicBool so do it's getter manually to prevent auto-synthesis
    return (BOOL)_isRecording;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMRendererProcotol
/////////////////////////////////////////////////////////////////////////

- (AURenderCallbackStruct)renderCallbackStruct
{
    AURenderCallbackStruct rcbStruct = {
        .inputProc = &AUMFileRecordingProcessorRCB,
        .inputProcRefCon = (__bridge void *)(self)     // We'll use naughty public ivars :)
    };
    return rcbStruct;
}

/////////////////////////////////////////////////////////////////////////

/// Grab the format from output bus 0 as this is the one our RCB will capture from
- (void)willAddToAUMUnit:(AUMUnitAbstract *)anAUMUnit
{
    // Grab the format for output bus 0 if not overriden
    if (AUM_isNoStreamFormat(_inputStreamFormat)) {
        AudioStreamBasicDescription aFormat = [anAUMUnit streamFormatForOutputBus:0];
        
        // Recorder needs the sample rate so grab it if not set
        if (aFormat.mSampleRate == kAudioStreamAnyRate) {
            aFormat.mSampleRate = AUMAudioSession.currentHardwareSampleRate;
            if (aFormat.mSampleRate == 0) {
                [NSException raise:NSInternalInconsistencyException format:@"Sample rate could not be retrieved from the Audio Session.  Set explicitly or initialise the session first"];
            }
        }
        
        _inputStreamFormat = aFormat;
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)newOutputFileWithURL:(NSURL *)aURL withFileFormat:(AUMAudioFileFormatDescription)aFileFormat
{
    if (_isRecording)
        [self stop];
    
    // Close the old one
    if (_fileRef) {
        _(ExtAudioFileDispose(_fileRef),
          kAUMAudioFileException,
          @"Error disposing of previous file %@", _outputFileURL.lastPathComponent);
        _fileRef = NULL;
    }
    
    // Store the parameters for opening on queue...
    _outputFileURL = aURL;
    _outputFileFormat = aFileFormat;
}

/////////////////////////////////////////////////////////////////////////

- (void)queue
{
    if ([self _isQueued]) {
        MMLogWarn(@"'queue' called when already queued!")
        return;
    }
    
    if (!_outputFileURL) {
        [NSException raise:NSInternalInconsistencyException format:@"Output file must be loaded first"];
    }
    
    // Open the new one

    _(ExtAudioFileCreateWithURL((__bridge CFURLRef)_outputFileURL,
                                _outputFileFormat.fileTypeId,
                                &_outputFileFormat.streamFormat,
                                NULL,
                                kAudioFileFlags_EraseFile,
                                &_fileRef),
      kAUMAudioFileException,
      @"Error creating audio file %@", _outputFileURL.absoluteString);

    // Set the client data format to our input format
    _(ExtAudioFileSetProperty(_fileRef,
                              kExtAudioFileProperty_ClientDataFormat,
                              sizeof(_inputStreamFormat),
                              &_inputStreamFormat),
      kAUMAudioFileException,
      @"Error setting client format on audio file %@", _outputFileURL.absoluteString);
    
    // Explicitly set the codec (hardware/software) to prevent various issues
    // See http://michaelchinen.com/2012/04/30/ios-encoding-to-aac-with-the-extended-audio-file-services-gotchas/
    
    _(ExtAudioFileSetProperty(_fileRef,
                              kExtAudioFileProperty_CodecManufacturer,
                              sizeof(_outputFileFormat.codecManufacturer),
                              &_outputFileFormat.codecManufacturer),
      kAUMAudioFileException,
      @"Error setting the codec manufacturer (hardware/software) for audio file %@", _outputFileURL.absoluteString);
}

/////////////////////////////////////////////////////////////////////////

- (void)record
{
    if (_isRecording) {
        MMLogWarn(@"'record' called when already recording!")
        return;
    }
    if (!self._isQueued)
        [self queue];
    
    _isRecording = true;
}

/////////////////////////////////////////////////////////////////////////

- (void)stop
{
    if (not _isRecording) {
        MMLogWarn(@"'stop' called when already stopped!")
        return;
    }
    
    // Request stop and then spin lock until the RCB confirms
    _stopRequestFlag = true;
    while (_isRecording) usleep(100);
    
    // Reset the request flag
    _stopRequestFlag = false;
    
    _(ExtAudioFileDispose(_fileRef),
      kAUMAudioFileException,
      @"Error closing the the file %@", _outputFileURL.absoluteString);
    
    _fileRef = NULL;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - <#statements#>
/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////

- (BOOL)_isQueued { return _fileRef != NULL; }

@end

/// @}