//
//  CameraController.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "CameraController.h"
#import <AVFoundation/AVFoundation.h>
#import "MovieWriter.h"
#import <Photos/Photos.h>

@interface CameraController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, MovieWriterDelegate>

@property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property(nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;
@property(nonatomic, strong) MovieWriter *movieWriter;

@end

@implementation CameraController

- (BOOL)setupSessionOutputs:(NSError **)error {

    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    //当结合OpenGL ES和CoreImage时这一格式非常适合
    NSDictionary *outputSetting = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    self.videoDataOutput.videoSettings = outputSetting;
    
    //是否丢弃帧 当设置为NO时，会给委托方法一些额外的时间来处理样本buffer,不过这会增加内存消耗。不过在处理每个样本buffer时都要做到尽可能高效，这样才能保障实时性 能
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.dispatchQueue];
    
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
    } else {
        return NO;
    }
    
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.dispatchQueue];
    if ([self.captureSession canAddOutput:self.audioDataOutput]) {
        [self.captureSession addOutput:self.audioDataOutput];
    } else {
        return NO;
    }
    
    NSString *fileType = AVFileTypeQuickTimeMovie;
    NSDictionary *videoSettings = [self.videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:fileType];
    
    NSDictionary *audioSetting = [self.audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:fileType];
    
    self.movieWriter = [[MovieWriter alloc] initWithVideoSettings:videoSettings audioSettings:audioSetting dispatchQueue:self.dispatchQueue];
    
    self.movieWriter.delegate = self;
    
    return YES;
}

- (NSString *)sessionPreset {
    return AVCaptureSessionPresetMedium;
}

- (void)startRecording {
    [self.movieWriter startWriting];
    self.recording = YES;
}

- (void)stopRecording {
    [self.movieWriter stopWriting];
    self.recording = NO;
}


#pragma mark - Delegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

    [self.movieWriter processSampleBuffer:sampleBuffer];
    
    if (captureOutput == self.videoDataOutput) {
      
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer
                                                       options:nil];
        
        [self.imageTarget setImage:sourceImage];
    }
}

//MovieWriterDelegate
- (void)didWriteMovieAtURL:(NSURL *)outputURL {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"save video success");
        } else {
            NSLog(@"save video faile");
            [self.delegate assetLibraryWriteFailedWithError:error];
        }
    }];
}

@end
