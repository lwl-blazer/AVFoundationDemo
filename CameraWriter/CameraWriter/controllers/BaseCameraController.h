//
//  BaseCameraController.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <Foundation/Foundation.h>
#import "CameraControllerDelegate.h"

FOUNDATION_EXPORT NSString *const BLMovieCreateNotification;

NS_ASSUME_NONNULL_BEGIN
@class AVCaptureSession;
@interface BaseCameraController : NSObject

@property(nonatomic, weak) id<CameraControllerDelegate>delegate;

@property(nonatomic, strong, readonly) AVCaptureSession *captureSession;
@property(nonatomic, strong, readonly) dispatch_queue_t dispatchQueue;

- (BOOL)setupSession:(NSError **)error;
- (BOOL)setupSessionInputs:(NSError **)error;
- (BOOL)setupSessionOutputs:(NSError **)error;
- (NSString *)sessionPreset;

- (void)startSession;
- (void)stopSession;

@end

NS_ASSUME_NONNULL_END
