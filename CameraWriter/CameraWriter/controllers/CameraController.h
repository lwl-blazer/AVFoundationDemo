//
//  CameraController.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "BaseCameraController.h"
#import "ImageTarget.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraController : BaseCameraController

- (void)startRecording;
- (void)stopRecording;

@property(nonatomic, getter=isRecording) BOOL recording;
@property(nonatomic, weak) id<ImageTarget>imageTarget;

@end

NS_ASSUME_NONNULL_END
