//
//  UIImage+Alpha.h
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (Alpha)

//是否有alpha通道
- (BOOL)hasAlpha;

//图片的像素值
- (NSData *)ARGBData;

//图片的一个像素point是否透明
- (BOOL)isPointTransparent:(CGPoint)point;

// 返回具有Alpha通道的图片
- (UIImage *)imageWithAlpha;

@end
