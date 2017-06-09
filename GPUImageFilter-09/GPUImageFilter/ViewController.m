//
//  ViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/2/4.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "ViewController.h"
#import "QMImageHelper.h"
#import <GPUImage.h>
#import "QMFishEyeFilter.h"
#import "QM3DLightFilter.h"

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
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
    
    QMFishEyeFilter *filter = [[QMFishEyeFilter alloc] init];
    
    [picture addTarget:filter];
    [filter addTarget:_imageView];
    
    [picture processImage];
}

- (IBAction)filterButtonTapped:(UIButton *)sender
{
    // 加载图片
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
    
    QM3DLightFilter *filter = [[QM3DLightFilter alloc] init];
    
    [picture addTarget:filter];
    [filter addTarget:_imageView];
    
    [picture processImage];
}

@end
