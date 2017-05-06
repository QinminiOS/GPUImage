//
//  ImageShowViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/5/5.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "ImageShowViewController.h"

@interface ImageShowViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ImageShowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageView.image = _image;
}

- (IBAction)backButtonTapped:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
