/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{
 */


#import "MarshmallowDebug.h"
#import "Private/AUMErrorChecking.h"
#import "AUMAudioFileReader.h"


@implementation AUMAudioFileReader
{
    ExtAudioFileRef _fileRef;
    UInt32 _readPosInFrames;    ///< Track read position to prevent unnecessary Seeks on Read
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
/////////////////////////////////////////////////////////////////////////

+ (id)audioFileForURL:(NSURL *)aFileURL
{
    return [[self alloc] initForURL:aFileURL];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////

- (void)dealloc
{
    // Clean up the file ref
    if (_fileRef)
        ExtAudioFileDispose(_fileRef);
}

/////////////////////////////////////////////////////////////////////////

- (id)initForURL:(NSURL *)aFileURL
{    
    // Much of this is taken from the OpenALExample sample project's MyGetOpenALAudioData(...) function
    
    // Validations and supers
    if (!(self = [super init])) return nil;
    
    _readHeadPosInFrames = 0;   // Init to start of file
    _eof = NO;
    
    _fileURL = [aFileURL copy];
    UInt32 s;   // for property variable sizes
    
    // Open the file
    _(ExtAudioFileOpenURL((__bridge CFURLRef)aFileURL, &_fileRef),
      kAUMAudioFileException,
      @"Failed to open file %@", _fileURL.lastPathComponent);
    
    
    // Get the length in frames
    SInt64 lengthInFrames;
    s = sizeof(lengthInFrames);
    _(ExtAudioFileGetProperty(_fileRef,
                              kExtAudioFileProperty_FileLengthFrames,
                              &s,
                              &lengthInFrames),
      kAUMAudioFileException,
      @"Error reading frame length from file %@", _fileURL.lastPathComponent);
    
    _lengthInFrames = lengthInFrames;
    
    
    // Get the format description
    s = sizeof(AudioStreamBasicDescription);
    _(ExtAudioFileGetProperty(_fileRef,
                              kExtAudioFileProperty_FileDataFormat,
                              &s,
                              &_inFormat),
      kAUMAudioFileException,
      @"Error reading ASBD from file %@", _fileURL.lastPathComponent);
    
    
    // Set the default output format
    self.outFormat = kAUMStreamFormatAUMUnitCanonical;     // Sets the property on the ExtAudioFile as well
    
    return self;
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors
/////////////////////////////////////////////////////////////////////////

- (void)setOutFormat:(AudioStreamBasicDescription)outFormat
{
    _outFormat = outFormat;
    UInt32 s = sizeof(AudioStreamBasicDescription);
    _(ExtAudioFileSetProperty(_fileRef, kExtAudioFileProperty_ClientDataFormat, s, &_outFormat),
      kAUMAudioFileException,
      @"Couldn't set client format on file %@", _fileURL.lastPathComponent);
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)seekToFrame:(NSUInteger)theFrame
{
    if (theFrame >= _lengthInFrames) {
        [NSException raise:NSRangeException format:@"Frame %u out of bounds for file %@ of length %u frames)", theFrame, _fileURL.lastPathComponent, _lengthInFrames];
    }
    _readHeadPosInFrames = theFrame;
    _(ExtAudioFileSeek(_fileRef, theFrame),
      kAUMAudioFileException,
      @"Error seeking to frame %i in file %@", theFrame, _fileURL.lastPathComponent);

    _eof = NO;
}

/////////////////////////////////////////////////////////////////////////

- (void)reset
{
    _readHeadPosInFrames = 0;
    _eof = NO;
}

/////////////////////////////////////////////////////////////////////////

- (NSUInteger)readFrames:(NSUInteger)theFrameCount intoBufferL:(void *)aBufferL bufferR:(void *)aBufferR
{
    return [self readFrames:theFrameCount fromFrame:_readHeadPosInFrames intoBufferL:aBufferL bufferR:aBufferR];
}

/////////////////////////////////////////////////////////////////////////

- (NSUInteger)readFrames:(NSUInteger)theFrameCount fromFrame:(NSUInteger)theStartFrame intoBufferL:(void *)aBufferL bufferR:(void *)aBufferR
{
    // Malloc the ABL
    AudioBufferList *abl;
    UInt32 ablSize = offsetof(AudioBufferList, mBuffers[0]) + sizeof(AudioBuffer) * _outFormat.mChannelsPerFrame;  // 2 buffers for stereo
    abl = malloc(ablSize);
    
    // Get the data size required
    UInt32 dataSizeBytes = _outFormat.mBytesPerFrame * theFrameCount;
    
    // Setup and assign the underlying buffer to our pointer argument
    abl->mNumberBuffers = _outFormat.mChannelsPerFrame;
    abl->mBuffers[0].mNumberChannels = 1;               // always 1 for non-interleaved
    abl->mBuffers[0].mDataByteSize = dataSizeBytes;
    abl->mBuffers[0].mData = aBufferL;
    
    // Create the other buffer only if stereo
    if (_outFormat.mChannelsPerFrame > 1) {
        abl->mBuffers[1].mNumberChannels = 1;
        abl->mBuffers[1].mDataByteSize = dataSizeBytes;
        abl->mBuffers[1].mData = aBufferR;
    }
    
    UInt32 framesRead = [self readFrames:theFrameCount fromFrame:theStartFrame intoAudioBufferList:abl];
    
    // If mono then copy to aBufferR
    if (_outFormat.mChannelsPerFrame == 1) {
        memcpy(aBufferR, aBufferL, dataSizeBytes);
    }
    
    free(abl);
    
    return framesRead;
}

/////////////////////////////////////////////////////////////////////////

- (NSUInteger)readFrames:(NSUInteger)theFrameCount fromFrame:(NSUInteger)theStartFrame intoAudioBufferList:(AudioBufferList *)theAudioBufferList
{
    // Don't check bounds.  Will return the number of frames read if less than requested.  This is how you determine EOF
    
    UInt32 framesToReadAndRead = theFrameCount;
    
    // Seek if required
    if (theStartFrame != _readHeadPosInFrames) {
        _(ExtAudioFileSeek(_fileRef, theStartFrame),
          kAUMAudioFileException,
          @"Error seeking to frame %i in file %@", theStartFrame, _fileURL.lastPathComponent);
    }
    
    _(ExtAudioFileRead(_fileRef, &framesToReadAndRead, theAudioBufferList),
      kAUMAudioFileException,
      @"Error reading %i - %i frames from file %@", theStartFrame, theStartFrame+theFrameCount, _fileURL.lastPathComponent);
    
    // update read head
    _readHeadPosInFrames = theStartFrame + framesToReadAndRead;
    
    // EOF?
    if (_readHeadPosInFrames >= _lengthInFrames) {
        _eof = YES;
        MMLogRealTime(@"EOF reached for file %@", _fileURL.lastPathComponent);
    } else {
        _eof = NO;  // Reset eof if we're back on track
    }
    
    return framesToReadAndRead;
}


@end

/*
AudioBufferList *AUMCreateNonInterleavedAudioBufferList(UInt32 numChannels, void *buffers[], UInt32 bufferBytesSize)
{
    AudioBufferList *abl;
    UInt32 ablSize = offsetof(AudioBufferList, mBuffers[0]) + sizeof(AudioBuffer) * numChannels;
    abl = malloc(ablSize);

    for (int i=0; i<numChannels; i++) {
        abl->mBuffers[i].mDataByteSize = bufferBytesSize;
        abl->mBuffers[i].mNumberChannels = 1;   // non-interleaved is always 1
        abl->mBuffers[i].mData = buffers[i];
    }
    
    return abl;
}*/

/// @}