/** 
 \ingroup    SoundWand
 
 UIColor+Marshmallows.h
 
 \author     Created by  on 06/03/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 \brief 
 */
@interface UIColor (Marshmallows)

/**
 Return a new UIColor with each parameter x mapped to f(x) = Kx + N.  Hue is wrapped, the others' clamped to 0..1.
 */
- (UIColor *)colorAugmentedByHueFactor:(CGFloat)hueK 
                      saturationFactor:(CGFloat)satK 
                      brightnessFactor:(CGFloat)brightK
                           alphaFactor:(CGFloat)alphaK
                              hueShift:(CGFloat)hueN 
                       saturationShift:(CGFloat)satN 
                       brightnessShift:(CGFloat)brightN
                            alphaShift:(CGFloat)alphaN;

/////////////////////////////////////////////////////////////////////////

/// Convenience method for doing just the brightness.  0 < brightK < inf;
- (UIColor *)colorBrightenedByFactor:(CGFloat)brightK;

@end
