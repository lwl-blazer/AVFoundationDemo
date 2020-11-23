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

@implementation CameraController

- (BOOL)setupSessionOutputs:(NSError **)error {

    // Listing 8.10

    // Listing 8.17

    return NO;
}

- (NSString *)sessionPreset {

    // Listing 8.10

    return nil;
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

    // Listing 8.11

    // Listing 8.17
}

- (void)didWriteMovieAtURL:(NSURL *)outputURL {

    // Listing 8.17
    
}

@end
