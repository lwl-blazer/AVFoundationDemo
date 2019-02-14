//
//  ViewController.m
//  AVFoundationDemo
//
//  Created by blazer on 2019/2/13.
//  Copyright © 2019 blazer. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingSession];
}

- (void)settingSession{
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.usesApplicationAudioSession = NO;
    
    //视频输入
    /**
     //前摄像头只支持这种
     AVCaptureDeviceTypeBuiltInWideAngleCamera     广角相机
     AVCaptureDeviceTypeBuiltInTelephotoCamera //创建比广角相机更长的焦距。只有使用 AVCaptureDeviceDiscoverySession 可以使用
     AVCaptureDeviceTypeBuiltInDualCamera    //最清楚，画面最清楚
     
     */
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    NSError *inputError = nil;
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&inputError];
    if (inputError) {
        NSLog(@"input error");
        return;
    }
    
    if ([self.captureSession canAddInput:deviceInput]) {
        [self.captureSession addInput:deviceInput];
    }
    
    //视频输出
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    //设置视频数据格式
    NSDictionary *videoSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
    [captureOutput setVideoSettings:videoSetting];
    
    //视频输出代理
    dispatch_queue_t outputQueue = dispatch_queue_create("ACVideoCaptureOutputQueue", DISPATCH_QUEUE_SERIAL);
    [captureOutput setSampleBufferDelegate:self
                                     queue:outputQueue];
    
    captureOutput.alwaysDiscardsLateVideoFrames = YES; //丢弃延迟的帧
    
    if ([self.captureSession canAddOutput:captureOutput]) {
        [self.captureSession addOutput:captureOutput];
    }
    
    //设置分辨率
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    
   AVCaptureConnection *captureConnect =  [captureOutput connectionWithMediaType:AVMediaTypeVideo];
    captureConnect.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    if (captureDevice.position == AVCaptureDevicePositionFront && captureConnect.supportsVideoMirroring) {
        captureConnect.videoMirrored = YES;
    }
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer addSublayer:self.previewLayer];
    [self.captureSession startRunning];
    
}

@end
