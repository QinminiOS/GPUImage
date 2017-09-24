#import "GPUImageFramebufferCache.h"
#import "GPUImageContext.h"
#import "GPUImageOutput.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#endif

@interface GPUImageFramebufferCache()
{
//    NSCache *framebufferCache;
    NSMutableDictionary *framebufferCache;
    NSMutableDictionary *framebufferTypeCounts;
    NSMutableArray *activeImageCaptureList; // Where framebuffers that may be lost by a filter, but which are still needed for a UIImage, etc., are stored
    id memoryWarningObserver;

    dispatch_queue_t framebufferCacheQueue;
}

- (NSString *)hashForSize:(CGSize)size textureOptions:(GPUTextureOptions)textureOptions onlyTexture:(BOOL)onlyTexture;

@end


@implementation GPUImageFramebufferCache

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    __unsafe_unretained __typeof__ (self) weakSelf = self;
    memoryWarningObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        __typeof__ (self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf purgeAllUnassignedFramebuffers];
        }
    }];
#else
#endif

//    framebufferCache = [[NSCache alloc] init];
    framebufferCache = [[NSMutableDictionary alloc] init];
    framebufferTypeCounts = [[NSMutableDictionary alloc] init];
    activeImageCaptureList = [[NSMutableArray alloc] init];
    framebufferCacheQueue = dispatch_queue_create("com.sunsetlakesoftware.GPUImage.framebufferCacheQueue", GPUImageDefaultQueueAttribute());
    
    return self;
}

- (void)dealloc;
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#else
#endif
}

#pragma mark -
#pragma mark Framebuffer management

- (NSString *)hashForSize:(CGSize)size textureOptions:(GPUTextureOptions)textureOptions onlyTexture:(BOOL)onlyTexture;
{
    if (onlyTexture)
    {
        return [NSString stringWithFormat:@"%.1fx%.1f-%d:%d:%d:%d:%d:%d:%d-NOFB", size.width, size.height, textureOptions.minFilter, textureOptions.magFilter, textureOptions.wrapS, textureOptions.wrapT, textureOptions.internalFormat, textureOptions.format, textureOptions.type];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fx%.1f-%d:%d:%d:%d:%d:%d:%d", size.width, size.height, textureOptions.minFilter, textureOptions.magFilter, textureOptions.wrapS, textureOptions.wrapT, textureOptions.internalFormat, textureOptions.format, textureOptions.type];
    }
}

- (GPUImageFramebuffer *)fetchFramebufferForSize:(CGSize)framebufferSize textureOptions:(GPUTextureOptions)textureOptions onlyTexture:(BOOL)onlyTexture;
{
    __block GPUImageFramebuffer *framebufferFromCache = nil;
//    dispatch_sync(framebufferCacheQueue, ^{
    runSynchronouslyOnVideoProcessingQueue(^{
        // 创建查找字符串
        NSString *lookupHash = [self hashForSize:framebufferSize textureOptions:textureOptions onlyTexture:onlyTexture];
        // 获取GPUImageFramebuffer在缓存中的数量
        NSNumber *numberOfMatchingTexturesInCache = [framebufferTypeCounts objectForKey:lookupHash];
        NSInteger numberOfMatchingTextures = [numberOfMatchingTexturesInCache integerValue];
        
        // 如果没有，则创建
        if ([numberOfMatchingTexturesInCache integerValue] < 1)
        {
            // Nothing in the cache, create a new framebuffer to use
            framebufferFromCache = [[GPUImageFramebuffer alloc] initWithSize:framebufferSize textureOptions:textureOptions onlyTexture:onlyTexture];
        }
        else
        {
            // Something found, pull the old framebuffer and decrement the count
            // 如果有，则取出最后一个
            NSInteger currentTextureID = (numberOfMatchingTextures - 1);
            while ((framebufferFromCache == nil) && (currentTextureID >= 0))
            {
                // 根据数量构建带数量的textureHash字符串
                NSString *textureHash = [NSString stringWithFormat:@"%@-%ld", lookupHash, (long)currentTextureID];
                
                // 查找以textureHash为key的GPUImageFramebuffer是否存在
                framebufferFromCache = [framebufferCache objectForKey:textureHash];
                // Test the values in the cache first, to see if they got invalidated behind our back
                if (framebufferFromCache != nil)
                {
                    // 存在，则从缓存中删除
                    // Withdraw this from the cache while it's in use
                    [framebufferCache removeObjectForKey:textureHash];
                }
                currentTextureID--;
            }
            
            currentTextureID++;
            
            // 更新framebufferTypeCounts中相同类型GPUImageFramebuffer的数量（相同类型GPUImageFramebuffer指的是计算出来的lookupHash相同）
            [framebufferTypeCounts setObject:[NSNumber numberWithInteger:currentTextureID] forKey:lookupHash];
            
            // 还是没有则创建
            if (framebufferFromCache == nil)
            {
                framebufferFromCache = [[GPUImageFramebuffer alloc] initWithSize:framebufferSize textureOptions:textureOptions onlyTexture:onlyTexture];
            }
        }
    });
    
    // 引用计数加1，返回
    [framebufferFromCache lock];
    return framebufferFromCache;
}

