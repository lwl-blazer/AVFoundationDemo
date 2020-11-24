//
//  CaptureButton.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CaptureButtonMode){
    CaptureButtonModePhoto = 0,
    CaptureButtonModeVideo = 1
};

@interface CaptureButton : UIButton

+ (instancetype)captureButton;
+ (instancetype)captureButtonWithMode:(CaptureButtonMode)captureButtonMode;

@property(nonatomic) CaptureButtonMode captureButtonMode;

@end

NS_ASSUME_NONNULL_END
