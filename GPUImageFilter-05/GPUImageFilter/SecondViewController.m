//
//  Second ViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/5/3.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "SecondViewController.h"
#import "ImageShowViewController.h"
#import <GPUImage.h>

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong)  GPUImageFilter *filter;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    [_imageView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];

    // 滤镜
    _filter = [[GPUImageGrayscaleFilter alloc] init];
    
    // 初始化
    _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    [_camera addTarget:_filter];
    [_filter addTarget:_imageView];
    
    // 开始运行
    [_camera startCameraCapture];
}

- (IBAction)pictureButtonTapped:(UIButton *)sender
{
    if ([_camera isRunning]) {
        [_camera capturePhotoAsImageProcessedUpToFilter:_filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            [_camera stopCameraCapture];
            
            ImageShowViewController *imageShowVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ImageShowViewController"];
            imageShowVC.image = processedImage;
            [self presentViewController:imageShowVC animated:YES completion:NULL];
        }];
    }else {
        [_camera startCameraCapture];
    }
}


@end
