//
//  QMRotationFilter.m
//  GPUImageFilter
//
//  Created by qinmin on 2017/6/8.
//  Copyright © 2017年 Qinmin. All rights reserved.
//

#import "QM3DLightFilter.h"
#import "GLMath.h"
#import "TinyOBJModel.h"


NSString *const kQM3DLightFilterVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 inputTextureCoordinate;
 attribute vec3 normal;
 
 uniform mat4 MV;
 uniform mat4 P;
 uniform mat4 normalMat;
 
 varying vec2 textureCoordinate;
 varying vec3 vNormal;
 varying vec3 vPosition;
 
 void main()
 {
     gl_Position = P * MV * position;
     
     textureCoordinate = inputTextureCoordinate;
     vPosition = mat3(MV) * vec3(position);
     vNormal = mat3(normalMat) * normal;
 }
 );

NSString *const kQM3DLightFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 varying vec3 vNormal;
 varying vec3 vPosition;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     vec3 lightPos = vec3(5.0, -5.0, 0.0);
     vec3 L = normalize(lightPos);
     vec3 N = normalize(vNormal);
     
     //ambient
     vec4 AmbientLightColor = vec4(0.5, 0.5, 0.5, 1.0);
     vec4 AmbientMaterial = vec4(0.2, 0.2, 0.2, 1.0);
     vec4 ambientColor = AmbientLightColor * AmbientMaterial;
     
     //diffuse
     vec4 DiffuseLightColor = vec4(1.0, 1.0, 1.0, 1.0);
     vec4 DiffuseMaterial = vec4(0.8, 0.8, 0.8, 1.0);
     vec4 diffuseColor = DiffuseLightColor * DiffuseMaterial * max(0.0, dot(N, L));
     
     // Specular
     vec4 SpecularLightColor = vec4(1.0, 1.0, 0.0, 1.0);
     vec4 SpecularMaterial = vec4(0.7, 0.7, 0.7, 1.0);
     vec3 eye = vec3(1.0, -2.0, 5.0) - vPosition;
     vec3 H = normalize(eye + L);
     vec4 specularColor = SpecularLightColor * SpecularMaterial * pow(max(0.0, dot(N, H)), 2.5);
     
     // All light
     vec4 light = ambientColor + diffuseColor + specularColor;
     
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = color * light;
 }
 );


@interface QM3DLightFilter ()
{
    GLint pUniform;
    GLint mvUniform;
    GLint normalMatUniform;
    
    GLint filterNormalAttribute;
    
    std::shared_ptr<TinyOBJModel> _tinyOBJModel;
}
@end

@implementation QM3DLightFilter

- (instancetype)init
{
    if (self = [super initWithVertexShaderFromString:kQM3DLightFilterVertexShaderString fragmentShaderFromString:kQM3DLightFilterFragmentShaderString]) {
        
        [filterProgram addAttribute:@"normal"];
        filterNormalAttribute = [filterProgram attributeIndex:@"normal"];
        glEnableVertexAttribArray(filterNormalAttribute);
        
        pUniform = [filterProgram uniformIndex:@"P"];
        mvUniform = [filterProgram uniformIndex:@"MV"];
        normalMatUniform = [filterProgram uniformIndex:@"normalMat"];
        
        [self setMVPMatrix];
        
        [self setupSurface];
        
        [self setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
    return self;
}

- (void)setMVPMatrix
{
    mat4_t P = mat4_perspective(M_PI/3, 1.0, 1.0, 10.0);
    [self setMatrix4f:*((GPUMatrix4x4 *)&P) forUniform:pUniform program:filterProgram];
    
    mat4_t MV = mat4_create_translation(0, 0, -2.2);
    [self setMatrix4f:*((GPUMatrix4x4 *)&MV) forUniform:mvUniform program:filterProgram];
    
    mat4_t normalMat = mat4_transpose(mat4_inverse(MV, NULL));
    [self setMatrix4f:*((GPUMatrix4x4 *)&normalMat) forUniform:normalMatUniform program:filterProgram];
}

- (void)setupSurface
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Sphere" ofType:@"obj"];
    _tinyOBJModel = std::make_shared<TinyOBJModel>();
    _tinyOBJModel->LoadObj(path.UTF8String);
}

#pragma mark - Overwrite
- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];

    // Setup depth render buffer
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    // Create a depth buffer that has the same size as the color buffer.
    GLuint depthRenderBuffer;
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    
    // Attach color render buffer and depth render buffer to frameBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER, depthRenderBuffer);
    
    glEnable(GL_DEPTH_TEST);
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    int stride = 8 * sizeof(GLfloat);
    const GLvoid* normalOffset = (const GLvoid*)(5 * sizeof(GLfloat));
    const GLvoid* texCoordOffset = (const GLvoid*)(3 * sizeof(GLfloat));
    
    glBindBuffer(GL_ARRAY_BUFFER, _tinyOBJModel->getVertexBuffer());
    glVertexAttribPointer(filterPositionAttribute, 3, GL_FLOAT, GL_FALSE, stride, 0);
    glVertexAttribPointer(filterNormalAttribute, 3, GL_FLOAT, GL_FALSE, stride, normalOffset);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, stride, texCoordOffset);
    
    // Draw the triangles.
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _tinyOBJModel->getIndexBuffer());
    glDrawElements(GL_TRIANGLES, _tinyOBJModel->getIndexCount(), GL_UNSIGNED_INT, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glDisable(GL_DEPTH_TEST);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
