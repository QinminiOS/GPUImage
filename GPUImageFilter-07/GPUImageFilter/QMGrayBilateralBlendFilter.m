//
//  QMRGBBilateralBlendFilter.m
//  GPUImageFilter
//
//  Created by mac on 17/5/11.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "QMGrayBilateralBlendFilter.h"

NSString *const kGrayBilateralBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     highp vec4 gray = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 bilateral = texture2D(inputImageTexture2, textureCoordinate2);
     
     highp float range = distance(textureCoordinate, vec2(0.5, 0.5));
     
     highp vec4 dstClor = bilateral;
     if (range < 0.4) {
         dstClor = gray;
     }
     
     gl_FragColor = dstClor;
     
     //gl_FragColor = vec4(vec3(mix(gray, bilateral, 0.6)), 1.0);
 }
 );

@implementation QMGrayBilateralBlendFilter

- (instancetype)init
{
    if (self = [super init])
    {
        // RGBFilter
        GPUImageGrayscaleFilter *grayFilter = [[GPUImageGrayscaleFilter alloc] init];
        [self addFilter:grayFilter];
        
        // BilateralFilter
        GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
        bilateralFilter.distanceNormalizationFactor = 16.0;
        [self addFilter:bilateralFilter];
        
        // GPUImageTwoPassFilter
        GPUImageTwoInputFilter *twoPassFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kGrayBilateralBlendFragmentShaderString];
        
        // GPUImageHSBFilter
        GPUImageHSBFilter *hsbFilter = [[GPUImageHSBFilter alloc] init];
        
        [grayFilter addTarget:twoPassFilter];
        [bilateralFilter addTarget:twoPassFilter];
        [twoPassFilter addTarget:hsbFilter];
        
        self.initialFilters = @[grayFilter, bilateralFilter];
        self.terminalFilter = hsbFilter;
        
    }
    return self;
}

@end
