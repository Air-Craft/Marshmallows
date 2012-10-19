/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file AUMFilePlayerUnitRCB.h


#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <tgmath.h>
#import "AUMAtomicType.h"
#import "AUMTypes.h"
#import "AUMException.h"
#import "AUMAudioFile.h"
//#import "AUMFilePlayerUnitRenderer.h"
#import "AUMCircularBuffer.h"

class AUMFilePlayerUnitRenderer;

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMRendererAudioFileSource
/////////////////////////////////////////////////////////////////////////

/**
 \ingroup   Marshmallows
 \brief     Goals:  Hide implementation of CircularBuffer, disk reading, atomic ops.  Maintain refs for the RCB to neccessary objects related to a source. And to bridge between audio file format and format required by RCB
 
 \section Audio File Format
 Current supports non-interleaved, native/float/packed, <=2 channels.  Set your AudioFile output format accordingly or you'll get an exception

 \section Mono/Stereo
 There is a L and R audio buffer. Mono files will simply read the same data into both L & R channels.
 
 \section Concurrency
 All atomic ops funnel through the inlined AUM::AtomicType properties which use a barrier to ensure memory syncronicity.  [OLD]Originally the only barrier op was in callbackSetFinished() for reasons stated in it's comments.  The others were deemed unimportant as at worst it would result in the render callback to skip an iteration which isn't such a big deal.  (This assumes that the memory would sync pretty quickly afterwards).  The outstanding issue which is mentioned in the AudioRender is resetting the source.  Do we need a special flag to mark the cleaning start and end to prevent the render CB from receiving a dirty source?
 
 \section DEV: The Flow Model
 Render Callback Scenarios:
 -# Stopped while note in callback loop
 -# Stopped before callback plays source
 -# Stopped while callback plays source
 
 \p
 - init ->
 - play() playing = 0
 - stop -> queuedToStop = 0
 
 \p callback():
 - if isPlaying && queuedToStop -> play=0
 - do it..checking each loop for queuedToStop? (no, locks)
 - if (eob and eof || queuedToStop) play=0, queuedToStop=1(??needed?) ==>  callbackSetFinished
 
 \p cleanUp():
 - if !play && queuedToStop  ==> isFinished()
 - if play && depleted ==> fill (check queuedToStop()?)
 
 \p Volume changes & previousVolume:
 To ensure smooth glitch-free transitions, we need to keep track of the previous volume.  previousVolume should only be R/W by the callback to prevent the need for thread safety measures.  prevVol begin life as -1 which signals to the callback to init it to volume on first run.  This prevents an unintended ramp occuring for sources that begin playing at a volume other than the default of 1.
 */
class AUMRendererAudioFileSource
{
public:
    /**
     The current playback state of the source
     */
    enum State : UInt32 {
        //Ready,          ///< ie Not playing, paused and rewound to beginning
        Paused,         ///< Paused.  Set when file is first queued up.
        Playing,        ///< Playing
        QueuedToPause,  ///< Still playing but will be paused by RCB on next iteration
        Finished        ///< EOF and buffer empty.  Set via RCB some time after EOF
    };

/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////

