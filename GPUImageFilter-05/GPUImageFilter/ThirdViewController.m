//
//  ThirdViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/5/5.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "ThirdViewController.h"
#import <GPUImage.h>

#define DOCUMENT(path) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path]

@interface ThirdViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (nonatomic, strong) GPUImageMovie *movie;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, assign) CGSize size;
@end

@implementation ThirdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 获取文件路径
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"1.mp4" withExtension:nil];
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    
    // 获取视频宽高
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = [tracks firstObject];
    _size = videoTrack.naturalSize;

    // 初始化GPUImageMovie
    _movie = [[GPUImageMovie alloc] initWithAsset:asset];
    
    // 滤镜
    _filter = [[GPUImageGrayscaleFilter alloc] init];
    
    [_movie addTarget:_filter];
    [_filter addTarget:_imageView];
}

- (IBAction)playButtonTapped:(UIButton *)sender
{
    [_movie startProcessing];
}

- (IBAction)transcodeButtonTapped:(id)sender
{
    // 文件路径
    NSURL *videoFile = [NSURL fileURLWithPath:DOCUMENT(@"/2.mov")];
    [[NSFileManager defaultManager] removeItemAtURL:videoFile error:nil];
    
    // GPUImageMovieWriter
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:videoFile size:_size];
    [_movieWriter setHasAudioTrack:YES audioSettings:nil];
    
    // GPUImageMovie相关设置
    _movie.audioEncodingTarget = _movieWriter;
    [_filter addTarget:_movieWriter];
    [_movie enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    // 开始转码
    [_movieWriter startRecording];
    [_movie startProcessing];
    
    // 结束
    __weak typeof(_movieWriter) wMovieWriter = _movieWriter;
    __weak typeof(self) wSelf = self;
    [_movieWriter setCompletionBlock:^{
        [wMovieWriter finishRecording];
        [wSelf.movie removeTarget:wMovieWriter];
        wSelf.movie.audioEncodingTarget = nil;
    }];
    
}


@end
