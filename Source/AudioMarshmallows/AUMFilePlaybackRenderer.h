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
#import "AUMRendererProtocol.h"
#import "AUMRemoteIOUnit.h"

/**
 \brief Our very own hi-performance file player unit which boasts the ability to use your own update thread.  Does NOT use Apple's FilePlayer AU
 
 \todo Init w/o thread details auto creates (shared) thread like the Apple AU version
 
 \section Concurrency Considerations
 Any public method which acts on _audioSource and/or _audioFile must be syncro'ed with the thread's update methods.  Otherwise file change and seek operations could lead to collisions
 */
@interface AUMFilePlaybackRenderer : NSObject <AUMRendererProtocol>

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

@property (nonatomic) BOOL loop;
@property (nonatomic) AUMAudioControlParameter volume;
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

-(void)play;
-(void)pause;
-(void)seekToFrame:(NSUInteger)toFrame;
-(void)loadAudioFileFromURL:(NSURL *)fileURL;


@end

/// @}