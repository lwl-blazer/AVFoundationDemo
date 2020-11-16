//
//  BaseCameraController.h
//  CubeCamera
//
//  Created by luowailin on 2020/11/16.
//

#import <Foundation/Foundation.h>
#import "CameraControllerDelegate.h"

FOUNDATION_EXPORT NSString * _Nonnull const CameraErrorDomain;
FOUNDATION_EXPORT NSString * _Nonnull const ThumbnailCreateNotification;

typedef NS_ENUM(NSUInteger, CameraErrorCode) {
    CameraErrorFailedToAddInput = 98,
    CameraErrorFailedToAddOutput,
};

@class AVCaptureSession, AVCaptureDevice;

NS_ASSUME_NONNULL_BEGIN

@interface BaseCameraController : NSObject

@property(nonatomic, weak) id<CameraControllerDelegate>delegate;
@property(nonatomic, strong, readonly) AVCaptureSession *captureSession;

@property(nonatomic, assign, readonly) NSUInteger cameraCount;
@property(nonatomic, strong, readonly) AVCaptureDevice *activeCamera;

- (BOOL)setupSession:(NSError **)error;
- (BOOL)setupSessionInputs:(NSError **)error;
- (BOOL)setupSessionOutputs:(NSError **)error;

- (void)startSession;
- (void)stopSession;

- (BOOL)switchCameras;

@end

NS_ASSUME_NONNULL_END
