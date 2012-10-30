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
#import "AUMAudioFileReader.h"
#import "AUMCircularBuffer.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMRendererAudioSource
/////////////////////////////////////////////////////////////////////////

/**
 \ingroup   Marshmallows
 \brief     Goals:  Hide implementation of CircularBuffer, atomic ops and provide mechanism for client to feed from an external source such as a file.  Also to maintain refs for the RCB to neccessary objects related to a source. And to bridge between audio file format and format required by RCB
 
 \todo Resolve fact that public methods like ->pause() confuse the use of ->state().  Clients should only have to deal with one or the other.
 
 \section Audio File Format
 Source must be fed non-interleaved, stereo.  Float v Int and bit depth are configurable via initializeBuffer()'s bytesPerFrame param.  For mono, just feed the same data to both L & R channels.
 
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
 
 \todo Spinlock on pause? (if so then remove one from play)
 */
class AUMRendererAudioSource
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
        Finished        ///< EOF and buffer empty.  Set externally usually when feeding file EOFs
    };

/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////

    /**
     \throws NSInvalidArgumentException if AudioFile output format is incompatible
     */
    AUMRendererAudioSource() :
        _state(AUMRendererAudioSource::Paused),
        _volume(1.0),
        _pitch(1.0),
        _previousVolume(-1.0),
        _bufferReadPosInFrames(0.0),
        _bytesPerFrame(0)
    {   
        // Init the ringBuffer structs to ensure we can test whether they have been initialised
        memset(&_ringBufferL, 0, sizeof(AUMCircularBuffer));
        memset(&_ringBufferR, 0, sizeof(AUMCircularBuffer));
    };
    
    /////////////////////////////////////////////////////////////////////////
    
    ~AUMRendererAudioSource()
    {
        if (_ringBufferL.buffer) {
            AUMCircularBufferCleanup(&_ringBufferL);
            AUMCircularBufferCleanup(&_ringBufferR);
        }
    };
    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

    /** Init the internal buffer. bytesPerFrames is *per channel*!
     
        \param bufferSizeInFrames   The total size for BOTH L & R channels.  Thus, bufferSizeInFrames = bufferSizeInBytes/2/bytesPerFrame.  The actual bytes allocated will be rounded down to the nearest multiple of bytesPerFrame * 2
        \param bytesPerFrame    Used to effectively set the bit depth your RCB will expect (eg Float32 = 4)
     */
    void initializeBuffer(NSInteger bufferSizeInBytes, NSInteger bytesPerFrame);
    
    /////////////////////////////////////////////////////////////////////////
    
    /** Volume */
    inline void volume(AUMAudioControlParameter v) { _volume = v; }    // implicit conversion to ensure it still works if AUMAudioControlParam changes to 64 bit
    inline AUMAudioControlParameter volume() { return _volume; }
    
    /////////////////////////////////////////////////////////////////////////
    
    /** Pitch */
    inline void pitch(AUMAudioControlParameter p) { _pitch = p; }
    inline AUMAudioControlParameter pitch() { return _pitch; }
    
    /////////////////////////////////////////////////////////////////////////
    
    /** State accessor. R/O. */
    inline AUMRendererAudioSource::State state() {
        UInt32 t = _state;  // Get around type conversion issues
        return AUMRendererAudioSource::State(t);
    }
    
    /** Public method for indicating that the source is done and should be ignored by the RCB
     
     This generally happens when its feeding file has EOF'ed and there are no frames left in the buffer
     */
    void setFinished();
    
    /////////////////////////////////////////////////////////////////////////

    /** R/O Not to be confused with the file read position. This is updates on every buffer read. It can be fractional if pitch scaling is involved. */
    Float32 playheadPosInFrames() { return _bufferReadPosInFrames; }

    /////////////////////////////////////////////////////////////////////////

    void play();
    void pause();
    
    /** Erases the ring buffers (L & R) and resets the read position indicator to 0.0.  Reset state to Paused (the initial state) */
    void clearBuffer();
    
    /** Clears the buffers and also resets the volume and pitch.  Intended for cleaning prior to reuse */
    void reset();

    NSUInteger framesRemainingInBuffer();
    
    /** Keep in mind there are 2 channels so sizeInBytes = BytesPerFrame * bufferSizeInFrames * 2 */
    NSUInteger bufferSizeInFrames() { return _bufferSizeInFrames; }
    void pointersToBufferHeads(void **bufferPtrL, void **bufferPtrR);
    void indicateFramesWrittenToBuffer(NSUInteger framesWritten);
    
    /////////////////////////////////////////////////////////////////////////
#pragma mark - Render Callback Publics
    /////////////////////////////////////////////////////////////////////////
    
public:
    
    /// @name Render Callback Publics
    /// These are meant for RCB functions only.  
    
    AUM::AtomicUInt32 _state;
    AUM::AtomicFloat32 _volume;
    AUMAudioControlParameter _previousVolume;   ///< Used by RCB only for smooth volume x-sitions.  No need for atomic
    AUM::AtomicFloat32 _pitch;
    
    Float32 _bufferReadPosInFrames;         ///< The current read head in frames + fraction
    
    // Used in the RCB after QueueToPause has been processed
    inline void _setPausedState() { _state = AUMRendererAudioSource::Paused; }
    
    /**
     Read a quantity of frames and update the internal buffer read pointer.
     
     Float values needed to read fractional values which are needed in pitch scaled sources.  Returns pointer to the frames from floor(frameReadPos) to ceil(frameReadPos + framesToRead) but only advances the read head on the internal buffer to floor(framesReadPos+framesToRead) since the subsequent frame may be required in the next read (as well as the current).
     */
    inline const Float32 _readFramesFromBuffer(void *destBufferL, void *destBufferR, Float32 framesToRead);
    
    /// @}
    

    
/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////
private:
    
    AUMCircularBuffer _ringBufferL;
    AUMCircularBuffer _ringBufferR;
    int32_t _bufferSizeInFrames;
    int32_t _bytesPerFrame;
    
};


/////////////////////////////////////////////////////////////////////////
#pragma mark - Inlines
/////////////////////////////////////////////////////////////////////////

inline const Float32 AUMRendererAudioSource::_readFramesFromBuffer(void *destBufferL, void *destBufferR, Float32 framesToRead)
{
    // Check the buffers have been initialised
    if (!_ringBufferL.buffer) {
        [NSException raise:NSInternalInconsistencyException format:@"Must initialise the buffer before calling this method"];
    }
    
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

