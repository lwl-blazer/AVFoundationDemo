
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

#import <VideoToolbox/VideoToolbox.h>

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

/** 编码 VideoToolbox
 * 在iOS下进行视频编码的最重要的数据类型就是VTCompressionSession， 它管理着VideoEncoder
 *
 * 编码的基本流程:
    1.创建编码器
    2.从Camera获取视频帧，获取到的视频帧类型是CVPixelBuffers类型, 一般Camera采集的数据都是每秒30帧
    3.通过VTCompressionSession管理的VideoEncoder对视频帧进行编码
    4.输出H264数据，它由CMSampleBuffers容器进行管理
 */
- (void)videoEncoderWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    VTCompressionSessionRef sessionRef;
    OSStatus status = VTCompressionSessionCreate(NULL,  //session分配器  NULL使用默认的分配器
                                                  600,   //视频帧的像素宽度
                                                  500,   //视频帧的像素高度
                                                  kCMVideoCodecType_H264, //编码类型
                                                  NULL, //使用的视频编码器  NULL让videoToolbox自己选择
                                                  NULL, //指定源图像属性  如YUV类型为 NV12
                                                  NULL,  //压缩数据分配器  NULL使用默认
                                                  NULL,  //编码后的回调函数。该函数会在不同的线程中异步调用。
                                                  NULL,  //用户自定义的回调上下文，一般设置为NULL。
                                                  &sessionRef //compression session的返回值
                                                  );
    
    /** 配置CompressionSession
     * 设置RealTime 即是否是实时编码
     * 设置Profile level, baseline, mainline, highlevel等
     * 设置是否允许录制
     * 设置平均比特率及最大码流。 最大码流是平均比特率的1.5倍
     * 设置关键帧最大间隔为60fps
     * 设置关键帧持续时间 240s
     */
    status = VTSessionSetProperty(sessionRef, NULL, NULL);
    
    //对视频帧进行编码
    VTCompressionSessionEncodeFrame(sessionRef,
                                    NULL,   // 它里面包含了被压缩的视频帧
                                    CMTimeMake(3, 300),   //pts 视频帧展示时的时间戳
                                    kCMTimeZero, //时间    没用
                                    NULL,  //键值对  指明了额外的属性
                                    NULL, //可用于存放上下文， 它将被透传给回调函数
                                    NULL);
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


/**
 * CMSampleBuffer  存放视频数据的容器。它即可以存放原始视频数据，也可以存放编码后的视频数据
 *
 * CMVideoFormatDescription   存放图像信息的数据结构，如宽\高格式类型(kCMPixelFormat_32BGRA, kCMVideoCodecType_H264, ...), 扩展(像素宽高比，颜色空间...)
 *
 * CVPixelBuffer  存放未压缩 \ 未编码的原始数据
 *
 * CVPixelBuffer   存放未压缩/未编码的原始数据
 *
 * CVPixelBufferPool : CVPixelBuffer 对象池
 *
 * pixelBufferAttributes  存放视频的宽/高， 像素类型(32BGRA, YCbCr420), 兼容性(OpenGL ES, Core Animation)
 *
 * CMBlockBuffer 存放编码后的视频数据
 *
 * CMTime/CMClock/CMTimebase 存放时间戳
 */
