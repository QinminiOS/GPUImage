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
@property (nonatomic, strong) GPUImageRawDataInput *rawDataInput;
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
    [self showPicture];
}

- (IBAction)finishButtonTapped:(UIButton *)sender
{
    [self writeRGBADataToFile];
}

#pragma mark - PrivateMethod
//- (void)showPicture1
//{
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"png"];
//    
//    // 读取png文件
//    pic_data pngData;
//    read_png_file([filePath UTF8String], &pngData);
//    
//    // 像素格式
//    GPUPixelFormat pixelFormat;
//    switch (pngData.flag) {
//        case PNG_HAVE_ALPHA:
//            pixelFormat = GPUPixelFormatRGBA;
//            break;
//            
//        case PNG_NO_ALPHA:
//            pixelFormat = GPUPixelFormatRGB;
//            break;
//        default:
//            pixelFormat = GPUPixelFormatRGB;
//            break;
//    }
//    
//    // 初始化GPUImageRawDataInput
//    _rawDataInput = [[GPUImageRawDataInput alloc] initWithBytes:pngData.rgba size:CGSizeMake(pngData.width, pngData.height) pixelFormat:pixelFormat];
//    
//    // 滤镜
//    GPUImageCannyEdgeDetectionFilter *filter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
//    [_rawDataInput addTarget:filter];
//    [filter addTarget:_imageView];
//    
//    // 开始处理数据
//    [_rawDataInput processData];
//    
//    // 销毁png数据
//    free_png_data(&pngData);
//}

- (void)showPicture
{
    // 加载纹理
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    unsigned char *imageData = [QMImageHelper convertUIImageToBitmapRGBA8:image];
    
    // 初始化GPUImageRawDataInput
    _rawDataInput = [[GPUImageRawDataInput alloc] initWithBytes:imageData size:CGSizeMake(width, height) pixelFormat:GPUPixelFormatRGBA];
    
    // 滤镜
    GPUImageSolarizeFilter *filter = [[GPUImageSolarizeFilter alloc] init];
    [_rawDataInput addTarget:filter];
    [filter addTarget:_imageView];
    
    // 开始处理数据
    [_rawDataInput processData];
    
    // 清理
    if (imageData) {
        free(imageData);
        image = NULL;
    }
}

- (void)writeRGBADataToFile
{
    // 加载纹理
    UIImage *image = [UIImage imageNamed:@"2.jpg"];
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    unsigned char *imageData = [QMImageHelper convertUIImageToBitmapRGBA8:image];
    
    // 初始化GPUImageRawDataInput
    _rawDataInput = [[GPUImageRawDataInput alloc] initWithBytes:imageData size:CGSizeMake(width, height) pixelFormat:GPUPixelFormatRGBA];
    
    // 滤镜
    GPUImageSaturationFilter *filter = [[GPUImageSaturationFilter alloc] init];
    filter.saturation = 0.3;
    
    // GPUImageRawDataOutput
    GPUImageRawDataOutput *rawDataOutput = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(width, height) resultsInBGRAFormat:NO];
    [rawDataOutput lockFramebufferForReading];
    
    [_rawDataInput addTarget:filter];
    [filter addTarget:_imageView];
    [filter addTarget:rawDataOutput];
    
    // 开始处理数据
    [_rawDataInput processData];
    
    // 生成png图片
    unsigned char *rawBytes = [rawDataOutput rawBytesForImage];
    pic_data pngData = {(int)width, (int)height, 8, PNG_HAVE_ALPHA, rawBytes};
    write_png_file([DOCUMENT(@"raw_data_output.png") UTF8String], &pngData);
    
    // 清理
    [rawDataOutput unlockFramebufferAfterReading];
    if (imageData) {
        free(imageData);
        image = NULL;
    }
    
    NSLog(@"%@", DOCUMENT(@"raw_data_output.png"));
    
}

@end
