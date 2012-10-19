/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */

#import "AUMRendererAudioFileSource.h"
#import "MarshmallowDebug.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioFileSource::play()
{
    if (_state != AUMRendererAudioFileSource::Paused) {
        [NSException raise:NSInternalInconsistencyException format:@"Source must be in 'Paused' state in order to play"];
    }
    
    _state = AUMRendererAudioFileSource::Playing;
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioFileSource::pause()
{
    if (_state != AUMRendererAudioFileSource::Playing) {
        [NSException raise:NSInternalInconsistencyException format:@"Source must be in 'Playing' state in order to play"];
    }
    
    _state = AUMRendererAudioFileSource::QueuedToPause;
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioFileSource::seekToFrame(NSUInteger toFrame)
{
    // Sanity check
    if (toFrame >= _audioFile.lengthInFrames) {
        [NSException raise:NSRangeException format:@"Frame %i exceeds file's max length of %i", toFrame, _audioFile.lengthInFrames];
    }
    
    // Update the seektoframe
    _seekToFrameOnNextUpdate = toFrame;
    
    // If a seek is already outstanding then just update the frame
    if (_seekIsPending) {
        return;
    }
    
    // Otherwise set the state vars and queue to seek
    
    // Queue to pause if not already.  Remember that we were playing
    if (_state == AUMRendererAudioFileSource::Playing) {
        _stateToResumeAfterSeek = AUMRendererAudioFileSource::Playing;
        _state = AUMRendererAudioFileSource::QueuedToPause;
    
    // Otherwise stay paused.  This will clear a Finished state as well
    } else {
        _stateToResumeAfterSeek = AUMRendererAudioFileSource::Paused;
    }
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioFileSource::updateSource()
{
    _processPendingSeeks();
    _replenishBufferFromDisk();
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioFileSource::_clearBuffer()
{
    AUMCircularBufferClear(&_ringBufferL);
    AUMCircularBufferClear(&_ringBufferR);
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioFileSource::_processPendingSeeks()
{
    if (!_seekIsPending) return;
    
    // Sanity check.  Playing shouldnt be if _seekIsPending is true
    if (_state == AUMRendererAudioFileSource::Playing) {
        [NSException raise:NSInternalInconsistencyException format:@"Shouldn't be!"];
    }
    
    // If we're not yet paused then do nothing
    if (_state == AUMRendererAudioFileSource::QueuedToPause) return;
    
    // Otherwise do the deed.  Update the frame positions and re-queue the buffer from disk
    _audioFileReadPosInFrames = _seekToFrameOnNextUpdate;
    _bufferReadPosInFrames = _seekToFrameOnNextUpdate;
    _clearBuffer();
    _replenishBufferFromDisk();
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioFileSource::_replenishBufferFromDisk()
{
    // Log finished sources
    if (_state == AUMRendererAudioFileSource::Finished) {
        MMLogDetail("Source %p: Finished playback.", this);
    }
    
    
    // Check that we're actually playing a file and the EOF hasn't been reached
    if (_state != AUMRendererAudioFileSource::Playing or _isEOF) { return; }
    
    
    // See if we have enough frames in the ring buffer...
    int32_t availBytes;
    AUMCircularBufferTail(&_ringBufferL, &availBytes);  // L & R should be the same
    NSUInteger framesRemainingInBuffer = (NSUInteger)(availBytes / _bytesPerFrame);
    
    if (framesRemainingInBuffer > _bufferDepletedThresholdInFrames) { return; }
    
    
    // Otherwise fill 'er up
    int32_t freeBytes;
    int32_t framesToLoad = _bufferSizeInFrames - framesRemainingInBuffer;
    int32_t bytesToLoad = framesToLoad * _bytesPerFrame;
    
    // Get the buffer head and number of available bytes
    void *bufferHeadL = AUMCircularBufferHead(&_ringBufferL, &freeBytes);
    void *bufferHeadR = AUMCircularBufferHead(&_ringBufferR, &freeBytes);
    
    // Not enough space?  Throw exception! Programmer error.
    if (freeBytes < bytesToLoad) {
        [NSException raise:NSInvalidArgumentException format:@"Not enough space available in buffer! Check with ::framesRemainingInBuffer() first!"];
    }
    
    NSUInteger framesLoaded = [_audioFile readFrames:framesToLoad fromFrame:_audioFileReadPosInFrames intoBufferL:bufferHeadL bufferR:bufferHeadR];
    
    
    // Update streamFile read position and consume the bytes
    _audioFileReadPosInFrames += framesLoaded;
    int32_t bytesLoaded = framesLoaded * _bytesPerFrame;
    AUMCircularBufferProduce(&_ringBufferL, bytesLoaded);
    AUMCircularBufferProduce(&_ringBufferR, bytesLoaded);
    
    // Are we at EOF?
    if (framesLoaded < framesToLoad) {
        _isEOF = true;
        MMLogDetail("Source %p: EOF reached.", this);
    }
}


/// @}
