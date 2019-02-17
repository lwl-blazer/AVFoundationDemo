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
@property(nonatomic, strong) AVCaptureConnection *captureConnection;

@property(nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property(nonatomic, strong) AVCaptureVideoDataOutput *captureDeviceDataOutput;

@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property(nonatomic, assign) BOOL isCapturing; //是否已经在采集
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingSession];
    [self.startButton setTitle:@"停止" forState:UIControlStateSelected];
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
   self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&inputError];
    if (inputError) {
        NSLog(@"input error");
        return;
    }
    
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    
    //视频输出
    self.captureDeviceDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    //设置视频数据格式
    NSDictionary *videoSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey, nil];
    [ self.captureDeviceDataOutput setVideoSettings:videoSetting];
    self.captureConnection = [ self.captureDeviceDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //视频输出代理
    dispatch_queue_t outputQueue = dispatch_queue_create("ACVideoCaptureOutputQueue", DISPATCH_QUEUE_SERIAL);
    [ self.captureDeviceDataOutput setSampleBufferDelegate:self
                                     queue:outputQueue];
    
     self.captureDeviceDataOutput.alwaysDiscardsLateVideoFrames = YES; //丢弃延迟的帧
    
    if ([self.captureSession canAddOutput: self.captureDeviceDataOutput]) {
        [self.captureSession addOutput: self.captureDeviceDataOutput];
    }
    
    //设置分辨率
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    
    /*
   AVCaptureConnection *captureConnect =  [captureOutput connectionWithMediaType:AVMediaTypeVideo];
    captureConnect.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    if (captureDevice.position == AVCaptureDevicePositionFront && captureConnect.supportsVideoMirroring) {
        captureConnect.videoMirrored = YES;
    }
    */
    
    [self adjustFrameRate:30];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 200);
    self.previewLayer.frame = frame;
    
   NSLog(@"%@", NSStringFromCGPoint( [self.previewLayer captureDevicePointOfInterestForPoint:CGPointMake(200, 200)])); //获取屏幕坐标 转成设备坐标
   NSLog(@"%@", NSStringFromCGPoint([self.previewLayer pointForCaptureDevicePointOfInterest:CGPointMake(0.5, 0.4)]));  //获取设置坐标  转换屏幕坐标
    
    [self.videoView.layer  addSublayer:self.previewLayer];
}

- (IBAction)presetAction:(id)sender { //分辨率
}

- (IBAction)frameRateAction:(id)sender { //帖率
}

- (IBAction)resetVideoAction:(id)sender { //反转摄像头
    [self reverseCamera];
}

- (IBAction)startAction:(UIButton *)sender { //开始结束
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startCapture];
    } else {
        [self stopCapture];
    }
}

- (void)startCapture{ //开始采集
    if (self.isCapturing) {
        return;
    }
    [self.captureSession startRunning];
    self.isCapturing = YES;
}

- (void)stopCapture{
    if (!self.isCapturing) {
        return;
    }
    
    [self.captureSession stopRunning];
    self.isCapturing = NO;
}



//设置帧率
- (NSError *)adjustFrameRate:(NSInteger)frameRate{
    NSError *error = nil;
    
    AVFrameRateRange *frameRateRange = self.captureDeviceInput .device.activeFormat.videoSupportedFrameRateRanges.firstObject;
    
    if (frameRate > frameRateRange.maxFrameRate || frameRate < frameRateRange.minFrameRate) {
        error = [NSError errorWithDomain:@"adjust Frame Rate Error" code:1 userInfo:nil];
        return error;
    }
    
    //一定要进行判断   如果超出的话，强行设置崩溃
    [self.captureDeviceInput.device lockForConfiguration:&error];
    self.captureDeviceInput.device.activeVideoMinFrameDuration = CMTimeMake(1, (int)frameRate);
    self.captureDeviceInput.device.activeVideoMaxFrameDuration = CMTimeMake(1, (int)frameRate);
    [self.captureDeviceInput.device unlockForConfiguration];
    
    return error;
}

//修改视频分辨率
- (void)changeSessionPreset:(AVCaptureSessionPreset)sessionPreset{
    if ([self.captureSession canSetSessionPreset:sessionPreset]) {
        self.captureSession.sessionPreset = sessionPreset;
    }
}

//翻转摄像头
- (NSError *)reverseCamera{
    
    AVCaptureDevicePosition devicePosition = self.captureDeviceInput.device.position;
    AVCaptureDevicePosition toDevicePostion = AVCaptureDevicePositionUnspecified;
    switch (devicePosition) {
        case AVCaptureDevicePositionFront:
            toDevicePostion = AVCaptureDevicePositionBack;
            break;
        case AVCaptureDevicePositionBack:
            toDevicePostion = AVCaptureDevicePositionFront;
            break;
        default:
            toDevicePostion = AVCaptureDevicePositionFront;
            break;
    }
    
    AVCaptureDevice *newCaptureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    
    NSError *error = nil;
    AVCaptureDeviceInput *newDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newCaptureDevice error:&error];
    
    //开始修改
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.captureDeviceInput];
    if ([self.captureSession canAddInput:newDeviceInput]) {
        [self.captureSession addInput:newDeviceInput];
        self.captureDeviceInput = newDeviceInput;
    }
    [self.captureSession commitConfiguration];
    
    //重新获取连接并设置方向
    self.captureConnection = [self.captureDeviceDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    return error;
}





#pragma mark -- Delegate --

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}



@end
