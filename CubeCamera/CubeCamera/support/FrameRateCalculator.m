//
//  FrameRateCalculator.m
//  CubeCamera
//
//  Created by luowailin on 2020/11/16.
//

#import "FrameRateCalculator.h"
#import <AVFoundation/AVFoundation.h>

@interface FrameRateCalculator ()

@property(nonatomic, strong) NSMutableArray *previousSecondTimestamps;

@end

@implementation FrameRateCalculator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _previousSecondTimestamps = [NSMutableArray array];
    }
    return self;
}

- (void)calculateFramerateAtTimestamp:(CMTime)timestamp{
    NSValue *timestampValue = [NSValue valueWithCMTime:timestamp];
    [self.previousSecondTimestamps addObject:timestampValue];
    
    CMTime oneSecond = CMTimeMake(1, 1);
    CMTime oneSecondAgo = CMTimeSubtract(timestamp, oneSecond);
    
    CMTime time = [[self.previousSecondTimestamps firstObject] CMTimeValue];
    while (CMTIME_COMPARE_INLINE(time, <, oneSecondAgo)) {
        [self.previousSecondTimestamps removeObjectAtIndex:0];
        time = [[self.previousSecondTimestamps firstObject] CMTimeValue];
    }
    
    Float64 newRate = [self.previousSecondTimestamps count];
    self.frameRate = (self.frameRate + newRate) / 2;
}

@end
