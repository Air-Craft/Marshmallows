//
//  MACrossfadeLayer.m
//  SoundWand
//
//  Created by  on 04/03/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#import "MACrossfadeLayer.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - MACrossfadeLayer
/////////////////////////////////////////////////////////////////////////

@implementation MACrossfadeLayer

@synthesize activeLayerIndex, fadeDuration;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

+ (id)layerWithLayers:(NSArray *)theLayers fadeDuration:(CFTimeInterval)theDuration
{
    id newLayer = [[self alloc] initWithLayers:theLayers fadeDuration:theDuration];
    return newLayer;
}

/////////////////////////////////////////////////////////////////////////

- (id)initWithLayers:(NSArray *)theLayers fadeDuration:(CFTimeInterval)theDuration
{
    if (self = [super init]) {
        fadeDuration = theDuration;
        
        // Get the max size of the underlying layers and set our bounds accordingly
        // Add a sublayer for each and set opacity to 0.
        CGSize maxSize = CGSizeMake(0, 0);
        for (CALayer *layer in theLayers) {

            layer.opacity = 0;
            
            //Let user set this?
            //layer.anchorPoint = CGPointMake(0, 0); 
            
            // Update the max size property
            if (layer.bounds.size.width > maxSize.width)
                maxSize.width = layer.bounds.size.width;
            if (layer.bounds.size.height > maxSize.height)
                maxSize.height = layer.bounds.size.height;
            
            // should we let the user set this too?
            layer.contentsScale = self.contentsScale;
            
            [self addSublayer:layer];
        }
        
        // Update our bounds
        self.bounds = CGRectMake(0, 0, maxSize.width, maxSize.height);
        
        // Show the first layer and init the index tracker
        ((CALayer *)[[self sublayers] objectAtIndex:0]).opacity = 1.0;
        activeLayerIndex = 0;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass Overrides
/////////////////////////////////////////////////////////////////////////

/// Update content scale for all sublayers
- (void)setContentsScale:(CGFloat)contentsScale 
{
    for (CALayer *l in self.sublayers) {
        l.contentsScale = contentsScale;
    }
    [super setContentsScale:contentsScale];
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)addLayer:(CALayer *)layer
{
    layer.opacity = 0;
    
    // Update the max size property	
    CGSize currentSize = self.bounds.size;
    if (layer.bounds.size.width > currentSize.width)
        currentSize.width = layer.bounds.size.width;
    if (layer.bounds.size.height > currentSize.height)
        currentSize.height = layer.bounds.size.height;
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, currentSize.width, currentSize.height);
    
    // should we let the user set this too?
    layer.contentsScale = self.contentsScale;
    
    [self addSublayer:layer];
}

/////////////////////////////////////////////////////////////////////////

- (void)showLayerAtIndex:(NSUInteger)theIdx
{
    // Nothing to do if it's already the active one
    if (activeLayerIndex == theIdx)
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
    activeLayerIndex = theIdx;
    
    [CATransaction commit];

}

/////////////////////////////////////////////////////////////////////////

- (void)hideAll
{
    // Fade out all which are being faded
    for (NSUInteger i=0; i<[[self sublayers] count]; i++) {        
        // Get the layer 
        CALayer *l = [[self sublayers] objectAtIndex:i];
        l.opacity = 0;
    }
}



@end
