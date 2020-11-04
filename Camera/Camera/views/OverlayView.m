//
//  OverlayView.m
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import "OverlayView.h"
#import "CameraModeView.h"
#import "StatusView.h"
#import "FlashControl.h"

@implementation OverlayView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    [self.modeView addTarget:self action:@selector(modeChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)modeChange:(CameraModeView *)modeView{
    BOOL photoModeEnabled = modeView.cameraMode == CameraModePhoto;
    UIColor *toColor = photoModeEnabled ? [UIColor blackColor] : [UIColor colorWithWhite:0.0 alpha:0.5];
    CGFloat toOpacity = photoModeEnabled ? 0.0f : 1.0f;
    self.statusView.layer.backgroundColor = toColor.CGColor;
    self.statusView.elapsedTimeLabel.layer.opacity = toOpacity;
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if ([self.statusView pointInside:[self convertPoint:point toView:self.statusView] withEvent:event]) {
        [self.modeView pointInside:[self convertPoint:point toView:self.modeView] withEvent:event];
        return YES;
    }
    return NO;
}

- (void)setFlashControlHidden:(BOOL)flashControlHidden{
    if (_flashControlHidden != flashControlHidden) {
        _flashControlHidden = flashControlHidden;
        self.statusView.flashControl.hidden = flashControlHidden;
    }
}


@end
