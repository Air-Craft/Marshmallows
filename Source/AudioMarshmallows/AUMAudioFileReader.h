/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{
 */
/// \file AUMAudioFile.h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 \brief     Wrapper around Ext Audio File Services to allow reading of arbitrary files into arbitrary output format.  outFormat defaults to Linear PCM/44.1/16bit/stereo/floating point/native endian/interleaved.  Set after init to change.
 */
@interface AUMAudioFileReader : NSObject 

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

@property (strong, nonatomic, readonly) NSURL *fileURL;

/** Length of the audio */
@property (nonatomic, readonly) NSUInteger lengthInFrames;

/** Readonly property representing the stream format of the file */
@property (nonatomic, readonly) AudioStreamBasicDescription inFormat;

/** Sets the format which read operations will render
    \throws kAUMAudioFileException on error when setting */
@property (nonatomic) AudioStreamBasicDescription outFormat;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
/////////////////////////////////////////////////////////////////////////

/** See initForURL: */
+ (id)audioFileForURL:(NSURL *)aFileURL;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

/**
 Load the Audio File Service reference and get the property data for the specified URL
 
 \throws kAUMAudioFileException
 \return Nil if there was a problem along with [SEOpenALWrapper messages...
 */
- (id)initForURL:(NSURL *)aFileURL;


/**
 Read frames from a specified starting position and return the number actually read.
 \property theBufferList    MUST BE properly malloc'ed prior!
 \throws kAUMAudioFileException
 \return the Number of frames actually read (0 for error, less than requested for EOF)
 */
- (NSUInteger)readFrames:(NSUInteger)theFrameCount fromFrame:(NSUInteger)theStartFrame intoAudioBufferList:(AudioBufferList *)theAudioBufferList;

/**
 \brief Convenience method for reading stereo data directly in void * buffers.  If mono then the channel will be copied to both
 */
- (NSUInteger)readFrames:(NSUInteger)theFrameCount fromFrame:(NSUInteger)theStartFrame intoBufferL:(void *)aBufferL bufferR:(void *)aBufferR;

@end

/// @}