//
//  CameraModeView.h
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, CameraMode) {
    CameraModePhoto = 0,
    CameraModeVideo = 1
};

@interface CameraModeView : UIControl

@property(nonatomic, assign) CameraMode cameraMode;

@end

NS_ASSUME_NONNULL_END
