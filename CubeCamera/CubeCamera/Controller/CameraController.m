//
//  CameraController.m
//  CubeCamera
//
//  Created by luowailin on 2020/11/16.
//

#import "CameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface CameraController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@end


@implementation CameraController

- (instancetype)initWithContext:(EAGLContext *)context{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)sessionPreset {
    return AVCaptureSessionPreset640x480;
}

- (BOOL)setupSessionOutputs:(NSError *__autoreleasing  _Nullable *)error{
    return NO;
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}

- (void)cleanupTextures{
    
}

@end
