//
//  CameraHandleObject.h
//  AVFoundationDemo
//
//  Created by blazer on 2019/2/16.
//  Copyright © 2019 blazer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const THThumbnailCreatedNotification;

@protocol CameraHandleObjectDelegate <NSObject>

- (void)deviceConfigurationFailedWidthError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

@end


@interface CameraHandleObject : NSObject

@property(nonatomic, weak) id<CameraHandleObjectDelegate>delegate;
@property(nonatomic, strong, readonly) AVCaptureSession *captureSession;


//session configuration
- (BOOL)setupSession:(NSError *)error;
- (void)startSession;
- (void)stopSession;


//camera device support
- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;
@property(nonatomic, strong, readonly) AVCaptureDevice *activeCamera;
@property(nonatomic, assign, readonly) NSUInteger cameraCount;

@property(nonatomic, assign, readonly) BOOL cameraHasTorch;
@property(nonatomic, assign, readonly) BOOL cameraHasFlash;
@property(nonatomic, assign, readonly) BOOL cameraSupportsTapToFocus;
@property(nonatomic, assign, readonly) BOOL cameraSupportsTapToExpose;

@property(nonatomic, assign) AVCaptureTorchMode torchMode;
@property(nonatomic, assign) AVCaptureFlashMode flashMode;


//Tap to Methods
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;

//Media Capture Methods
- (void)captureStillImage;   //Still Image Capture

//Video Recording
- (void)startRecording;
- (void)stopRecording;
- (BOOL)isRecording;

@end

NS_ASSUME_NONNULL_END
