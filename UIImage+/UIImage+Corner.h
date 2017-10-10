//
//  UIImage+Corner.h
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Corner)

// 圆角绘制
- (UIImage*)imageWithConrnerWithRadius:(CGFloat)radius sizeToFit:(CGSize)size;

@end
