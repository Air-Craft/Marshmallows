/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */

#import "AUMRendererAudioSource.h"
#import "MarshmallowDebug.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioSource::initializeBuffer(NSInteger bufferSizeInFrames, NSInteger bytesPerFrame)
{
    _bufferSizeInFrames = bufferSizeInFrames;
    _bytesPerFrame = bytesPerFrame;
    
    // Init our ring buffers
    AUMCircularBufferInit(&_ringBufferL, _bufferSizeInFrames * _bytesPerFrame);
    AUMCircularBufferInit(&_ringBufferR, _bufferSizeInFrames * _bytesPerFrame);
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioSource::play()
{
    if (_state != AUMRendererAudioSource::Paused) {
        [NSException raise:NSInternalInconsistencyException format:@"Source must be in 'Paused' state in order to play"];
    }
    
    _state = AUMRendererAudioSource::Playing;
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioSource::pause()
{
    if (_state != AUMRendererAudioSource::Playing or
        _state != AUMRendererAudioSource::QueuedToPause) {
        [NSException raise:NSInternalInconsistencyException format:@"Source must be in 'Playing' state (or even 'QueuedToPause' we'll allow) in order to 'pause'"];
    }
    
    _state = AUMRendererAudioSource::QueuedToPause;
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioSource::reset()
{
    clearBuffer();
    _volume = 1;
    _pitch = 1;
}

/////////////////////////////////////////////////////////////////////////

NSUInteger AUMRendererAudioSource::framesRemainingInBuffer()
{
    // Check the buffers have been initialised
    if (!_ringBufferL.buffer) {
        [NSException raise:NSInternalInconsistencyException format:@"Must initialise the buffer before calling this method"];
    }
    
    int32_t availBytes;
    AUMCircularBufferTail(&_ringBufferL, &availBytes);  // L & R should be the same
    return (NSUInteger)(availBytes / _bytesPerFrame);
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioSource::pointersToBufferHeads(void **bufferPtrL, void **bufferPtrR)
{
    // Check the buffers have been initialised
    if (!_ringBufferL.buffer) {
        [NSException raise:NSInternalInconsistencyException format:@"Must initialise the buffer before calling this method"];
    }
    
    int32_t freeBytes;
    *bufferPtrL = AUMCircularBufferHead(&_ringBufferL, &freeBytes);
    *bufferPtrR = AUMCircularBufferHead(&_ringBufferR, &freeBytes);
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioSource::indicateFramesWrittenToBuffer(NSUInteger framesWritten)
{
    // Check the buffers have been initialised
    if (!_ringBufferL.buffer) {
        [NSException raise:NSInternalInconsistencyException format:@"Must initialise the buffer before calling this method"];
    }
    
    int32_t bytesWritten = framesWritten * _bytesPerFrame;
    AUMCircularBufferProduce(&_ringBufferL, bytesWritten);
    AUMCircularBufferProduce(&_ringBufferR, bytesWritten);
}

/////////////////////////////////////////////////////////////////////////


void AUMRendererAudioSource::clearBuffer()
{
    AUMCircularBufferClear(&_ringBufferL);
    AUMCircularBufferClear(&_ringBufferR);
    _bufferReadPosInFrames = 0;
    _state = AUMRendererAudioSource::Paused;    // Reset state in case finished.
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioSource::setFinished()
{
    _state = AUMRendererAudioSource::Finished;
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////


/// @}