- (GPUImageFramebuffer *)fetchFramebufferForSize:(CGSize)framebufferSize onlyTexture:(BOOL)onlyTexture;
{
    GPUTextureOptions defaultTextureOptions;
    defaultTextureOptions.minFilter = GL_LINEAR;
    defaultTextureOptions.magFilter = GL_LINEAR;
    defaultTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.internalFormat = GL_RGBA;
    defaultTextureOptions.format = GL_BGRA;
    defaultTextureOptions.type = GL_UNSIGNED_BYTE;
    
    return [self fetchFramebufferForSize:framebufferSize textureOptions:defaultTextureOptions onlyTexture:onlyTexture];
}

- (void)returnFramebufferToCache:(GPUImageFramebuffer *)framebuffer;
{
    // 清楚引用计数
    [framebuffer clearAllLocks];
    
//    dispatch_async(framebufferCacheQueue, ^{
    runAsynchronouslyOnVideoProcessingQueue(^{
        CGSize framebufferSize = framebuffer.size;
        GPUTextureOptions framebufferTextureOptions = framebuffer.textureOptions;
        // 常见查找hash字符串
        NSString *lookupHash = [self hashForSize:framebufferSize textureOptions:framebufferTextureOptions onlyTexture:framebuffer.missingFramebuffer];
        // 获取当前同类型缓存的数量
        NSNumber *numberOfMatchingTexturesInCache = [framebufferTypeCounts objectForKey:lookupHash];
        NSInteger numberOfMatchingTextures = [numberOfMatchingTexturesInCache integerValue];
        
        // 对相同类型的GPUImageFramebuffer,存放在framebufferCache中时，key值由lookupHash加上数量避免覆盖相同的GPUImageFramebuffer。
        NSString *textureHash = [NSString stringWithFormat:@"%@-%ld", lookupHash, (long)numberOfMatchingTextures];
        
//        [framebufferCache setObject:framebuffer forKey:textureHash cost:round(framebufferSize.width * framebufferSize.height * 4.0)];
        [framebufferCache setObject:framebuffer forKey:textureHash];
        
        // framebufferTypeCounts中的key没有加数量
        [framebufferTypeCounts setObject:[NSNumber numberWithInteger:(numberOfMatchingTextures + 1)] forKey:lookupHash];
    });
}

- (void)purgeAllUnassignedFramebuffers;
{
    runAsynchronouslyOnVideoProcessingQueue(^{
//    dispatch_async(framebufferCacheQueue, ^{
        [framebufferCache removeAllObjects];
        [framebufferTypeCounts removeAllObjects];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CVOpenGLESTextureCacheFlush([[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], 0);
#else
#endif
    });
}

- (void)addFramebufferToActiveImageCaptureList:(GPUImageFramebuffer *)framebuffer;
{
    runAsynchronouslyOnVideoProcessingQueue(^{
//    dispatch_async(framebufferCacheQueue, ^{
        [activeImageCaptureList addObject:framebuffer];
    });
}

- (void)removeFramebufferFromActiveImageCaptureList:(GPUImageFramebuffer *)framebuffer;
{
    runAsynchronouslyOnVideoProcessingQueue(^{
//  dispatch_async(framebufferCacheQueue, ^{
        [activeImageCaptureList removeObject:framebuffer];
    });
}

@end
