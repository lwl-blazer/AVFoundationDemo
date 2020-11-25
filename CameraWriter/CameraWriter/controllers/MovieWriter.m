//
//  MovieWriter.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "MovieWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "ContextManager.h"
#import "BLFunctions.h"
#import "PhotoFilters.h"
#import "BLNotifications.h"

static NSString *const VideoFilename = @"movie.mov";

@interface MovieWriter ()

@property(nonatomic, strong) AVAssetWriter *assetWriter;
@property(nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property(nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelBufferAdaptor;

@property(nonatomic, strong) dispatch_queue_t dispatchQueue;

@property(nonatomic, weak) CIContext *ciContext;
@property(nonatomic, assign) CGColorSpaceRef colorSpace;
@property(nonatomic, strong) CIFilter *activeFilter;

@property(nonatomic, strong) NSDictionary *videoSettings;
@property(nonatomic, strong) NSDictionary *audioSettings;

@property(nonatomic, assign) BOOL firstSample;

@end



@implementation MovieWriter

- (id)initWithVideoSettings:(NSDictionary *)videoSettings
              audioSettings:(NSDictionary *)audioSettings
              dispatchQueue:(dispatch_queue_t)dispatchQueue {

    self = [super init];
    if (self) {
        _videoSettings = videoSettings;
        _audioSettings = audioSettings;
        _dispatchQueue = dispatchQueue;
        
        _ciContext = [ContextManager sharedInstance].ciContext;
        _colorSpace = CGColorSpaceCreateDeviceRGB();
        
        _activeFilter = [PhotoFilters defaultFilter];
        
        _firstSample = YES;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
            selector:@selector(filterChanged:)
                   name:BLFilterSelectionChangedNotification
                 object:nil];

    }
    return self;
}

- (void)dealloc {
    CGColorSpaceRelease(_colorSpace);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)filterChanged:(NSNotification *)notification {
    self.activeFilter = [notification.object copy];
}

- (void)startWriting {
    dispatch_async(self.dispatchQueue, ^{
        NSError *error = nil;
        NSString *fileType = AVFileTypeQuickTimeMovie;
        self.assetWriter = [AVAssetWriter assetWriterWithURL:[self outputURL]
                                                    fileType:fileType
                                                       error:&error];
        if (!self.assetWriter || error) {
            NSString *formatString = @"Could not create AVAssetWrite: %@";
            NSLog(@"%@", [NSString stringWithFormat:formatString, error]);
            return;
        }
        
        self.assetWriterVideoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:self.videoSettings];
        //YES 指明这个输入应该针对实时性进行优化
        self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        self.assetWriterVideoInput.transform = BLTransformForDeviceOrientation(orientation);
        
        //要保证最大效率，字典中的值应该对应于在配置AVCaptureVideoDataOutput时所使用的原像素格式
        NSDictionary *attributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                                     (id)kCVPixelBufferWidthKey:self.videoSettings[AVVideoWidthKey],
                                     (id)kCVPixelBufferHeightKey: self.videoSettings[AVVideoHeightKey],
                                     // kCVPixelFormatOpenGLESCompatibility 为true的话 此格式可以与OpenGL ES 兼容
                                     (id)kCVPixelFormatOpenGLESCompatibility: (id)kCFBooleanTrue
        };
        
        // AVAssetWriterInputPixelBufferAdaptor 这个对象提供了一个优化的CVPixelBufferPool,使用它可以创建CVPixelBuffer对象来渲染筛选视频帧
        self.assetWriterInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.assetWriterVideoInput sourcePixelBufferAttributes:attributes];
        
        if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {
            [self.assetWriter addInput:self.assetWriterVideoInput];
        } else {
            NSLog(@"Unable to add  video input.");
            return;
        }
        
        self.assetWriterAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:self.audioSettings];
        self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
        if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {
            [self.assetWriter addInput:self.assetWriterAudioInput];
        } else {
            NSLog(@"unable to add audio input.");
            return;
        }
        
        self.isWriting = YES;
        self.firstSample = YES;
    });
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer {

    if (!self.isWriting) {
        return;
    }
    
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);
    if (mediaType == kCMMediaType_Video) {
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if (self.firstSample) {
            if ([self.assetWriter startWriting]) {
                [self.assetWriter startSessionAtSourceTime:timestamp];
            } else {
                NSLog(@"Failed to start writing.");
            }
            self.firstSample = NO;
        }
        
        CVPixelBufferRef outputRenderBuffer = NULL;
        CVPixelBufferPoolRef pixelBufferPool = self.assetWriterInputPixelBufferAdaptor.pixelBufferPool;
        OSStatus err = CVPixelBufferPoolCreatePixelBuffer(NULL,
                                                          pixelBufferPool, &outputRenderBuffer);
        if (err) {
            NSLog(@"Unable to obtain a pixel buffer from the pool.");
            return;
        }
        
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer options:nil];
        
        [self.activeFilter setValue:sourceImage forKey:kCIInputImageKey];
        
        CIImage *filteredImage = self.activeFilter.outputImage;
        
        if (!filteredImage) {
            filteredImage = sourceImage;
        }
        
        [self.ciContext render:filteredImage
               toCVPixelBuffer:outputRenderBuffer
                        bounds:filteredImage.extent colorSpace:self.colorSpace];
    
        if (self.assetWriterVideoInput.readyForMoreMediaData) {
            if (![self.assetWriterInputPixelBufferAdaptor appendPixelBuffer:outputRenderBuffer withPresentationTime:timestamp]) {
                NSLog(@"Error appending pixel buffer.");
            }
        }
        
        CVPixelBufferRelease(outputRenderBuffer);
    } else if (!self.firstSample && mediaType == kCMMediaType_Audio) {
        if (self.assetWriterAudioInput.isReadyForMoreMediaData) {
            if (![self.assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                NSLog(@"Error appending audio sample buffer.");
            }
        }
    }
}

- (void)stopWriting {

    // Listing 8.16
    
}

- (NSURL *)outputURL {
    NSString *filePath =
        [NSTemporaryDirectory() stringByAppendingPathComponent:VideoFilename];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

@end
