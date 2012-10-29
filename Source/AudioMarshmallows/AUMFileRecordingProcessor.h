/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 23/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AUMFileRecordingProcessor.h
 
 
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AUMTypes.h"
#ifdef __cplusplus
#import "Private/AUMAtomicType.h"
#endif
#import "AUMProcessorRendererProtocol.h"

/**
 \brief Records audio from an AUMUnit bus to disk
 
 \section DEV NOTES
 - Only use _stopRequestFlag in the RCB and in [stop].  [stop] is a synchronous command and waits for the RCB to finish so no need to check it outside of these locations.  Also use [stop] interally to stop recording as it handles the whole delay thing invisibly.
 
 \todo User settable bus and pre/post render?
 */
@interface AUMFileRecordingProcessor : NSObject <AUMProcessorRendererProtocol>
{
    /// Naughty publics to allow RCB access without expensive ObjC messaging
@public
    
    // Make this C friendly.  They are only here because we need public access to them in the RCB
#ifdef __cplusplus
    /// Set to true to request that the RCB stop the recording and set isRecording=false after next iteration.
    AUM::AtomicBool _stopRequestFlag;
    // Confirm
    AUM::AtomicBool _isRecording;
    ExtAudioFileRef _fileRef;
#endif

}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

/** Setting opens a new file for output
 \throws kAUMAudioFileException on error closing any previous file or creating the new one
 */
@property (nonatomic, strong, readonly) NSURL *outputFileURL;

/** Will be obtained automatically when connected to a unit if not set explicitly before. Ie, set to override.
 \throws NSInvalidArgumentException On set if mSampleRate is not set */
@property (nonatomic) AudioStreamBasicDescription inputStreamFormat;

/** The file format set via newOutputFileWithURL:withFileFormat */
@property (nonatomic, readonly) AUMAudioFileFormatDescription outputFileFormat;

@property (nonatomic, readonly) BOOL isRecording;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)newOutputFileWithURL:(NSURL *)aURL withFileFormat:(AUMAudioFileFormatDescription)aFileFormat;


/** Open the requested file and prepare for recording.  Called automatically by record if not alreayd queued but can be called manually to have record kick in faster.  If already queued then it issues an MMLogWarn but then quietly returns.
 \throws NSInternalInconsistencyException If no file specified
 */
- (void)queue;

/** Begin recording to the file.  If file has not ben "queued" then queueFile will be called. If already recording it issues an MMLogWarn but then quietly returns.
 \throws NSInternalInconsistencyException If no file has been set
 */
- (void)record;

/** Stops the recording. Also closes the audio file to ensure all async writes have completed and that the file can be used elsewhere. If already stopped then it issues an MMLogWarn but then quietly returns.
 \throws kAUMAudioFileException if error while closing (disposing) of the audio file
 */
- (void)stop;


@end

/// @}