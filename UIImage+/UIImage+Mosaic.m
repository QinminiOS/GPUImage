//
//  UIImage+Mosaic.m
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import "UIImage+Mosaic.h"

@implementation UIImage (Mosaic)

- (UIImage *)mosaicImageWithLevel:(int)level
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter= [CIFilter filterWithName:@"CIPixellate"];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    CIVector *vector = [CIVector vectorWithX:self.size.width /2.0f Y:self.size.height /2.0f];
    [filter setDefaults];
    [filter setValue:vector forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithDouble:level] forKey:@"inputScale"];
    [filter setValue:inputImage forKey:@"inputImage"];
    
    CGImageRef cgiimage = [context createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage scale:self.scale orientation:self.imageOrientation];
    
    CGImageRelease(cgiimage);
    
    return newImage;
}

- (UIImage *)mosaicDefaultImage
{
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:self.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setDefaults];
    CIVector *vector = [CIVector vectorWithX:self.size.width /2.0f Y:self.size.height /2.0f];

    [filter setValue:vector forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithDouble:24] forKey:@"inputScale"];
    

    
    CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
    
    // 2. 用CIContext将滤镜中的图片渲染出来
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outImage fromRect:[ciImage extent]];
    
    // 3. 导出图片
    UIImage *showImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return showImage;
}

@end
