#import "MarshmallowsTests.h"
#if DO_UIImageMMPixelDataTests == 1
//
//  UIImageMMPixelDataTests.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 03/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageMMPixelDataTests.h"

@implementation UIImageMMPixelDataTests

- (void)setUp
{
    // Load the gradient image
    NSString *tmpPath = [[NSBundle mainBundle] pathForResource:@"GradientChrome" ofType:@"png" inDirectory:@"TestResources" forLocalization:nil];
    gradientImage = [UIImage imageWithContentsOfFile:tmpPath];
}

- (void)testSamplePixelColorAtX
{
    CGFloat r,g,b,a;
    UIColor *sampledColor;
    
    // 0,0 should be 255,233,196
    sampledColor = [gradientImage samplePixelColorAtX:0 andY:0];
    [sampledColor getRed:&r green:&g blue:&b alpha:&a];
    STAssertEqualsWithAccuracy(r, 250.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(g, 233.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(b, 196.0f/255.0f, 0.01f, nil);
    
    // 239,18 should be 32,99,113
    sampledColor = [gradientImage samplePixelColorAtX:239 andY:18];
    [sampledColor getRed:&r green:&g blue:&b alpha:&a];
    STAssertEqualsWithAccuracy(r, 32.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(g, 99.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(b, 113.0f/255.0f, 0.01f, nil);
    
    // Test out of range
    STAssertThrows([gradientImage samplePixelColorAtX:300 andY:0], @"Should be out of range"); // width
    STAssertThrows([gradientImage samplePixelColorAtX:0 andY:46], @"Should be out of range"); // height
    STAssertThrows([gradientImage samplePixelColorAtX:500 andY:1000], @"Should be out of range"); // both
}

- (void)testSamplePixelColorsHorizontally
{
    CGFloat r,g,b,a;
    NSArray *sampledColors;
    
    // Test full range first
    sampledColors = [gradientImage sampleNPixelColorsHorizontally:3 
                                                           onRowY:0];
    STAssertEquals([sampledColors count], 3u, nil);
    
    [[sampledColors objectAtIndex:0] getRed:&r green:&g blue:&b alpha:&a];
    STAssertEqualsWithAccuracy(r, 250.0f/255.0f, 0.1f, nil);
    STAssertEqualsWithAccuracy(g, 233.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(b, 196.0f/255.0f, 0.01f, nil);
    
    [[sampledColors objectAtIndex:1] getRed:&r green:&g blue:&b alpha:&a];
    STAssertEqualsWithAccuracy(r, 212.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(g, 199.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(b, 86.0f/255.0f, 0.01f, nil);
    
    [[sampledColors objectAtIndex:2] getRed:&r green:&g blue:&b alpha:&a];
    STAssertEqualsWithAccuracy(r, 202.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(g, 224.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(b, 246.0f/255.0f, 0.01f, nil);
    
    // Test second half
    sampledColors = [gradientImage sampleNPixelColorsHorizontally:2 
                                                           onRowY:1 
                                                         inXRange:NSMakeRange(150, 150)];
    
    [[sampledColors objectAtIndex:0] getRed:&r green:&g blue:&b alpha:&a];
    STAssertEqualsWithAccuracy(r, 212.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(g, 199.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(b, 86.0f/255.0f, 0.01f, nil);
    
    [[sampledColors objectAtIndex:1] getRed:&r green:&g blue:&b alpha:&a];
    STAssertEqualsWithAccuracy(r, 202.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(g, 224.0f/255.0f, 0.01f, nil);
    STAssertEqualsWithAccuracy(b, 246.0f/255.0f, 0.01f, nil);
}


@end

#endif
