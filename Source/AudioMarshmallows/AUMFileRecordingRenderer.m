/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 23/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMFileRecordingRenderer.h"
#import "Private/AUMErrorChecking.h"

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
    
    
    return noErr;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMFileRecordingRenderer
/////////////////////////////////////////////////////////////////////////

@implementation AUMFileRecordingRenderer
{
    ExtAudioFileRef _fileRef;
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
    }
    return self;
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
    // Close the old one
    if (_fileRef) {
        _(ExtAudioFileDispose(_fileRef),
          kAUMAudioFileException,
          @"Error disposing of previous file %@", _outputFileURL.lastPathComponent);
    }
    
    // Open the new one
    AudioStreamBasicDescription asbd = {0};
    asbd.mSampleRate = kAudioStreamAnyRate;
    asbd.mFormatID = kAudioFormatAppleIMA4;
    asbd.mChannelsPerFrame = 2;
    
    _(ExtAudioFileCreateWithURL((__bridge CFURLRef)aURL,
                                aFileFormat.fileTypeId,
                                &aFileFormat.streamFormat,
                                NULL,
                                kAudioFileFlags_EraseFile,
                                &_fileRef),
      kAUMAudioFileException,
      @"Error creating audio file %@", aURL.absoluteString);
    
    
    // Now set our property as we've opened it successfully
    _outputFileURL = aURL;
    
    
    // Explicitly set the encoding method to prevent various issues
    // See http://michaelchinen.com/2012/04/30/ios-encoding-to-aac-with-the-extended-audio-file-services-gotchas/
    _(ExtAudioFileSetProperty(_fileRef,
                              kExtAudioFileProperty_CodecManufacturer,
                              sizeof(aFileFormat.codecManufacturer),
                              &aFileFormat.codecManufacturer),
      kAUMAudioFileException,
      @"Error setting the codec manufacturer (hardware/software) for audio file %@", _outputFileURL.absoluteString);
}

/////////////////////////////////////////////////////////////////////////



- (void)record
{
    // Check input format has been set
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}