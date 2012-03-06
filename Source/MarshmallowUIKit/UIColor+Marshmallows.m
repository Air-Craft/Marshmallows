//
//  UIColor+Marshmallows.m
//  SoundWand
//
//  Created by  on 06/03/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#import "UIColor+Marshmallows.h"
#import "MarshmallowMath.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - UIColor (Marshmallows)
/////////////////////////////////////////////////////////////////////////

@implementation UIColor (Marshmallows)


- (UIColor *)colorAugmentedByHueFactor:(CGFloat)hueK saturationFactor:(CGFloat)satK brightnessFactor:(CGFloat)brightK alphaFactor:(CGFloat)alphaK hueShift:(CGFloat)hueN saturationShift:(CGFloat)satN brightnessShift:(CGFloat)brightN alphaShift:(CGFloat)alphaN
{
    CGFloat h, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    
    h = hueK * h + hueN;
    s = satK * s + satN;
    b = brightK * b + brightN;
    a = alphaK * a + alphaN;
    
    h = MM_Wrap(h, 0, 1);
    s = MM_Clamp(s, 0, 1);
    b = MM_Clamp(b, 0, 1);
    a = MM_Clamp(a, 0, 1);
    
    return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
}

/////////////////////////////////////////////////////////////////////////

- (UIColor *)colorBrightenedByFactor:(CGFloat)brightK
{
    return [self colorAugmentedByHueFactor:1 saturationFactor:1 brightnessFactor:brightK alphaFactor:0 hueShift:0 saturationShift:0 brightnessShift:0 alphaShift:0];
}

@end
