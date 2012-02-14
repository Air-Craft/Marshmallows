//
//  MAImageCrossfadeLayer.m
//  SoundWand
//
//  Created by Hari Karam Singh on 13/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAImageCrossfadeLayer.h"

@implementation MAImageCrossfadeLayer

@synthesize images, activeImageIndex, fadeDuration;

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Class Methods

+ (id)layerWithImages:(NSArray *)theImages fadeDuration:(CFTimeInterval)theDuration 
{
    MAImageCrossfadeLayer *newLayer = [[self alloc] initWithImages:theImages fadeDuration:theDuration];
    return newLayer;
}


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Life Cycle

- (id)initWithImages:(NSArray *)theImages fadeDuration:(CFTimeInterval)theDuration
{
    if (self = [super init]) {
        fadeDuration = theDuration;
        
        // Create a sublayer for each image and set opacity to 0.
        // Get the maximum bounds for the images
        CGSize maxSize = CGSizeMake(0, 0);
        for (UIImage *img in theImages) {
            MAImageLayer *layer = [MAImageLayer layerWithImage:img];
            layer.opacity = 0;
            layer.anchorPoint = CGPointMake(0, 0);
            
            // Update the max size property
            if (layer.bounds.size.width > maxSize.width)
                maxSize.width = layer.bounds.size.width;
            if (layer.bounds.size.height > maxSize.height)
                maxSize.height = layer.bounds.size.height;
            
            layer.contentsScale = self.contentsScale;
            [self addSublayer:layer];
        }
        self.bounds = CGRectMake(0, 0, maxSize.width, maxSize.height);
        
        // Show the first layer
        ((MAImageLayer *)[[self sublayers] objectAtIndex:0]).opacity = 1.0;
        activeImageIndex = 0;
    }
    return self;
}

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Superclass Overrides

/// Update content scale for all sublayers
- (void)setContentsScale:(CGFloat)contentsScale 
{
    for (CALayer *l in self.sublayers) {
        l.contentsScale = contentsScale;
    }
    [super setContentsScale:contentsScale];
}

/** ********************************************************************/

/// Override to set additional properties
- (id)initWithLayer:(id)layer 
{
    if (self = [super initWithLayer:layer]) {
        images = self.images;
    }
    return self;
}

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Public API

- (void)showImageN:(NSUInteger)theIdx
{
    NSAssert((theIdx < [[self sublayers] count]), @"Max index exceeded [%u, max=%u]", theIdx, [[self sublayers] count]);
    
    // Nothing to do if it's already the active one
    if (activeImageIndex == theIdx)
        return;
    
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:fadeDuration];
    
    // Fade out all which are being faded
    for (NSUInteger i=0; i<[[self sublayers] count]; i++) {
        // Nothing for layer to be made active
        if (i == theIdx)
            continue;
        
        // Get the layer 
        CALayer *l = [[self sublayers] objectAtIndex:i];
        l.opacity = 0;
    }

    // Fade in the active layer 
    CALayer *activeLayer = [[self sublayers] objectAtIndex:theIdx];
    activeLayer.opacity = 1.0;
    activeImageIndex = theIdx;
    [CATransaction commit];
}

@end
