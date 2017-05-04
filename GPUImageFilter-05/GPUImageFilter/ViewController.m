//
//  ViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/2/4.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>

#define DOCUMENT(path) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path]

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (strong, nonatomic) GPUImageVideoCamera *video;
@property (strong, nonatomic) GPUImageMovieWriter *writer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    [_imageView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];

    // 设置保存文件路径
    NSURL *file = [NSURL fileURLWithPath:DOCUMENT(@"/1.mov")];
    [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
    
    // 设置GPUImageMovieWriter
    _writer = [[GPUImageMovieWriter alloc] initWithMovieURL:file size:CGSizeMake(480, 640)];
    [_writer setHasAudioTrack:YES audioSettings:nil];
    
    // 设置GPUImageVideoCamera
    _video = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _video.outputImageOrientation = UIInterfaceOrientationPortrait;
    [_video addAudioInputsAndOutputs];
    
    // 设置音频处理Target
    _video.audioEncodingTarget = _writer;

    // 设置Target
    [_video addTarget:_imageView];
    [_video addTarget:_writer];
    
    // 开始拍摄
    [_video startCameraCapture];
}

- (IBAction)startButtonTapped:(UIButton *)sender
{
    // 开始录制视频
    [_writer startRecording];
}

- (IBAction)finishButtonTapped:(UIButton *)sender
{
    // 结束录制
    [_writer finishRecording];
}

@end
