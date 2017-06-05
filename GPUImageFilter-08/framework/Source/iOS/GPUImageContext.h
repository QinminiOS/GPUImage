#import "GLProgram.h"
#import "GPUImageFramebuffer.h"
#import "GPUImageFramebufferCache.h"

#define GPUImageRotationSwapsWidthAndHeight(rotation) ((rotation) == kGPUImageRotateLeft || (rotation) == kGPUImageRotateRight || (rotation) == kGPUImageRotateRightFlipVertical || (rotation) == kGPUImageRotateRightFlipHorizontal)

typedef NS_ENUM(NSUInteger, GPUImageRotationMode) {
	kGPUImageNoRotation,
	kGPUImageRotateLeft,
	kGPUImageRotateRight,
	kGPUImageFlipVertical,
	kGPUImageFlipHorizonal,
	kGPUImageRotateRightFlipVertical,
	kGPUImageRotateRightFlipHorizontal,
	kGPUImageRotate180
};

@interface GPUImageContext : NSObject

@property(readonly, nonatomic) dispatch_queue_t contextQueue;
@property(readwrite, retain, nonatomic) GLProgram *currentShaderProgram;
@property(readonly, retain, nonatomic) EAGLContext *context;
@property(readonly) CVOpenGLESTextureCacheRef coreVideoTextureCache;
@property(readonly) GPUImageFramebufferCache *framebufferCache;

// 获取队列标识
+ (void *)contextKey;
// 单例对象
+ (GPUImageContext *)sharedImageProcessingContext;
// 获取处理队列
+ (dispatch_queue_t)sharedContextQueue;
// 帧缓存
+ (GPUImageFramebufferCache *)sharedFramebufferCache;
// 设置当前上下文
+ (void)useImageProcessingContext;
- (void)useAsCurrentContext;
// 设置当前的GL程序
+ (void)setActiveShaderProgram:(GLProgram *)shaderProgram;
- (void)setContextShaderProgram:(GLProgram *)shaderProgram;
// 获取设备OpenGLES相关特性的支持情况
+ (GLint)maximumTextureSizeForThisDevice;
+ (GLint)maximumTextureUnitsForThisDevice;
+ (GLint)maximumVaryingVectorsForThisDevice;
+ (BOOL)deviceSupportsOpenGLESExtension:(NSString *)extension;
+ (BOOL)deviceSupportsRedTextures;
+ (BOOL)deviceSupportsFramebufferReads;
// 纹理大小调整，保证纹理不超过OpenGLES支持最大的尺寸
+ (CGSize)sizeThatFitsWithinATextureForSize:(CGSize)inputSize;
// 将渲染缓存呈现在设备上
- (void)presentBufferForDisplay;
// 创建GLProgram，首先在缓存中查找，如果没有则创建
- (GLProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString;
// 创建Sharegroup
- (void)useSharegroup:(EAGLSharegroup *)sharegroup;

// Manage fast texture upload
+ (BOOL)supportsFastTextureUpload;

@end

@protocol GPUImageInput <NSObject>
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
- (NSInteger)nextAvailableTextureIndex;
- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
- (CGSize)maximumOutputSize;
- (void)endProcessing;
- (BOOL)shouldIgnoreUpdatesToThisTarget;
- (BOOL)enabled;
- (BOOL)wantsMonochromeInput;
- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue;
@end
