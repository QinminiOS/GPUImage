//
//  Second ViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/5/3.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "SecondViewController.h"
#import <GPUImage.h>

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_imageView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    GPUImageUIElement *element = [[GPUImageUIElement alloc] initWithView:_bgView];
    GPUImageHueFilter *filter = [[GPUImageHueFilter alloc] init];
    [element addTarget:filter];
    [filter addTarget:_imageView];
    [filter useNextFrameForImageCapture];
    
    [element update];
}



@end
