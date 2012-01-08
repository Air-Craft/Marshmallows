//
//  CEUIImage.m
//  AirPluckGuiDev
//
//  Created by Hari Karam Singh on 01/01/2012.
//  Copyright (c) 2012 Amritvela / Club 15CC.  MIT License.
//

#import "UIImage+MMPixelData.h"


@implementation UIImage (MMPixelData)

- (NSData *)getRawImageData
{
    // First get the image into your data buffer
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger dataSize = height * width * MM_UIIMAGE_BYTES_PER_PIXEL;
    unsigned char *rawData = malloc(dataSize);
    NSUInteger bytesPerRow = width * MM_UIIMAGE_BYTES_PER_PIXEL;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    NSData *rtn = [NSData dataWithBytes:rawData length:dataSize];
    free(rawData);
    return rtn;
}

/**********************************************************************/

- (UIColor *)samplePixelColorAtX:(NSUInteger)xCoord andY:(NSUInteger)yCoord 
{
    NSAssert(xCoord < self.size.width, @"Out of range!"); // 0 
    NSAssert(yCoord < self.size.height, @"Out of range!");
             
    // Get the raw data
    NSData *imgData = [self getRawImageData];
    if (!imgData) return nil;
    
    // Calculate the byte offset
    NSUInteger byteIndex = MM_UIIMAGE_BYTES_PER_PIXEL * (self.size.width * yCoord + xCoord);
    
    // Read in the 4 pixel bytes and scale to 0...1
    unsigned char rgbaData[4];
    NSRange range = { byteIndex, 4u };
    [imgData getBytes:rgbaData range:range];
    CGFloat red   = rgbaData[0] / 255.0;
    CGFloat green = rgbaData[1] / 255.0;
    CGFloat blue  = rgbaData[2] / 255.0;
    CGFloat alpha = rgbaData[3] / 255.0;
    
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/**********************************************************************/

- (NSArray *)sampleNPixelColorsHorizontally:(NSUInteger)n 
                                      onRowY:(NSUInteger)theY 
                              inXRange:(NSRange)theXRange
{
    // Sanity checks
    NSAssert(theY <= self.size.height, @"Out of range!");
    NSAssert((theXRange.location + theXRange.length) <= self.size.width, @"The range exceeds the maximum width!");
    NSAssert(n < theXRange.length, @"The request sample count exceeds the number of pixels in the specifed range");
    
    NSMutableArray *sampledColors = [NSMutableArray array];
    
    // Get the raw data
    NSData *imgData = [self getRawImageData];
    if (!imgData) return nil;
    
    // Calculate the width of the sample range
    float sampleColumnSpacing = (float)(theXRange.length - 1) / (float)(n - 1);
    
    unsigned char rgbaData[4];
    for (NSUInteger i=0; i<n; i++) {
        NSUInteger xPos = roundf(i * sampleColumnSpacing + theXRange.location);
        NSUInteger byteIndex = MM_UIIMAGE_BYTES_PER_PIXEL * (self.size.width * theY + xPos);
        
        // Read in the 4 pixel bytes and scale to 0...1
        NSRange range = { byteIndex, 4u };
        [imgData getBytes:rgbaData range:range];
        CGFloat red   = rgbaData[0] / 255.0;
        CGFloat green = rgbaData[1] / 255.0;
        CGFloat blue  = rgbaData[2] / 255.0;
        CGFloat alpha = rgbaData[3] / 255.0;
        
        [sampledColors addObject: [UIColor colorWithRed:red green:green blue:blue alpha:alpha]];
    }
    
    return [NSArray arrayWithArray:sampledColors];
}

/**********************************************************************/

- (NSArray *)sampleNPixelColorsHorizontally:(NSUInteger)n onRowY:(NSUInteger)theY 
{
    return [self sampleNPixelColorsHorizontally:n onRowY:theY inXRange:NSMakeRange(0, self.size.width - 1)];
}

@end