    /**
     \throws NSInvalidArgumentException if AudioFile output format is incompatible
     */
    AUMRendererAudioFileSource(AUMAudioFile *af, int32_t bufferSizeInFrames) :
        _isEOF(false),
        _audioFile(af),
        _volume(1.0),
        _loop(false),
        _pitch(1.0),
        _previousVolume(-1.0),
        _bufferReadPosInFrames(0.0),
        _audioFileReadPosInFrames(0),
        _state(AUMRendererAudioFileSource::Paused),
        _seekToFrameOnNextUpdate(0),
        _seekIsPending(false),
        _stateToResumeAfterSeek(AUMRendererAudioFileSource::Paused)
    {
        // Enforce interleaved audio for now.  Proper exceptions as the output format is set by the programmer, ie, we're not talking about the file format here
        if ( !(_audioFile.outFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved) ||
             !(_audioFile.outFormat.mFormatFlags & kAudioFormatFlagsNativeFloatPacked) ) {
            [NSException raise:NSInvalidArgumentException format:@"Audio file output format must be non-interleaved and native/float/packed"];
        }
        
        // Enforce mono/stereo...
        if (_audioFile.outFormat.mChannelsPerFrame > 2) {
            [NSException raise:NSInvalidArgumentException format:@"Audio file output must be mono or stereo (%i channels reported)", (int)af.outFormat.mChannelsPerFrame];
        }
        
        //_numChannels = _audioFile.outFormat.mChannelsPerFrame;
        _bufferSizeInFrames = bufferSizeInFrames;
        _bufferDepletedThresholdInFrames = _bufferSizeInFrames / 2;      // Lets say half for now
        _bytesPerFrame = _audioFile.outFormat.mBytesPerFrame;
        
        // Init our ring buffers
        AUMCircularBufferInit(&_ringBufferL, _bufferSizeInFrames * _bytesPerFrame);
        
        AUMCircularBufferInit(&_ringBufferR, _bufferSizeInFrames * _bytesPerFrame);
    };
    
    /////////////////////////////////////////////////////////////////////////
    
    ~AUMRendererAudioFileSource()
    {
        _audioFile = nil;
        AUMCircularBufferCleanup(&_ringBufferL);
        AUMCircularBufferCleanup(&_ringBufferR);
    };
    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors
/////////////////////////////////////////////////////////////////////////
    
    /** Volume */
    inline void volume(AUMAudioControlParameter v) { _volume = v; }    // implicit conversion to ensure it still works if AUMAudioControlParam changes to 64 bit
    inline AUMAudioControlParameter volume() { return _volume; }
    
    /////////////////////////////////////////////////////////////////////////
    
    /** Pitch */
    inline void pitch(AUMAudioControlParameter p) { _pitch = p; }
    inline AUMAudioControlParameter pitch() { return _pitch; }
    
    /////////////////////////////////////////////////////////////////////////
    
    /** Looping */
    inline void loop(bool l) { _loop = l; }
    inline bool loop() { return _loop; }
    
    /////////////////////////////////////////////////////////////////////////
    
    /** State.  Help with type compat issues */
    inline AUMRendererAudioFileSource::State state() {
        UInt32 t = _state;
        return AUMRendererAudioFileSource::State(t);
    }
    inline void state(AUMRendererAudioFileSource::State t) { _state = t; }
    
    /////////////////////////////////////////////////////////////////////////
    
    /** EOF flag */
    inline bool isEOF() { return _isEOF; }
    
    /////////////////////////////////////////////////////////////////////////

    /** R/O Not to be confused with the file read position. This is updates on every buffer read. It can be fractional if pitch scaling is involved. */
    Float32 playheadPosInFrames() { return _bufferReadPosInFrames; }

    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

    void play();
    void pause();
    void reset();
    void seekToFrame(NSUInteger);
    
    /**
     To be called at a regular interval. Handles disk buffer replenishing and seeking (which is delayed as to allow the RCB to pause the source first to prevent buffer R/W collisions)
     */
    void updateSource();
    
    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Render Callback Publics
/////////////////////////////////////////////////////////////////////////

private:

    /// @name Render Callback Publics
    /// These privates are meant to be accessed by the RCB
    friend AUMFilePlayerUnitRenderer;
    /*    friend OSStatus AUMFilePlayerUnitRenderer::renderCallback( void                        *inRefCon,
     AudioUnitRenderActionFlags  *ioActionFlags,
     const AudioTimeStamp        *inTimeStamp,
     UInt32                      inBusNumber,
     UInt32                      inNumberFrames,
     AudioBufferList             *ioData
     );*/
    
