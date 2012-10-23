/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 23/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AUMFileRecordingRenderer.h
 
 
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AUMRendererProtocol.h"
#import "AUMTypes.h"

/**
 \brief 
 */
@interface AUMFileRecordingRenderer : NSObject <AUMRendererProtocol>

/** Setting opens a new file for output
 \throws kAUMAudioFileException on error closing any previous file or creating the new one
 */
@property (nonatomic, strong, readonly) NSURL *outputFileURL;
@property (nonatomic) AudioStreamBasicDescription inputStreamFormat;


- (void)newOutputFileWithURL:(NSURL *)aURL withFileFormat:(AUMAudioFileFormatDescription)aFileFormat;

- (void)record;
- (void)stop;


@end

/// @}