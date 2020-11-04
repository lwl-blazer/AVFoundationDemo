//
//  PreviewView.h
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PreviewViewDelegate <NSObject>

- (void)tappedToFocusAtPoint:(CGPoint)point;
- (void)tappedToExposeAtPoint:(CGPoint)point;
- (void)tappedToResetFocusAndExposure;

@end
@class AVCaptureSession;
@interface PreviewView : UIView

@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, weak) id<PreviewViewDelegate>delegate;

@property(nonatomic, assign) BOOL tapToFocusEnabled;
@property(nonatomic, assign) BOOL tapToExposeEnabled;

@end

NS_ASSUME_NONNULL_END
