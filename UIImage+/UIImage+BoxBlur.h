//
//  UIImage+BoxBlur.h
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BoxBlur)

// Level in 0 ~ 1.0
+ (UIImage *)boxBlurImage:(UIImage *)image withLevel:(CGFloat)level;
@end
