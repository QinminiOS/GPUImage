//
//  UIImage+Alpha.m
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import "UIImage+Alpha.h"

@implementation UIImage (Alpha)

//创建上下文对象
static CGContextRef CreateARGBBitmapContextWithCGImage(CGImageRef inImage)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    size_t bitmapBytesPerRow = (pixelsWide * 4);
    size_t bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        return nil;
    }
    
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) {
        CGColorSpaceRelease( colorSpace );
        return nil;
    }
    
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    
    if (context == NULL) {
        fprintf (stderr, "Context not created!");
    }
    
    free (bitmapData);
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

- (NSData *)ARGBData
{
    CGContextRef cgctx = CreateARGBBitmapContextWithCGImage(self.CGImage);
    
    if (cgctx == NULL) {
        return nil;
    }
    
    size_t w = CGImageGetWidth(self.CGImage);
    size_t h = CGImageGetHeight(self.CGImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, self.CGImage);

    void *data = CGBitmapContextGetData (cgctx);
    
    CGContextRelease(cgctx);
    
    if (!data) {
        return nil;
    }
    
    size_t dataSize = 4 * w * h; // ARGB
    
    return [NSData dataWithBytes:data length:dataSize];
}

- (BOOL)isPointTransparent:(CGPoint)point
{
    NSData *rawData = [self ARGBData];
    if (rawData == nil) {
        return NO;
    }

    size_t bitPerPoint = 4;
    size_t bitPerRow = self.size.width * 4;
    
    NSUInteger index = point.x * bitPerPoint + (point.y * bitPerRow);
    
    char *rawDataBytes = ( char *)[rawData bytes];
    
    return rawDataBytes[index] == 0;
}

- (BOOL)hasAlpha
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

- (UIImage *)imageWithAlpha
{
    if ([self hasAlpha]) {
        return self;
    }
    
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

@end
