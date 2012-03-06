/** 
 \ingroup    Marshmallows
 
 MACrossfadeLayer.h
 
 \author     Created by  on 04/03/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 \brief Handles crossfading of multiple CALayers
 */
@interface MACrossfadeLayer : CALayer


/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

@property (atomic) NSUInteger activeLayerIndex;
@property (atomic) CFTimeInterval fadeDuration; // warning: dont call it duration!


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

+ (id)layerWithLayers:(NSArray *)theLayers fadeDuration:(CFTimeInterval)theDuration;

- (id)initWithLayers:(NSArray *)theLayers fadeDuration:(CFTimeInterval)theDuration;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

/// Adds a layer (sublayer) to the cross fade set
- (void)addLayer:(CALayer *)layer;

/** Crossfades in the layer at the index */
- (void)showLayerAtIndex:(NSUInteger)theIdx;

- (void)hideAll;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end
