//
//  ViewController.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "ViewController.h"
#import "OverlayView.h"
#import <GLKit/GLKit.h>
#import "CameraController.h"
#import "PreviewView.h"
#import "ContextManager.h"
#import "OverlayView.h"
#import "PhotoFilters.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet OverlayView *overlayView;
@property (strong, nonatomic) CameraController *controller;
@property (strong, nonatomic) PreviewView *previewView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.controller = [[CameraController alloc] init];
    
    CGRect frame = self.view.bounds;
    EAGLContext *eaglContext = [ContextManager sharedInstance].eaglContext;
    self.previewView = [[PreviewView alloc] initWithFrame:frame
                                                  context:eaglContext];
    
    self.previewView.filter = [PhotoFilters defaultFilter];
    
    self.controller.imageTarget = self.previewView;
    
    self.previewView.coreImageContext = [ContextManager sharedInstance].ciContext;
    [self.view insertSubview:self.previewView belowSubview:self.overlayView];
    
    NSError *error;
    if ([self.controller setupSession:&error]) {
        [self.controller startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (IBAction)captureOrRecord:(UIButton *)sender {
    if (!self.controller.isRecording) {
        dispatch_async(dispatch_queue_create("com.tapharmonic.camera", NULL), ^{
            [self.controller startRecording];
        });
    } else {
        [self.controller stopRecording];
    }
    sender.selected = !sender.selected;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
