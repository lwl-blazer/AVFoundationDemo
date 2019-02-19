//
//  AVCaptureDevice+BLAdditions.m
//  AVFoundationDemo
//
//  Created by blazer on 2019/2/19.
//  Copyright © 2019 blazer. All rights reserved.
//

#import "AVCaptureDevice+BLAdditions.h"

@interface BLQualityOfService : NSObject

@property(nonatomic, strong, readonly) AVCaptureDeviceFormat *format;
@property(nonatomic, strong, readonly) AVFrameRateRange *frameRateRange;
@property(nonatomic, assign, readonly) BOOL isHighFrameRate;

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format
               frameRateRange:(AVFrameRateRange *)frameRateRange;

- (BOOL)isHighFrameRate;

@end

@implementation BLQualityOfService

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format frameRateRange:(AVFrameRateRange *)frameRateRange{
    return [[self alloc] initWithFormat:format frameRateRange:frameRateRange];
}

- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format
                frameRateRange:(AVFrameRateRange *)frameRateRange{
    self = [super init];
    if (self) {
        _format = format;
        _frameRateRange = frameRateRange;
    }
    return self;
}

- (BOOL)isHighFrameRate{
    return self.frameRateRange.maxFrameRate > 30.0f;
}

@end

@implementation AVCaptureDevice (BLAdditions)

- (BOOL)supportsHighFrameRateCapture{
    if (![self hasMediaType:AVMediaTypeVideo]) {   //是否为视频设备
        return NO;
    }
    return [self findHighestQualityOfService].isHighFrameRate;
}

- (BLQualityOfService *)findHighestQualityOfService{
    AVCaptureDeviceFormat *maxFormat = nil;
    AVFrameRateRange *maxFrameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in self.formats) {
        FourCharCode codecType = CMVideoFormatDescriptionGetCodecType(format.formatDescription); //CMFormatDescriptionRef是一个Core Media的隐含类型，提供了许多相关信息
        
        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {     //筛选出视频格式
            NSArray *frameRateRanges = format.videoSupportedFrameRateRanges; //AVCaptureDeviceFormat的AVFrameRateRange对象集
            for (AVFrameRateRange *range in frameRateRanges) {
                if (range.maxFrameRate > maxFrameRateRange.maxFrameRate) { //判断找到最大的
                    maxFormat = format;
                    maxFrameRateRange = range;
                }
            }
        }
    }
    return [BLQualityOfService qosWithFormat:maxFormat frameRateRange:maxFrameRateRange];
}

- (BOOL)enableHighFrameRateCapture:(NSError * _Nullable __autoreleasing *)error{
    
    BLQualityOfService *qos = [self findHighestQualityOfService];
    if (!qos.isHighFrameRate) {
        
        if (error) {
            NSString *message = @"Device does not support high FPS capture";
            
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message};
            NSUInteger code = 1002;
            *error = [NSError errorWithDomain:@"com.tapharmonic.THCameraErrorDomain" code:code userInfo:userInfo];
        }
        return NO;
    }

    if ([self lockForConfiguration:error]) {
        CMTime minFrameDuration = qos.frameRateRange.minFrameDuration;
        
        self.activeFormat = qos.format;
        self.activeVideoMinFrameDuration = minFrameDuration;
        self.activeVideoMaxFrameDuration = minFrameDuration; //AVFoundation通常处理帧时长数据，使用CMTime实例而不是帧率。minFrameDuration值为maxFrameRate的倒数值，比如帧率为60FPS,则duration为1/60秒
        
        [self unlockForConfiguration];
        
        return YES;
    }
    
    return NO;
}

@end
