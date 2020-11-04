//
//  CameraController.h
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ThumbnailCreateNotification;

@protocol CameraControllerDelegate <NSObject>

- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFaileWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

@end

@interface CameraController : NSObject

@property(nonatomic, weak) id<CameraControllerDelegate>delegate;
@property(nonatomic, strong, readonly) AVCaptureSession *captureSession;

// Session Configuration
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

// Camera Device Support
- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;

@property(nonatomic, assign, readonly) NSUInteger cameraCount;
@property(nonatomic, assign, readonly) BOOL cameraHasTorch;
@property(nonatomic, assign, readonly) BOOL cameraHasFlash;
@property(nonatomic, assign, readonly) BOOL cameraSupportsTapToFocus;
@property(nonatomic, assign, readonly) BOOL cameraSupportsTapToExpose;

@property(nonatomic, assign) AVCaptureTorchMode torchMode;
@property(nonatomic, assign) AVCaptureFlashMode flashMode;


- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;

/** Media Capture Methods **/

// Still Image Capture
- (void)captureStillImage;

// Video Recording
- (void)startRecording;
- (void)stopRecording;
- (BOOL)isRecording;
- (CMTime)recordedDuration;

@end

NS_ASSUME_NONNULL_END
