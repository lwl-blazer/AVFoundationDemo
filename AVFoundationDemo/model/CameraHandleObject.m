//
//  CameraHandleObject.m
//  AVFoundationDemo
//
//  Created by blazer on 2019/2/16.
//  Copyright © 2019 blazer. All rights reserved.
//

#import "CameraHandleObject.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

#import "NSFileManager+THAdditions.h"

NSString *const THThumbnailCreatedNotification = @"THThumbnailCreated";

@interface CameraHandleObject () <AVCaptureFileOutputRecordingDelegate>

@property(nonatomic, strong) dispatch_queue_t videoQueue;
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;

@property(nonatomic, strong) AVCaptureStillImageOutput *imageOutput;   //在iOS10.后 用AVCapturePhotoOutput代替
@property(nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
@property(nonatomic, strong) NSURL *outputURL;

@end


@implementation CameraHandleObject

- (BOOL)setupSession:(NSError *)error{
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //默认返回后置摄像头
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        }
    } else{
        return NO;
    }
    
    //静态图片
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG}; //JPG格式
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    self.videoQueue = dispatch_queue_create("com.tapharmonic.VideoQueue", NULL);
    return YES;
}


- (void)startSession{
    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{   //异步调用不会阻塞主线程
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession{
    if ([self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

//摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{ //返回指定位置的摄像头
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera{
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamera{
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (BOOL)canSwitchCameras{
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (BOOL)switchCameras{
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                             error:&error];
    if (videoInput) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput]; //必须添加之前移除
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        [self.captureSession commitConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWidthError:error];
        return NO;
    }
    return YES;
}



//调整焦距
- (BOOL)cameraSupportsTapToFocus{
    return [[self activeCamera] isFocusPointOfInterestSupported]; //是否支持兴趣点对焦
}

//point 从屏幕坐标转换为捕捉设备坐标
- (void)focusAtPoint:(CGPoint)point{
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus; //对焦模式
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWidthError:error];
        }
    }
}


//曝光
- (BOOL)cameraSupportsTapToExpose{
    return [[self activeCamera] isExposurePointOfInterestSupported]; //是否支持对一个兴趣点进行曝光
}

static const NSString *THCameraAdjustingExposureContext;
- (void)exposeAtPoint:(CGPoint)point{
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) { //是否支持锁定曝光模式
                [device addObserver:self
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew
                            context:&THCameraAdjustingExposureContext];     //观察adjustingExposure属性的状态 ，可以知道曝光调整何时完成
            }
            
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWidthError:error];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    if (context == &THCameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self
                        forKeyPath:@"adjustingExposure"
                           context:&THCameraAdjustingExposureContext]; //移除 是为了只监视一次
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                } else {
                    [self.delegate deviceConfigurationFailedWidthError:error];
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

//重新设置对焦和曝光
- (void)resetFocusAndExposureModes{
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        
        [device unlockForConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWidthError:error];
    }
}


//闪光灯
- (BOOL)cameraHasFlash{
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode{
    return [[self activeCamera] flashMode];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWidthError:error];
        }
    }
}

- (BOOL)cameraHasTorch{
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode{
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWidthError:error];
        }
    }
}


//静态图片
- (void)captureStillImage{
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo]; //获取当前的connection的指针
    
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    id handler = ^(CMSampleBufferRef sampleBuffer, NSError *error){
        if (sampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [self writeImageToAssetsLibrary:image];
        } else {
            NSLog(@"NULL sampleBuffer: %@", [error localizedDescription]);
        }
    };
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:handler];
}

- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
            case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;   //相反的
            break;
            case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;    //相反的
            break;
    }
    return orientation;
}

- (void)writeImageToAssetsLibrary:(UIImage *)image{ //把照片存入到相册中

}

- (void)postThumbnaiNotification:(UIImage *)image{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:THThumbnailCreatedNotification object:image];
}

//录制(捕捉)
- (BOOL)isRecording{
    return self.movieOutput.isRecording;
}

- (void)startRecording{
    if (![self isRecording]) {
        AVCaptureConnection *videoConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        
        if ([videoConnection isVideoStabilizationSupported]) { //是否支持视频稳定
            videoConnection.enablesVideoStabilizationWhenAvailable = YES;
        }
        
        AVCaptureDevice *device = [self activeCamera];
        if (device.isSmoothAutoFocusSupported) {  //平滑对焦模式的操作
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            } else {
                [self.delegate deviceConfigurationFailedWidthError:error];
            }
        }
        
        self.outputURL = [self uniqueURL];
        [self.movieOutput startRecordingToOutputFileURL:self.outputURL recordingDelegate:self]; //开始录制
    }
}

- (NSURL *)uniqueURL{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [fileManager temporaryDirectoryWithTemplateString:@"kamera.XXXX"];
    if (dirPath) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"kamera_moive.mov"];
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

- (void)stopRecording{
    if ([self isRecording]) {
        [self.movieOutput stopRecording];
    }
}

#pragma mark -- AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    if (error) {
        [self.delegate mediaCaptureFailedWithError:error];
    } else {
        [self writeVideoToAssetLibrary:[self.outputURL copy]];
    }
    self.outputURL = nil;
}

- (void)writeVideoToAssetLibrary:(NSURL *)videoURL{ //存入到相册
    
}

- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL{ //生成缩略图
    dispatch_async(self.videoQueue, ^{
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(100.0, 0.0);
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero
                                                     actualTime:NULL
                                                          error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postThumbnaiNotification:image];
        });
    });
}

@end
