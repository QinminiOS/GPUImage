//
//  UIImage+Clip.h
//
//  Created by qinmin on 2016/4/13.
//  Copyright © 2016年 qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Clip)

+ (UIImage *)clipImage:(UIImage *)aImage CGBlendMode:(int)type;
+ (UIImage *)clipImage:(UIImage *)image withRect:(CGRect)rect;

+ (UIImage *)cropImage:(UIImage *)image
                 frame:(CGRect)frame
                 angle:(NSInteger)angle
          circularClip:(BOOL)circular;

@end
