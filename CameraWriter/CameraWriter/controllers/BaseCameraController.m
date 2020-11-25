//
//  BaseCameraController.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "BaseCameraController.h"
#import "NSFileManager+BLAdditions.h"
#import "BLError.h"
#import <AVFoundation/AVFoundation.h>

NSString *const ThumbnailCreatedNotification = @"ThumbnailCreated";
NSString *const MovieCreateNotification = @"MovieCreated";

@interface BaseCameraController ()

@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;

@property(nonatomic, strong) NSURL *outputURL;

@end

@implementation BaseCameraController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dispatchQueue = dispatch_queue_create("com.tapharmonic.CaptureDispatchQueue", NULL);
    }
    return self;
}

- (BOOL)setupSession:(NSError *__autoreleasing  _Nullable *)error{
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = [self sessionPreset];

    if (![self setupSessionInputs:error]) {
        return NO;
    }

    if (![self setupSessionOutputs:error]) {
        return NO;
    }
    
    return YES;
}


- (NSString *)sessionPreset{
    return AVCaptureSessionPresetHigh;
}

- (BOOL)setupSessionInputs:(NSError *__autoreleasing  _Nullable *)error{
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                             error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Failed to add video input."};
            *error = [NSError errorWithDomain:CameraErrorDomain
                                         code:CameraErrorFailedToAddInput
                                     userInfo:userInfo];
            return NO;
        }
    } else {
        return NO;
    }
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        } else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Failed to add audio input."};
            *error = [NSError errorWithDomain:CameraErrorDomain
                                         code:CameraErrorFailedToAddInput
                                     userInfo:userInfo];
            return NO;
        }
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)setupSessionOutputs:(NSError *__autoreleasing  _Nullable *)error{
    return YES;
}

- (void)startSession{
    dispatch_async(self.dispatchQueue, ^{
        if (![self.captureSession isRunning]) {
            [self.captureSession startRunning];
        }
    });
}

- (void)stopSession{
    dispatch_async(self.dispatchQueue, ^{
        if ([self.captureSession isRunning]) {
            [self.captureSession stopRunning];
        }
    });
}

#pragma mark --
- (AVCaptureDevice *)activeCamera{
    return self.activeVideoInput.device;
}

- (NSArray <AVCaptureDevice *> *)cameraWithPosition:(AVCaptureDevicePosition)position{
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera,
                                                                                                                           AVCaptureDeviceTypeBuiltInTelephotoCamera,
                                                                                                                           ] mediaType:AVMediaTypeVideo position:position];
    return discoverySession.devices;
}


- (AVCaptureDevice *)inactiveCamera{
    AVCaptureDevice *device = nil;
    if ([self activeCamera].position == AVCaptureDevicePositionBack) {
        device = [self cameraWithPosition:AVCaptureDevicePositionFront].firstObject;
    } else {
        device = [self cameraWithPosition:AVCaptureDevicePositionBack].firstObject;
    }
    return device;
}

- (BOOL)switchCameras{
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
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
        return NO;
    }
    return YES;
}

@end
