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

void AUMRendererAudioSource::initializeBuffer(NSInteger bufferSizeInBytes, NSInteger bytesPerFrame)
{
    // bufferSizeInBytes should represent the entire buffer size so divide by 2 first as we have 2 non-interleaved channels.  This aspect is independent of the any feeding files interleaved state as this source class assumes you'll feed it stereo non-interleaved.
    _bufferSizeInFrames = bufferSizeInBytes / (bytesPerFrame * 2);
    _bytesPerFrame = bytesPerFrame;
    
    // Init our ring buffers.  Use the potentially truncated _bufferSizeInFrames to calculate the numbers
    AUMCircularBufferInit(&_ringBufferL, _bufferSizeInFrames * _bytesPerFrame);
    AUMCircularBufferInit(&_ringBufferR, _bufferSizeInFrames * _bytesPerFrame);
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioSource::play()
{
    if (_state == AUMRendererAudioSource::Finished) {
        [NSException raise:NSInternalInconsistencyException format:@"Source can't be played once in Finished state."];
    }
    
    // If QueuedToPause, spin lock until the RCB finishes
    while (_state == AUMRendererAudioSource::QueuedToPause)
        sleep(1);   // 1ms
    
    // Now its safe to set playing state
    _state = AUMRendererAudioSource::Playing;
}

/////////////////////////////////////////////////////////////////////////

void AUMRendererAudioSource::pause()
{
    if (_state == AUMRendererAudioSource::Finished) {
        [NSException raise:NSInternalInconsistencyException format:@"Source can't be paused once in Finished state."];
    }
    
    if (_state == AUMRendererAudioSource::Paused) {
        MMLogWarn(@"Source paused when already in Paused state");
        return;
    }
    
    if (_state == AUMRendererAudioSource::QueuedToPause) {
        MMLogWarn(@"Source paused when already in QueuedToPause state");
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
