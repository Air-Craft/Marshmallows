//
//  MAImageLayer.h
//  SoundWand
//
//  Created by Hari Karam Singh on 13/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MAImageLayer : CALayer 

@property (strong, atomic, readonly) UIImage *image;

+ (id)layerWithImage:(UIImage *)theImage;
+ (id)layerWithImageNamed:(NSString *)theImageName;

- (id)initWithImage:(UIImage *)theImage;

@end
