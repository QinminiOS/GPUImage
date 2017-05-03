//
//  ViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/2/4.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_imageView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];
    GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc] init];
    [picture addTarget:filter];
    [filter addTarget:_imageView];
    [filter useNextFrameForImageCapture];
    
    [picture processImage];
}


@end
