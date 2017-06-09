//
//  QMRotationFilter.h
//  GPUImageFilter
//
//  Created by qinmin on 2017/6/8.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import <GPUImage.h>

@interface QMFishEyeFilter : GPUImageFilter

@property (nonatomic, assign) GLfloat radius;

- (instancetype)init;

@end
