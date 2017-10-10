//
//  UIImage+Blur.h
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)

- (UIImage *)gaussianBlurImageWithLevel:(CGFloat)blur;

@end
