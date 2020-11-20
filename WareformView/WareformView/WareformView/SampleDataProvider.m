//
//  SampleDataProvider.m
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//

#import "SampleDataProvider.h"

@implementation SampleDataProvider

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                  completionBlock:(SampleDataCompletionBlock)completionBlock {
    
    NSString *tracks = @"tracks";
    //异步载入
    [asset loadValuesAsynchronouslyForKeys:@[tracks]
                         completionHandler:^{
        AVKeyValueStatus status = [asset statusOfValueForKey:tracks
                                                       error:nil];
        NSData *sampleData = nil;
        
        if (status == AVKeyValueStatusLoaded) {
            sampleData = [self readAudioSamplesFromAsset:asset];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sampleData);
        });
    }];
}

+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset {

    NSError *error = nil;
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (!assetReader) {
        NSLog(@"AVAssetReader initWithAsset %@", error.localizedDescription);
        return nil;
    }
    
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *track = [tracks firstObject];
    
    //解压设置  AVAudioSettings.h文件中找到许多额外的键，它们可以对格式转换进行更详细的控制
    NSDictionary *outputSettings = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
                                     AVLinearPCMIsBigEndianKey: @NO,
                                     AVLinearPCMIsFloatKey: @NO,
                                     AVLinearPCMBitDepthKey: @(16)};
    
    AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:outputSettings];
    [assetReader addOutput:trackOutput];
    [assetReader startReading];
    
    
    NSMutableData *sampleData = [NSMutableData data];
    while (assetReader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
        if (sampleBuffer) {
            // get buffer
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
            // get length
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            SInt16 sampleBytes[length];
            
            // copy
            CMBlockBufferCopyDataBytes(blockBufferRef,
                                       0,
                                       length,
                                       sampleBytes);
            
            [sampleData appendBytes:sampleBytes length:length];
            
            // CMSampleBufferInvalidate 函数指定样本buffer已经使用和不可再继续使用
            CMSampleBufferInvalidate(sampleBuffer);
            // 释放
            CFRelease(sampleBuffer);
        }
    }
    
    if (assetReader.status == AVAssetReaderStatusCompleted) {
        return sampleData;
    } else {
        NSLog(@"Failed to read audio samples from asset");
        return nil;
    }
}

@end
