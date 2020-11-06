//
//  CameraController.m
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import "CameraController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSFileManager+BLAdditions.h"

NSString *const ThumbnailCreateNotification = @"ThumbnailCreated";

@interface CameraController ()<AVCapturePhotoCaptureDelegate>

@property(nonatomic, strong) dispatch_queue_t videoQueue;
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;
@property(nonatomic, strong) AVCapturePhotoOutput *imageOutput;
@property(nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;

@property(nonatomic, strong) NSURL *outputURL;

@end


@implementation CameraController

- (BOOL)setupSession:(NSError **)error {

    // Listing 6.4
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                             error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice
                                                                             error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        }
    } else {
        return NO;
    }
    
    self.imageOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    // 必须先添加到capturesession 才能设置
    [self.imageOutput capturePhotoWithSettings:[AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecJPEG}] delegate:self];
    
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    self.videoQueue = dispatch_queue_create("com.tapharmonic.VideoQueue", NULL);
    
    return YES;
}

- (void)startSession {

    // Listing 6.5
    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {

    // Listing 6.5
    if ([self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

#pragma mark - Device Configuration
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray <AVCaptureDevice *>*devices = [self discoveryDeviceWithPosition:position];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (NSUInteger)cameraCount {
    // Listing 6.6
    AVCaptureDevicePosition position;
    if ([self activeCamera].position == AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
    } else {
        position = AVCaptureDevicePositionBack;
    }
    return [self discoveryDeviceWithPosition:position].count;
}

- (NSArray <AVCaptureDevice *>*)discoveryDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray *types = nil;
    if (@available(iOS 13.0, *)) {
        types = @[AVCaptureDeviceTypeBuiltInWideAngleCamera,
                  AVCaptureDeviceTypeBuiltInTripleCamera,
                  AVCaptureDeviceTypeBuiltInDualCamera];
    } else if (@available(iOS 10.2, *)) {
        types = @[AVCaptureDeviceTypeBuiltInDualCamera, AVCaptureDeviceTypeBuiltInWideAngleCamera];
    } else if (@available(iOS 11.1, *)) {
        types = @[AVCaptureDeviceTypeBuiltInWideAngleCamera,
                  AVCaptureDeviceTypeBuiltInTrueDepthCamera];
    } else  {
        types = @[AVCaptureDeviceTypeBuiltInTelephotoCamera, AVCaptureDeviceTypeBuiltInWideAngleCamera];
    }
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:types
                                                                                                               mediaType:AVMediaTypeVideo
                                                                                                                position:position];
    return discoverySession.devices;
}

- (AVCaptureDevice *)activeCamera {

    // Listing 6.6
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamera {

    // Listing 6.6
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 0) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
           device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (BOOL)canSwitchCameras {

    // Listing 6.6
    return self.cameraCount > 0;
}

- (BOOL)switchCameras {

    // Listing 6.7
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput =  [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                          error:&error];
    if (videoInput) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        [self.captureSession commitConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
    }
    
    return YES;
}

#pragma mark - Focus Methods

- (BOOL)cameraSupportsTapToFocus {
    
    // Listing 6.8
    
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {
    
    // Listing 6.8
    AVCaptureDevice *device = [self activeCamera];
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

#pragma mark - Exposure Methods

- (BOOL)cameraSupportsTapToExpose {
 
    // Listing 6.9
    
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString *CameraAdjustingExposureContext;
- (void)exposeAtPoint:(CGPoint)point {

    // Listing 6.9
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposurePointOfInterest = point;
                    device.exposureMode = exposureMode;
                    if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                        [device addObserver:self
                                            forKeyPath:@"adjustingExposure"
                                            options:NSKeyValueObservingOptionNew
                                    context:&CameraAdjustingExposureContext];
                    }
                    [device unlockForConfiguration];
                }else{
                    [self.delegate deviceConfigurationFailedWithError:error];
                }
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    // Listing 6.9
    if (context == &CameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self
                        forKeyPath:@"adjustingExposure"
                           context:&CameraAdjustingExposureContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    [self.delegate deviceConfigurationFailedWithError:error];
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

- (void)resetFocusAndExposureModes {

    // Listing 6.10
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
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}

#pragma mark - Flash and Torch Modes

- (BOOL)cameraHasFlash {

    // Listing 6.11
    return [[self activeCamera] hasFlash];;
}

- (AVCaptureFlashMode)flashMode {

    // Listing 6.11
    return self.imageOutput.photoSettingsForSceneMonitoring.flashMode;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {

    // Listing 6.11
   
}

- (BOOL)cameraHasTorch {

    // Listing 6.11
    
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {

    // Listing 6.11
    
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {

    // Listing 6.11
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}


#pragma mark - Image Capture Methods

- (void)captureStillImage {

    // Listing 6.12

}

- (AVCaptureVideoOrientation)currentVideoOrientation {
    
    // Listing 6.12
    
    // Listing 6.13
    
    return 0;
}


- (void)writeImageToAssetsLibrary:(UIImage *)image {

    // Listing 6.13
    
}

- (void)postThumbnailNotifification:(UIImage *)image {

    // Listing 6.13
    
}

#pragma mark - Video Capture Methods

- (BOOL)isRecording {

    // Listing 6.14
    
    return NO;
}

- (void)startRecording {

    // Listing 6.14

}

- (CMTime)recordedDuration {
    return self.movieOutput.recordedDuration;
}

- (NSURL *)uniqueURL {


    // Listing 6.14
    
    return nil;
}

- (void)stopRecording {

    // Listing 6.14
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {

    // Listing 6.15

}

- (void)writeVideoToAssetsLibrary:(NSURL *)videoURL {

    // Listing 6.15
    
}

- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {

    // Listing 6.15
    
}


#pragma mark --
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error API_AVAILABLE(ios(11.0)){
    
}



@end