    AUM::AtomicUInt32 _state;
    AUM::AtomicFloat32 _volume;
    AUMAudioControlParameter _previousVolume;   ///< Used by RCB only for smooth volume x-sitions.  No need for atomic
    AUM::AtomicFloat32 _pitch;
    AUM::AtomicBool _loop;
    AUM::AtomicBool _isEOF;
    Float32 _bufferReadPosInFrames;         ///< The current read head in frames + fraction
    
    /**
     Read a quantity of frames and update the internal buffer read pointer.
     
     Float values needed to read fractional values which are needed in pitch scaled sources.  Returns pointer to the frames from floor(frameReadPos) to ceil(frameReadPos + framesToRead) but only advances the read head on the internal buffer to floor(framesReadPos+framesToRead) since the subsequent frame may be required in the next read (as well as the current).
     */
    inline const Float32 _readFramesFromBuffer(void *destBufferL, void *destBufferR, Float32 framesToRead);
    
    /// @}

    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////
    
    AUMAudioFile *_audioFile;
    AUMCircularBuffer _ringBufferL;
    AUMCircularBuffer _ringBufferR;
    int32_t _bufferSizeInFrames;
    int32_t _bufferDepletedThresholdInFrames;
    int32_t _bytesPerFrame;
    NSUInteger _audioFileReadPosInFrames;
    
    /** Vars to handle seek action */
    AUM::AtomicBool _seekIsPending;
    AUM::AtomicUInt32 _seekToFrameOnNextUpdate;
    AUMRendererAudioFileSource::State _stateToResumeAfterSeek;
    
    void _clearBuffer();
    void _processPendingSeeks();
    void _replenishBufferFromDisk();
    
};


/////////////////////////////////////////////////////////////////////////
#pragma mark - Inlines
/////////////////////////////////////////////////////////////////////////

inline const Float32 AUMRendererAudioFileSource::_readFramesFromBuffer(void *destBufferL, void *destBufferR, Float32 framesToRead)
{
    // Get the buffer pointer and available frames
    int32_t availBytes;
    void *sourceBufferL = AUMCircularBufferTail(&_ringBufferL, &availBytes);
    void *sourceBufferR = AUMCircularBufferTail(&_ringBufferR, &availBytes);
    NSUInteger availFrames = availBytes / _bytesPerFrame;
    
    // Nothing to read yet?
    if (0 == availFrames) return 0;
    
    // The amount of frames (decimal) which we've managed to read.
    Float32 framesReadFloat;
    
    // Check availability and get the whole number of frames to consume
    // as well as the decimal quantity of frames read as per the requested amount
    NSUInteger F0 = floor(_bufferReadPosInFrames);
    NSUInteger framesToConsume;
    
    // At the end of the buffer?  Adjust the return value
    if (_bufferReadPosInFrames + framesToRead > F0 + availFrames) {
        framesReadFloat = F0 + availFrames - _bufferReadPosInFrames;
        framesToConsume = availFrames;
    } else {
        framesReadFloat = framesToRead;
        framesToConsume = floor(_bufferReadPosInFrames + framesToRead) - F0;
    }
    
    // It could be zero, eg start = 10.1, framesToRead = 0.5 (1 frame with pitch=0.5)
    if (framesToConsume > 0) {
        AUMCircularBufferConsume(&_ringBufferL, framesToConsume * _bytesPerFrame);
        AUMCircularBufferConsume(&_ringBufferR, framesToConsume * _bytesPerFrame);
    }
    
    // Memcpy the data and update the head
    if (framesReadFloat > 0) {
        
        // Update the decimal read pos
        _bufferReadPosInFrames += framesReadFloat;
        memcpy(destBufferL, sourceBufferL, framesReadFloat * _bytesPerFrame);
        memcpy(destBufferR, sourceBufferR, framesReadFloat * _bytesPerFrame);
    }
    
    return framesReadFloat;
}

/// @}

