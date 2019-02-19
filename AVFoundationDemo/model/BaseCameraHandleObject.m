
//
//  BaseCameraHandleObject.m
//  AVFoundationDemo
//
//  Created by blazer on 2019/2/18.
//  Copyright © 2019 blazer. All rights reserved.
//

#import "BaseCameraHandleObject.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

const CGFloat THZoomRate = 1.0f;

static const NSString *THRampingVideoZoomContext;
static const NSString *THRampingVideoZoomFactorContext;

@interface BaseCameraHandleObject () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, weak) EAGLContext *context;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property(nonatomic) CVOpenGLESTextureCacheRef textureCache;
@property(nonatomic) CVOpenGLESTextureRef cameraTexture;

@end


@implementation BaseCameraHandleObject

//videoZoomFactory的属性，用于控制捕捉设备的缩放等级。 最小值是1.0 不能缩放图片
- (BOOL)cameraSupportsZoom{
    return self.activeCamera.activeFormat.videoMaxZoomFactor > 1.0;
}

//最大值 videoMaxZoomFactor
- (CGFloat)maxZoomFactor{
    return MIN(self.activeCamera.activeFormat.videoMaxZoomFactor, 4.0);
}

- (void)setZoomValue:(CGFloat)zoomValue{
    if (!self.activeCamera.isRampingVideoZoom) {
        NSError *error;
        
        if ([self.activeCamera lockForConfiguration:&error]) {
            CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);   //增长为指数形式，所以要提供范围线性增长的感觉，需要通过计算最大的缩放因子的zoomvalue次幂(0到1)来计算zoomFactor值
            self.activeCamera.videoZoomFactor = zoomFactor;
            
            [self.activeCamera unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWidthError:error];
        }
    }
}


- (void)rampZoomToValue:(CGFloat)zoomValue{
    CGFloat zoomFactory = pow([self maxZoomFactor], zoomValue);
    NSError *error;
    if ([self.activeCamera lockForConfiguration:&error]) {
        [self.activeCamera rampToVideoZoomFactor:zoomFactory withRate:THZoomRate];  //
        [self.activeCamera unlockForConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWidthError:error];
    }
}

- (void)cancelZoom{
    NSError *error;
    if (![self.activeCamera lockForConfiguration:&error]) {
        [self.activeCamera cancelVideoZoomRamp];
        [self.activeCamera unlockForConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWidthError:error];
    }
}

- (BOOL)setupSession:(NSError *)error{
    BOOL success = [super setupSession:error];
    
    if (success) {
        [self.activeCamera addObserver:self
                            forKeyPath:@"videoZoomFactor"
                               options:0 context:&THRampingVideoZoomFactorContext];
        [self.activeCamera addObserver:self
                            forKeyPath:@"ramingVideoZoom"
                               options:0
                               context:&THRampingVideoZoomContext];
    }
    return success;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (context == &THRampingVideoZoomContext) {
        [self updateZoomingDelegate];
    } else if (context == &THRampingVideoZoomFactorContext) {
        if (self.activeCamera.isRampingVideoZoom) {
            [self updateZoomingDelegate];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateZoomingDelegate{
    CGFloat curZoomFactor = self.activeCamera.videoZoomFactor;
    CGFloat maxZoomFactor = [self maxZoomFactor];
    CGFloat value = log(curZoomFactor) / log(maxZoomFactor);
    [self.zoomingDelegate rampedZoomToValue:value];
}


- (instancetype)initWithContext:(EAGLContext *)context{
    self = [super init];
    if (self) {
        _context = context;
        
        //创建贴图缓存
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                                    NULL,
                                                    _context,
                                                    NULL,
                                                    &_textureCache);
        if (err != kCVReturnSuccess) {
            NSLog(@"Error creating texture cache %d", err);
        }
    }
    return self;
}

- (NSString *)sessionPreset{
    return AVCaptureSessionPreset640x480;
}

- (BOOL)setupSessionOutputs:(NSError **)error{
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};  //OpenGL ES 通常使用的是BGRA 要注意这一格式的转换会稍微牺牲一点性能
    
    [self.videoDataOutput setSampleBufferDelegate:self
                                            queue:dispatch_get_main_queue()];
    
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
        
        return YES;
    }
    
    return NO;
}

/* Core Video 提供了一个对象类型CVOpenGLESTextureCache 作为Core Video像素Buffer和OpenGLES 贴图之间的桥梁。缓存的目的是减少数据从CPU转移到GPU(也可能是反向 的)开销*/
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CVReturn err;
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);   //CVImageBuffer是CVPixelBufferRef的类型定义
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription); //通过格式描述信息来获取视频帧的维度。它会返回一个带有宽和高信息的CMVideoDimensions结构
    
    //创建OpenGLES的贴图
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _textureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       dimensions.height,
                                                       dimensions.height,  //两个都使用height 因为希望在水平方向上剪辑视频。所以这个是完美矩形
                                                       GL_RGBA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &_cameraTexture);
    
    if (!err) {
        GLenum target = CVOpenGLESTextureGetTarget(_cameraTexture);
        GLuint name = CVOpenGLESTextureGetName(_cameraTexture);
        
        [self.textureDelegate textureCreateWithTarget:target name:name];
    } else {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    [self cleanupTextures];
}

- (void)cleanupTextures{
    if (_cameraTexture) {
        CFRelease(_cameraTexture);  //释放贴图
        _cameraTexture = NULL;
    }
    CVOpenGLESTextureCacheFlush(_textureCache, 0);  //刷新贴图缓存
}

@end


/** CMSampleBuffer
 
 CMSampleBuffer  是一个由Core Media 框架提供的Core Foundation 风格的对象，用于在媒体管道中传输数字样本。
 
 CMSampleBuffer 的角色是将基础的样本数据进行封装并提供格式和时间信息，还会加上所有在转换和处理数据时用到的元数据
 
 CVPixelBuffer 它是一个带有单个视频帧原始像素数据的Core Video对象。  CVPixelBuffer在主内存中保存像素数据，提供了操作内容的机会
 
 CMFormatDescription 对象的形式来访问样本的格式信息。
 
 CMSampleBufferGetPresentationTimeStamp函数和 CMSampleBufferGetDecodeTimeStamp 函数提取时间信息来得到原始的表示时间戳和解码时间戳
 
 CMAttachment形式的元数据协议   提供了读取和写入底层元数据的基础架构   比如可交换图片文件格式(Exif)标签
 */
