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

@interface MAImageCrossfadeLayer : CALayer 

@property (atomic, strong, readonly) NSArray *images;
@property (atomic) CFTimeInterval fadeDuration; // dont call it duration!
@property (atomic) NSUInteger activeImageIndex;

+ (id)layerWithImages:(NSArray *)theImages fadeDuration:(CFTimeInterval)theDuration;

- (id)initWithImages:(NSArray *)theImages fadeDuration:(CFTimeInterval)theDuration;

- (void)showImageN:(NSUInteger)theIdx;

@end
