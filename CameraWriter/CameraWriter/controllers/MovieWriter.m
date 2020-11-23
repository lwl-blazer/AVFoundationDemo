//
//  MovieWriter.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "MovieWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "ContextManager.h"
#import "BLFunctions.h"
#import "PhotoFilters.h"
#import "BLNotifications.h"

static NSString *const VideoFilename = @"movie.mov";

@interface MovieWriter ()

@property(nonatomic, strong) AVAssetWriter *assetWriter;
@property(nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property(nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelBufferAdaptor;

@property(nonatomic, strong) dispatch_queue_t dispatchQueue;

@property(nonatomic, weak) CIContext *ciContext;
@property(nonatomic, assign) CGColorSpaceRef colorSpace;
@property(nonatomic, strong) CIFilter *activeFilter;

@property(nonatomic, strong) NSDictionary *videoSettings;
@property(nonatomic, strong) NSDictionary *audioSettings;

@property(nonatomic, assign) BOOL firstSample;

@end



@implementation MovieWriter

- (id)initWithVideoSettings:(NSDictionary *)videoSettings
              audioSettings:(NSDictionary *)audioSettings
              dispatchQueue:(dispatch_queue_t)dispatchQueue {

    self = [super init];
    if (self) {

        // Listing 8.13

    }
    return self;
}

- (void)dealloc {

    // Listing 8.13

}

- (void)filterChanged:(NSNotification *)notification {

    // Listing 8.13

}

- (void)startWriting {

    // Listing 8.14

}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer {

    // Listing 8.15

}

- (void)stopWriting {

    // Listing 8.16
    
}

- (NSURL *)outputURL {
    NSString *filePath =
        [NSTemporaryDirectory() stringByAppendingPathComponent:VideoFilename];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

@end
