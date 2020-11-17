//
//  CameraController.m
//  CubeCamera
//
//  Created by luowailin on 2020/11/16.
//

#import "CameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface CameraController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, weak) EAGLContext *context;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

// CVOpenGLESTextureCache 作为Core Video 像素buffer 和 OpenGL ES 贴图之间的桥梁
@property(nonatomic) CVOpenGLESTextureCacheRef textureCache;
@property(nonatomic) CVOpenGLESTextureRef cameraTexture;

@end


@implementation CameraController

- (instancetype)initWithContext:(EAGLContext *)context{
    self = [super init];
    if (self) {
        _context = context;
        
        // 创建一个新的缓存实例。这个函数的关键参数是后备EAGLContext 和 textureCache指针
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                                    NULL,
                                                    _context,
                                                    NULL,
                                                    &_textureCache);
        if (err != kCVReturnSuccess) {
            NSLog(@"Error creating texture cache. %d", err);
        }
    }
    return self;
}

- (NSString *)sessionPreset {
    return AVCaptureSessionPreset640x480;
}

- (BOOL)setupSessionOutputs:(NSError *__autoreleasing  _Nullable *)error{
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    //摄像头初始格式为双平面420v 在使用OpenGL ES时经常会选用BGRA 要注意这一格式的转换会牺牲一点性能
    self.videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    
    //queue 参数指定的调度队列必须是一个序列队列，不过在许多其他案例中都是指定专门的视频处理队列
    [self.videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
        return YES;
    }
    
    return NO;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    //
    CVReturn err;
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //
    CMFormatDescriptionRef formationDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    //用CMVideoFormatDescriptionGetDimensions函数通过格式描述信息来获取视频帧的维度，返回一个带有宽和高信息的CMVideoDimensions结构
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formationDescription);
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _textureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       dimensions.height,
                                                       dimensions.width,
                                                       GL_BGRA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &_cameraTexture);
    
    if (!err) {
        GLenum target = CVOpenGLESTextureGetTarget(_cameraTexture);
        GLuint name = CVOpenGLESTextureGetName(_cameraTexture);
        [self.textureDelegate textureCreatedWithTarget:target
                                                  name:name];
    } else {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage：%d", err);
    }
    [self cleanupTextures];
}

- (void)cleanupTextures{
    if (_cameraTexture) {
        CFRelease(_cameraTexture);
        _cameraTexture = NULL;
    }
    CVOpenGLESTextureCacheFlush(_textureCache, 0);
}

@end
