//
//  Second ViewController.m
//  GPUImageFilter
//
//  Created by mac on 17/5/3.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "SecondViewController.h"
#import "QMImageHelper.h"
#import <GPUImage.h>

#define DOCUMENT(path) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path]

NSString *const kVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
);

NSString *const kFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
);

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (nonatomic, assign) GLuint texture;
@end

@implementation SecondViewController

- (void)dealloc
{
    glDeleteTextures(1, &_texture);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    [_imageView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
}

- (IBAction)textureInputButtonTapped:(UIButton *)sender
{
    // 加载纹理
    UIImage *image = [UIImage imageNamed:@"3.jpg"];
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    unsigned char *imageData = [QMImageHelper convertUIImageToBitmapRGBA8:image];
    
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GPUImageTextureInput *textureInput = [[GPUImageTextureInput alloc] initWithTexture:_texture size:CGSizeMake(width, height)];
    [textureInput addTarget:_imageView];
    [textureInput processTextureWithFrameTime:kCMTimeIndefinite];
    
    // 清理
    if (imageData) {
        free(imageData);
        image = NULL;
    }
}

- (IBAction)textureOutputButtonTapped:(UIButton *)sender
{
    UIImage *image = [UIImage imageNamed:@"3.jpg"];
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    
    // GPUImagePicture
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
    
    // GPUImageTextureOutput
    GPUImageTextureOutput *output = [[GPUImageTextureOutput alloc] init];
    
    [picture addTarget:output];
    [picture addTarget:_imageView];
    
    [picture processImage];
    
    // 生成图片
    runSynchronouslyOnContextQueue([GPUImageContext sharedImageProcessingContext], ^{
        // 设置程序
        GLProgram *progam = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kVertexShaderString fragmentShaderString:kFragmentShaderString];
        [progam addAttribute:@"position"];
        [progam addAttribute:@"inputTextureCoordinate"];
        
        // 激活程序
        [GPUImageContext setActiveShaderProgram:progam];
        [GPUImageContext useImageProcessingContext];
        
        // GPUImageFramebuffer
        GPUImageFramebuffer *frameBuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(width, height) onlyTexture:NO];
        [frameBuffer lock];
        
        static const GLfloat imageVertices[] = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f,
        };
        
        static const GLfloat textureCoordinates[] = {
            0.0f, 0.0f,
            1.0f, 0.0f,
            0.0f, 1.0f,
            1.0f, 1.0f,
        };
        
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glViewport(0, 0, (GLsizei)width, (GLsizei)height);
        
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, output.texture);
        
        glUniform1i([progam uniformIndex:@"inputImageTexture"], 2);
        
        glVertexAttribPointer([progam attributeIndex:@"position"], 2, GL_FLOAT, 0, 0, imageVertices);
        glVertexAttribPointer([progam attributeIndex:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, textureCoordinates);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        CGImageRef outImage = [frameBuffer newCGImageFromFramebufferContents];
        NSData *pngData = UIImagePNGRepresentation([UIImage imageWithCGImage:outImage]);
        [pngData writeToFile:DOCUMENT(@"texture_output.png") atomically:YES];
        
        NSLog(@"%@", DOCUMENT(@"texture_output.png"));
        
        // unlock
        [frameBuffer unlock];
        [output doneWithTexture];
    });
}

@end
