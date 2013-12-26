/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 01/01/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{
 */

#import "UIImage+Marshmallows.h"


@implementation UIImage (Marshmallows)

/////////////////////////////////////////////////////////////////////////
#pragma mark - Pixel Processing
/////////////////////////////////////////////////////////////////////////
/** @name  Pixel Processing */

- (NSData *)getRawImageData
{
    // First get the image into your data buffer
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);//CGColorSpaceCreateDeviceRGB();
    NSUInteger dataSize = height * width * MM_UIIMAGE_BYTES_PER_PIXEL;
    unsigned char *rawData = calloc(width*height, sizeof(GLubyte)*MM_UIIMAGE_BYTES_PER_PIXEL);
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
/// @}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Transformations
/////////////////////////////////////////////////////////////////////////
/** @name  Transformations */

- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    // Get the bounds for the destination images
    CGRect imgRect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, CGAffineTransformMakeRotation(-radians));
    
    // Create the contedt with the correct scale
    UIGraphicsBeginImageContextWithOptions(rotatedRect.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Rotate the context around the centre and draw in he image
    CGContextTranslateCTM(ctx, rotatedRect.size.width/2, rotatedRect.size.height/2);
    CGContextRotateCTM(ctx, -radians);
    [self drawAtPoint:CGPointMake(-imgRect.size.width/2, -imgRect.size.height/2)];
    
    // Get the image to return and cleanup
    UIImage *rtnImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return rtnImg;
}

/////////////////////////////////////////////////////////////////////////

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    return [self imageRotatedByRadians:degrees * (M_PI/180.0f)];
}

/// @}


@end

/// @}
