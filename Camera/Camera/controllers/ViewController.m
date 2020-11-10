//
//  ViewController.m
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "CameraController.h"
#import "PreviewView.h"
#import "OverlayView.h"
#import "FlashControl.h"
#import "StatusView.h"
#import "CameraModeView.h"
#import "NSTimer+BLAdditions.h"

@interface ViewController ()<PreviewViewDelegate>

@property(nonatomic, assign) CameraMode cameraMode;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) CameraController *cameraController;


@property (weak, nonatomic) IBOutlet PreviewView *previewView;
@property (weak, nonatomic) IBOutlet OverlayView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateThumbnail:)
                                                 name:ThumbnailCreateNotification
                                               object:nil];
    
    self.cameraMode = CameraModeVideo;
    self.cameraController = [[CameraController alloc] init];
    
    NSError *error;
    if ([self.cameraController setupSession:&error]) {
        [self.previewView setSession:self.cameraController.captureSession];
        self.previewView.delegate = self;
        [self.cameraController startSession];
    } else {
        NSLog(@"Error:%@", error.localizedDescription);
    }
    
    self.previewView.tapToFocusEnabled = self.cameraController.cameraSupportsTapToFocus;
    self.previewView.tapToExposeEnabled = self.cameraController.cameraSupportsTapToExpose;
}

- (IBAction)flashControlChanged:(FlashControl *)sender {
    NSInteger mode = [sender selectedMode];
    if (self.cameraMode == CameraModePhoto) {
        self.cameraController.flashMode = mode;
    } else {
        self.cameraController.torchMode = mode;
    }
}

- (void)updateThumbnail:(NSNotification *)notification{
    UIImage *image = notification.object;
    [self.thumbnailButton setBackgroundImage:image forState:UIControlStateNormal];
    self.thumbnailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailButton.layer.borderWidth = 1.0f;
}

- (IBAction)showCameraRoll:(UIButton *)sender {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:controller animated:YES completion:nil];
}

- (AVAudioPlayer *)playerWithResource:(NSString *)resourceName{
    NSURL *url = [[NSBundle mainBundle] URLForResource:resourceName
                                         withExtension:@"caf"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                                   error:nil];
    [player prepareToPlay];
    player.volume = 0.1f;
    return player;
}

- (IBAction)cameraModeChanged:(CameraModeView *)sender {
    self.cameraMode = sender.cameraMode;
}

- (IBAction)swapCarmers:(UIButton *)sender {
    if ([self.cameraController switchCameras]) {
        BOOL hidden = NO;
        if (self.cameraMode == CameraModePhoto) {
            hidden = !self.cameraController.cameraHasFlash;
        } else {
            hidden = !self.cameraController.cameraHasTorch;
        }
        
        self.overlayView.flashControlHidden = hidden;
        self.previewView.tapToExposeEnabled = self.cameraController.cameraSupportsTapToExpose;
        self.previewView.tapToFocusEnabled = self.cameraController.cameraSupportsTapToFocus;
        [self.cameraController resetFocusAndExposureModes];
    }
}

- (IBAction)captureOrRecord:(UIButton *)sender {
    if (self.cameraMode == CameraModePhoto) {
        [self.cameraController captureStillImage];
    } else {
        if (!self.cameraController.isRecording) {
            dispatch_async(dispatch_queue_create("com.tapharmonic.camera", NULL), ^{
                [self.cameraController startRecording];
                [self startTimer];
            });
        } else {
            [self.cameraController stopRecording];
            [self stopTimer];
        }
        sender.selected = !sender.selected;
    }
}

- (void)startTimer{
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(updateTimeDisplay)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer
                              forMode:NSRunLoopCommonModes];
}

- (void)updateTimeDisplay{
    CMTime duration = self.cameraController.recordedDuration;
    NSUInteger time = (NSUInteger)CMTimeGetSeconds(duration);
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%02i";
    NSString *timeString = [NSString stringWithFormat:format, hours, minutes, seconds];
    self.overlayView.statusView.elapsedTimeLabel.text = timeString;
}

- (void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
    self.overlayView.statusView.elapsedTimeLabel.text = @"00:00:00";
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark -- PreviewViewDelegate
- (void)tappedToFocusAtPoint:(CGPoint)point{
    [self.cameraController focusAtPoint:point];
}

- (void)tappedToExposeAtPoint:(CGPoint)point{
    [self.cameraController exposeAtPoint:point];
}

- (void)tappedToResetFocusAndExposure{
    [self.cameraController resetFocusAndExposureModes];
}

@end
