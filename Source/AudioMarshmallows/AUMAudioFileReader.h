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
 
 \par   Usage styles
        This will work as a sequential linear reader via [readFrames:intoBufferL:bufferR] or via the random access methods.  Both update the readHeadPosInFrames property. eof is set when th
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

@property (nonatomic, readonly) BOOL eof;

@property (nonatomic, readonly) NSUInteger readHeadPosInFrames;

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


/** Set the next read position for readFrame:intoBufferL:bufferB.  Essentially a setter for readHeadPosInFrames */
- (void)seekToFrame:(NSUInteger)theFrame;

/** Sets readHead back to 0 and clears eof */
- (void)reset;

/**
 \brief Read specified frames from the current readHeadPosInFrames, updating accordingly.  Use for linear streaming reads (as opposed to random access)
 */
- (NSUInteger)readFrames:(NSUInteger)theFrameCount intoBufferL:(void *)aBufferL bufferR:(void *)aBufferR;


/**
 \brief Convenience method for reading stereo data directly in void * buffers.  If mono then the channel will be copied to both
 */
- (NSUInteger)readFrames:(NSUInteger)theFrameCount fromFrame:(NSUInteger)theStartFrame intoBufferL:(void *)aBufferL bufferR:(void *)aBufferR;

/**
 The designated read method.  All others call this. Reads frames from a specified starting position and return the number actually read.
 \property theBufferList    MUST BE properly malloc'ed prior!
 \throws kAUMAudioFileException
 \return the Number of frames actually read (0 for error, less than requested for EOF)
 */
- (NSUInteger)readFrames:(NSUInteger)theFrameCount fromFrame:(NSUInteger)theStartFrame intoAudioBufferList:(AudioBufferList *)theAudioBufferList;

@end

/// @}