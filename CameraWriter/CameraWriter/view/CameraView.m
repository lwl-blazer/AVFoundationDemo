//
//  CameraView.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "CameraView.h"
#import "PreviewView.h"
#import "OverlayView.h"

@interface CameraView ()

@property (weak, nonatomic) IBOutlet PreviewView *previewView;
@property (weak, nonatomic) IBOutlet OverlayView *controlsView;

@end

@implementation CameraView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
}

@end
