/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 23/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import <unistd.h>
#import "AUMFileRecordingRenderer.h"
#import "Private/AUMErrorChecking.h"
#import "MarshmallowCocoa.h"
#import "MarshmallowDebug.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - RCB
/////////////////////////////////////////////////////////////////////////
static OSStatus AUMFileRecordingRendererRCB(void *							inRefCon,
                                             AudioUnitRenderActionFlags *	ioActionFlags,
                                             const AudioTimeStamp *			inTimeStamp,
                                             UInt32							inBusNumber,
                                             UInt32							inNumberFrames,
                                             AudioBufferList *				ioData)
{
    AUMFileRecordingRenderer *THIS = (__bridge AUMFileRecordingRenderer *)inRefCon;
    
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
#pragma mark - AUMFileRecordingRenderer
/////////////////////////////////////////////////////////////////////////

@implementation AUMFileRecordingRenderer
{
    

}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////

- (id)init
{
    self = [super init];
    if (self) {
        _fileRef = NULL;    // Init just to be sure
        _inputStreamFormat = kAUMStreamFormatAUMUnitCanonical;  // Just a handy default
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

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMRendererProcotol
/////////////////////////////////////////////////////////////////////////

- (AudioStreamBasicDescription)renderCallbackStreamFormat
{
    // Return whatever our user selected inputStreamFormat is
    return _inputStreamFormat;
}

- (AURenderCallbackStruct)renderCallbackStruct
{
    AURenderCallbackStruct rcbStruct = {
        .inputProc = &AUMFileRecordingRendererRCB,
        .inputProcRefCon = (__bridge void *)(self)     // We'll use naughty public ivars :)
    };
    return rcbStruct;
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
    }
    
    // Store the parameters for opening on queue...
    _outputFileURL = aURL;
    _outputFileFormat = aFileFormat;
}

/////////////////////////////////////////////////////////////////////////

- (void)queue
{
    if (!_outputFileURL) {
        [NSException raise:NSInternalInconsistencyException format:@"Output file must be loaded first"];
    }
    
    // Open the new one
    AudioStreamBasicDescription asbd = {0};
    asbd.mSampleRate = kAudioStreamAnyRate;
    asbd.mFormatID = kAudioFormatAppleIMA4;
    asbd.mChannelsPerFrame = 2;
    
    _(ExtAudioFileCreateWithURL((__bridge CFURLRef)_outputFileURL,
                                _outputFileFormat.fileTypeId,
                                &_outputFileFormat.streamFormat,
                                NULL,
                                kAudioFileFlags_EraseFile,
                                &_fileRef),
      kAUMAudioFileException,
      @"Error creating audio file %@", _outputFileURL.absoluteString);
  
    // Explicitly set the encoding method to prevent various issues
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
        [NSException raise:NSInternalInconsistencyException format:@"Recording is already on!"];
    }
    if (!self._isQueued)
        [self queue];
    
    _isRecording = true;
}

/////////////////////////////////////////////////////////////////////////

- (void)stop
{
    if (not _isRecording) {
        [NSException raise:NSInternalInconsistencyException format:@"Recording is already stopped!"];
    }
    
    // Request stop and then spin lock until the RCB confirms
    _stopRequestFlag = true;
    while (_isRecording) sleep(5);
    
    // Reset the request flag
    _stopRequestFlag = false;
    
    ExtAudioFileDispose(_fileRef);
    _fileRef = NULL;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////

- (BOOL)_isQueued { return _fileRef != NULL; }

@end

/// @}