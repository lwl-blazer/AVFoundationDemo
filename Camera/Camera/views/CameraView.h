//
//  CameraView.h
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PreviewView, OverlayView;
@interface CameraView : UIControl

@property (weak, nonatomic) IBOutlet PreviewView *previewView;
@property (weak, nonatomic) IBOutlet OverlayView *controlView;

@end

NS_ASSUME_NONNULL_END
