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

NSString *const kTwoInputFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     highp vec4 oneInputColor = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 twoInputColor = texture2D(inputImageTexture2, textureCoordinate2);
     
     highp float range = distance(textureCoordinate, vec2(0.5, 0.5));
     
     highp vec4 dstClor = oneInputColor;
     if (range < 0.25) {
         dstClor = twoInputColor;
     }else {
         //dstClor = vec4(vec3(1.0 - oneInputColor), 1.0);
         if (oneInputColor.r < 0.001 && oneInputColor.g < 0.001 && oneInputColor.b < 0.001) {
             dstClor = vec4(1.0);
         }else {
             dstClor = vec4(1.0, 0.0, 0.0, 1.0);
         }
     }
     
     gl_FragColor = dstClor;
 }
);

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_imageView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
}

- (IBAction)processButtonTapped:(UIButton *)sender
{
    // 图片
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];

    // 滤镜
    GPUImageCannyEdgeDetectionFilter *cannyFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc] init];

    [picture addTarget:cannyFilter];
    [picture addTarget:gammaFilter];

    // GPUImageTwoInputFilter
    GPUImageTwoInputFilter *twoFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kTwoInputFragmentShaderString];

    [cannyFilter addTarget:twoFilter];
    [gammaFilter addTarget:twoFilter];
    [twoFilter addTarget:_imageView];

    [picture processImage];
}

@end
