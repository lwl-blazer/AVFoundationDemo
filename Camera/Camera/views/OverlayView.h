//
//  OverlayView.h
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CameraModeView, StatusView;
@interface OverlayView : UIView

@property (weak, nonatomic) IBOutlet CameraModeView *modeView;
@property (weak, nonatomic) IBOutlet StatusView *statusView;

@property (assign, nonatomic) BOOL flashControlHidden;

@end

NS_ASSUME_NONNULL_END
