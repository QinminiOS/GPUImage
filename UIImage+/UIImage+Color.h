//
//  UIImage+Color.h
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

/** 灰度图 */
- (UIImage *)grayImage;

/** 根据颜色生成图片 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/** 取图片某像素的颜色 */
- (UIColor *)colorAtPixel:(CGPoint)point;

@end
