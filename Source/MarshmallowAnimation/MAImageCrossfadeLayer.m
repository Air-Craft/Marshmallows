//
//  MAImageCrossfadeLayer.m
//  SoundWand
//
//  Created by Hari Karam Singh on 13/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAImageCrossfadeLayer.h"

@implementation MAImageCrossfadeLayer

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////


+ (id)layerWithImages:(NSArray *)theImages fadeDuration:(CFTimeInterval)theDuration 
{
    id newLayer = [[self alloc] initWithImages:theImages fadeDuration:theDuration];
    return newLayer;
}

/////////////////////////////////////////////////////////////////////////

- (id)initWithImages:(NSArray *)theImages fadeDuration:(CFTimeInterval)theDuration
{
    // Prep for super call...
    // Create a sublayer for each image
    NSMutableArray *imgLayers = [NSMutableArray arrayWithCapacity:theImages.count];
    
    for (UIImage *img in theImages) {
        MAImageLayer *layer = [MAImageLayer layerWithImage:img];
        layer.anchorPoint = CGPointMake(0, 0);
        
        [imgLayers addObject:layer];
    }

    // Call the super
    return [super initWithLayers:imgLayers fadeDuration:theDuration];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)showImageAtIndex:(NSUInteger)theIdx
{
    [self showLayerAtIndex:theIdx];
}

@end
