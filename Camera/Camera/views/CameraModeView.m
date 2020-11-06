//
//  CameraModeView.m
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import "CameraModeView.h"
#import "UIView+BLAdditions.h"
#import <CoreText/CoreText.h>
#import "CaptureButton.h"

#define COMPONENT_MARGIN 20.0f
#define BUTTON_SIZE CGSizeMake(68.0f, 68.8f)

@interface CameraModeView ()

@property(nonatomic, strong) UIColor *foregroundColor;
@property(nonatomic, strong) CATextLayer *videoTextLayer;
@property(nonatomic, strong) CATextLayer *photoTextLayer;

@property(nonatomic, strong) UIView *labelContainerView;
@property (weak, nonatomic) IBOutlet CaptureButton *captureButton;

@property(nonatomic, assign) BOOL maxLeft;
@property(nonatomic, assign) BOOL maxRight;
@property(nonatomic, assign) CGFloat videoStringWidth;

@end

@implementation CameraModeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    /*
    _maxRight = YES;
    self.cameraMode = CameraModeVideo;
    
    //self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    _foregroundColor = [UIColor colorWithRed:1.000 green:0.734 blue:0.006 alpha:1.000];
    
    _videoTextLayer = [self textLayerWithTitle:@"VIDEO"];
    _videoTextLayer.foregroundColor = self.foregroundColor.CGColor;
    
    _photoTextLayer = [self textLayerWithTitle:@"PHOTO"];
    
    CGSize size = [@"VIDEO" sizeWithAttributes:[self fontAttributes]];
    self.videoStringWidth = size.width;
    
    _videoTextLayer.frame = CGRectMake(0.0f, 0.0f, 40.0f, 20.0f);
    _photoTextLayer.frame = CGRectMake(60.0f, 0.0f, 50.0f, 20.0f);
    
    CGRect containerRect = CGRectMake(0.0f, 0.0f, 120.0, 20.0);
    _labelContainerView = [[UIView alloc] initWithFrame:containerRect];
    _labelContainerView.backgroundColor = [UIColor clearColor];
    
    [_labelContainerView.layer addSublayer:_videoTextLayer];
    [_labelContainerView.layer addSublayer:_photoTextLayer];

    [self addSubview:_labelContainerView];
    
    self.labelContainerView.centerY += 8.0f;*/
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(switchMode:)];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(switchMode:)];
    
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:rightRecognizer];
    [self addGestureRecognizer:leftRecognizer];
}

- (CATextLayer *)textLayerWithTitle:(NSString *)title{
    CATextLayer *layer = [CATextLayer layer];
    layer.string = [[NSAttributedString alloc] initWithString:title attributes:[self fontAttributes]];
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

- (void)toggleSelected {
    self.captureButton.selected = !self.captureButton.selected;
}

- (void)switchMode:(UISwipeGestureRecognizer *)sender{
    NSLog(@"switchMode");
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft && !self.maxLeft) {
        [UIView animateWithDuration:0.28
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            self.labelContainerView.frameX -= 62;
            [UIView animateWithDuration:0.3
                                  delay:0.3
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                [CATransaction disableActions];
                self.photoTextLayer.foregroundColor = self.foregroundColor.CGColor;
                self.videoTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
            } completion:NULL];
        } completion:^(BOOL finished) {
            self.cameraMode = CameraModePhoto;
            self.maxLeft = YES;
            self.maxRight = NO;
        }];
    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight && !self.maxRight) {
        [UIView animateWithDuration:0.28
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            self.labelContainerView.frameX += 62;
            self.videoTextLayer.foregroundColor = self.foregroundColor.CGColor;
            self.photoTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
        } completion:^(BOOL finished) {
            self.cameraMode = CameraModeVideo;
            self.maxRight = YES;
            self.maxLeft = NO;
        }];
    }
}

- (void)setCameraMode:(CameraMode)cameraMode{
    if (_cameraMode != cameraMode) {
        _cameraMode = cameraMode;
        if (cameraMode == CameraModePhoto) {
            self.captureButton.selected = NO;
            self.captureButton.captureButtonMode = CaptureButtonModePhoto;
            //self.layer.backgroundColor = [UIColor blackColor].CGColor;
        } else {
            self.captureButton.captureButtonMode = CaptureButtonModeVideo;
           // self.layer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (NSDictionary *)fontAttributes {
    return @{NSFontAttributeName:[UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:17.0f],
             NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)drawRect:(CGRect)rect{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, self.foregroundColor.CGColor);
//
//    CGRect circleRect = CGRectMake(CGRectGetMidX(rect) - 4.0f, 2.0f, 6.0f, 6.0f);
//    CGContextFillEllipseInRect(context, circleRect);
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.labelContainerView.frameX = CGRectGetMidX(self.bounds) - (self.videoStringWidth / 2.0f);
}

@end
