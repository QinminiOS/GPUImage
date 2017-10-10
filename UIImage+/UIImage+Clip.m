//
//  UIImage+Clip.m
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import "UIImage+Clip.h"

@implementation UIImage (Clip)

static CGContextRef CreateRGBABitmapContextWithCGImage(CGImageRef aCGImage)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    unsigned char *bitmapData = NULL;
    
    size_t widthPixels = CGImageGetWidth(aCGImage);
    size_t higthPixels = CGImageGetHeight(aCGImage);
    size_t allPixels = widthPixels * higthPixels;
    size_t allBytes = allPixels * 4;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL) {
        return NULL;
    }
    
    bitmapData = malloc(allBytes);
    memset(bitmapData, 0, allBytes);
    
    if (bitmapData == NULL) {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    
    context = CGBitmapContextCreate(bitmapData,
                                    widthPixels,
                                    higthPixels,
                                    8,
                                    widthPixels * 4,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);
    if (context == NULL) {
        fprintf (stderr, "Context not created!");
    }
    
    free (bitmapData);
    bitmapData = NULL;
    
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

+ (UIImage *)clipImage:(UIImage *)aImage CGBlendMode:(int)type
{
    CGContextRef context = CreateRGBABitmapContextWithCGImage(aImage.CGImage);
    
    if (context == NULL) {
        return nil;
    }
    
    size_t w = CGImageGetWidth(aImage.CGImage);
    size_t h = CGImageGetHeight(aImage.CGImage);
    CGRect rect = {{0, 0}, {w, h}};
    
    CGContextSetBlendMode(context, type);
    CGContextDrawImage(context, rect, aImage.CGImage);
    
    
    CGImageRef aCGImage = CGBitmapContextCreateImage(context);
    
    UIImage *newImage = [UIImage imageWithCGImage:aCGImage];
    
    CGImageRelease(aCGImage);
    CGContextRelease(context);
    
    return newImage;
}

+ (UIImage *)clipImage:(UIImage *)image withRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *tmpImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return tmpImage;
}

+ (UIImage *)cropImage:(UIImage *)image
                 frame:(CGRect)frame
                 angle:(NSInteger)angle
          circularClip:(BOOL)circular
{
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
                     alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaPremultipliedLast);
    
    UIImage *croppedImage = nil;
    UIGraphicsBeginImageContextWithOptions(frame.size, !hasAlpha && !circular, [UIScreen mainScreen].scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (circular) {
            CGContextAddEllipseInRect(context, (CGRect){CGPointZero, frame.size});
            CGContextClip(context);
        }
        
        //To conserve memory in not needing to completely re-render the image re-rotated,
        //map the image to a view and then use Core Animation to manipulate its rotation
        if (angle != 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.layer.minificationFilter = kCAFilterNearest;
            imageView.layer.magnificationFilter = kCAFilterNearest;
            imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle * (M_PI/180.0f));
            CGRect rotatedRect = CGRectApplyAffineTransform(imageView.bounds, imageView.transform);
            UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, rotatedRect.size}];
            [containerView addSubview:imageView];
            imageView.center = containerView.center;
            CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
            [containerView.layer renderInContext:context];
        }
        else {
            CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
            [image drawAtPoint:CGPointZero];
        }
        
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:croppedImage.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
}

@end
