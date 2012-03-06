//
//  MAImageCrossfadeLayer.h
//  SoundWand
//
//  Created by Hari Karam Singh on 13/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MAImageLayer.h"
#import "MACrossfadeLayer.h"

/**
 Handles crossfading of a series of images.
 \todo Not tested since abstracting to MACrossfadeLayer subclass
 */
@interface MAImageCrossfadeLayer : MACrossfadeLayer 


+ (id)layerWithImages:(NSArray *)theImages fadeDuration:(CFTimeInterval)theDuration;
- (id)initWithImages:(NSArray *)theImages fadeDuration:(CFTimeInterval)theDuration;

/// Convenience method for clarity.  Just calls super::showLayerAtIndex:
- (void)showImageAtIndex:(NSUInteger)theIdx;

@end
