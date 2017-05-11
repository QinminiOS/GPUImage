//
//  ViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/2/4.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "ViewController.h"
#import "PngUtil.h"
#import "QMImageHelper.h"
#import <GPUImage.h>

#define DOCUMENT(path) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path]

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (nonatomic, strong) GPUImageFilterPipeline *pipleLine;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    [_imageView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
}

#pragma mark - Events
- (IBAction)startButtonTapped:(UIButton *)sender
{
    // 加载图片
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];

    // 配置文件
    NSURL *file = [[NSBundle mainBundle] URLForResource:@"filterConfig" withExtension:@"plist"];

    // 滤镜组合
    _pipleLine = [[GPUImageFilterPipeline alloc] initWithConfigurationFile:file input:picture output:_imageView];

    [picture processImage];
}

- (IBAction)finishButtonTapped:(UIButton *)sender
{
    // 加载图片
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"2.jpg"]];

    // filters
    GPUImageRGBFilter *rgbFilter = [[GPUImageRGBFilter alloc] init];
    GPUImagePerlinNoiseFilter *noiseFilter = [[GPUImagePerlinNoiseFilter alloc] init];

    // 配置文件
    NSArray *filters = @[rgbFilter, noiseFilter];

    // 滤镜组合
    _pipleLine = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:filters input:picture output:_imageView];

    [picture processImage];
}

#pragma mark - PrivateMethod

@end
