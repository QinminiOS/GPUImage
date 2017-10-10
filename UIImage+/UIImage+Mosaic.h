//
//  UIImage+Mosaic.h
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Mosaic)

/**
 返回马赛克图片
 @param level 以多少像素为一个格子
 @return UIImage
 */
- (UIImage *)mosaicImageWithLevel:(int)level;

/**
 返回level为8的马赛克图片
 @return UIImage
 */
- (UIImage *)mosaicDefaultImage;

@end
