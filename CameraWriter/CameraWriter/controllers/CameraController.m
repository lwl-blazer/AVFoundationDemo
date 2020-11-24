//
//  CameraController.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "CameraController.h"
#import <AVFoundation/AVFoundation.h>
#import "MovieWriter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CameraController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property(nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;

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
    return YES;
}

- (NSString *)sessionPreset {
    return AVCaptureSessionPresetMedium;
}

- (void)startRecording {

    // Listing 8.17

}

- (void)stopRecording {

    // Listing 8.17

}


#pragma mark - Delegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

    if (captureOutput == self.videoDataOutput) {
      
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer
                                                       options:nil];
        
        [self.imageTarget setImage:sourceImage];
    }
}

- (void)didWriteMovieAtURL:(NSURL *)outputURL {

    // Listing 8.17
    
}

@end
