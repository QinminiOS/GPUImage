//
//  ViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/2/4.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>
#import "QMImageHelper.h"

typedef struct {
    char r,g,b,a;
} RGBA;

#define DOCUMENT(path) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path]

@interface ViewController ()
@property (nonatomic, strong) GPUImageLookupFilter *filter;
@property (nonatomic, strong) GPUImagePicture *picture;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置背景色
    [_imageView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [_imageView setFillMode:kGPUImageFillModePreserveAspectRatio];
    
    
     [self setupFilter];
//    [self generateLoockupTexture];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - PrivateMethod
- (void)setupFilter
{
    self.filter = [[GPUImageLookupFilter alloc] init];
    [self.filter setIntensity:0.65f];
    [self.filter addTarget:self.imageView];
    
    self.picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
    [self.picture addTarget:self.filter];
    [self.picture processImage];
    
    GPUImagePicture *loockup = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookup.jpg"]];
    [loockup addTarget:self.filter];
    [loockup processImage];
    
}

- (void)generateLoockupTexture
{
    RGBA rgba[8*64][8*64];
    
    for (int by = 0; by < 8; by++) {
        for (int bx = 0; bx < 8; bx++) {
            for (int g = 0; g < 64; g++) {
                for (int r = 0; r < 64; r++) {
                    // 将RGB[0,255]分成64份，每份相差4个单位，+0.5做四舍五入运算
                    int rr = (int)(r * 255.0 / 63.0 + 0.5);
                    int gg = (int)(g * 255.0 / 63.0 + 0.5);
                    int bb = (int)(((bx + by * 8.0) * 255.0 / 63.0 + 0.5));
                    int aa = 255;
                    
                    int x = r + bx * 64;
                    int y = g + by * 64;
                    
                    rgba[y][x] = (RGBA){rr, gg, bb, aa};
                }
            }
        }
    }
    
    UIImage *image = [QMImageHelper convertBitmapRGBA8ToUIImage:(unsigned char *)rgba withWidth:8*64 withHeight:8*64];
    [UIImagePNGRepresentation(image) writeToFile:@"/Users/qinmin/Desktop/lookup.png" atomically:YES];
}


@end
