/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */
/// \file AUMFilePlayerUnit.h
 
#import <Foundation/Foundation.h>
#import "MarshmallowConcurrency.h"
#import "AUMTypes.h"
#import "AUMGeneratorRendererProtocol.h"
#import "AUMRemoteIOUnit.h"

/**
 \brief Our very own hi-performance file player unit which boasts the ability to use your own update thread.  Does NOT use Apple's FilePlayer AU
 
 \todo Init w/o thread details auto creates (shared) thread like the Apple AU version
 \todo Spin locks for pause method and also perhaps file change method to simplify in these less realtime events? (keep on-the-fly for seek though)
 
 \section Concurrency Considerations
 Any public method which acts on _audioSource and/or _audioFile must be syncro'ed with the thread's update methods.  Otherwise file change and seek operations could lead to collisions
 */

 

@interface AUMFilePlaybackGenerator : NSObject <AUMGeneratorRendererProtocol>

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

@property (nonatomic) BOOL loop;
@property (nonatomic) AUMAudioControlParameter volume;

/** Disable to prevent the source from auto-rewinding (and re-buffering) when finished. Default=YES*/
@property (nonatomic) BOOL autoRewindOnFinished;

@property (atomic, copy) void (^cbPlaybackFinished)(AUMFilePlaybackGenerator *sender);
@property (atomic, copy) void (^cbPlaybackDidOccur)(AUMFilePlaybackGenerator *sender, NSUInteger frame, NSTimeInterval time);

/** Defaults to 0.5 seconds */
@property (nonatomic) NSTimeInterval playbackDidOccurUpdateInterval;

/** Whether the file is currently playing.  Note, a call to [pause] will immediately be reflected in this property but the audio won't actually stop for another moment while the RCB finishes its rendering round */ 
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) NSTimeInterval playheadPosTime;
@property (nonatomic, readonly) NSUInteger playheadPosFrames;

@property (nonatomic, readonly) NSUInteger audioFileLengthInFrames;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

/** Convenience method which will check AUMAudioSession to get the sample rate and IOBufferDuration and defaults to 64kB diskBuffer  size
 \throws NSException::NSInternalInconsistencyException if AudioSession not initiliased with sample rate and IOBufferDuration */
- (id)initWithDiskBufferSizeInFrame:(NSUInteger)aDiskBufferSizeInFrames
                       updateThread:(id<MCThreadProxyProtocol>)anUpdateThread updateInterval:(NSTimeInterval)anUpdateInterval;
/** Designated init */
- (id)initWithSampleRate:(Float64)theSampleRate
   diskBufferSizeInFrame:(NSUInteger)aDiskBufferSizeInFrames
        ioBufferDuration:(NSTimeInterval)theIOBufferDuration
            updateThread:(id<MCThreadProxyProtocol>)anUpdateThread
          updateInterval:(NSTimeInterval)anUpdateInterval;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

-(void)loadAudioFileFromURL:(NSURL *)fileURL;

-(void)play;
-(void)pause;

/** Stops and rewinds */
-(void)stop;

/** Seeks to frame 0.  Playing files will continue to play from 0.  Finished files are reset to Paused state */
-(void)rewind;

-(void)seekToFrame:(NSUInteger)toFrame;


@end

/// @}