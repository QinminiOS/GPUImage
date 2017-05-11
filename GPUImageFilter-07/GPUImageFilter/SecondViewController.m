//
//  Second ViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/5/3.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "SecondViewController.h"
#import "QMImageHelper.h"
#import "QMGrayBilateralBlendFilter.h"
#import <GPUImage.h>

#define DOCUMENT(path) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path]


@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (strong, nonatomic) QMGrayBilateralBlendFilter *filter;
@end

@implementation SecondViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    [_imageView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
}

- (IBAction)textureInputButtonTapped:(UIButton *)sender
{
    // 加载图片
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];

    // 滤镜组合
    _filter = [[QMGrayBilateralBlendFilter alloc] init];
    
    [picture addTarget:_filter];
    [_filter addTarget:_imageView];
    
    [picture processImage];
}

@end
