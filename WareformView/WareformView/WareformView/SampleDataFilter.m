//
//  SampleDataFilter.m
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//
#import <UIKit/UIKit.h>
#import "SampleDataFilter.h"

@interface SampleDataFilter ()

@property(nonatomic, strong) NSData *sampleData;

@end


@implementation SampleDataFilter

- (instancetype)initWithData:(NSData *)sampleData {
    self = [super init];
    if (self) {
        _sampleData = sampleData;
    }
    return self;
}

- (NSArray *)filteredSamplesForSize:(CGSize)size {
    
    NSMutableArray *filteredSamples = [[NSMutableArray alloc] init];
    
    // 总样本数
    NSUInteger sampleCount = self.sampleData.length / sizeof(SInt16);
    
    // 多少个箱子
    NSUInteger binSize = sampleCount / size.width;
    
    SInt16 *bytes = (SInt16 *)self.sampleData.bytes;
    
    SInt16 maxSample = 0;
    
    for (NSUInteger i = 0; i < sampleCount; i += binSize) {
        SInt16 sampleBin[binSize];
        // 分箱装入数据
        for (NSUInteger j = 0; j < binSize; j ++) {
            // 当处理音频样本时，要时刻记得字节的顺序，所以要用到CFSwapInt16LittleToHost函数来确保样本是按主机内置的字节顺序处理的
            sampleBin[j] = CFSwapInt16LittleToHost(bytes[i + j]);
        }
        //当前箱子中的最大值
        SInt16 value = [self maxValueInArray:sampleBin ofSize:binSize];
        [filteredSamples addObject:@(value)];
        
        if (value > maxSample) { // 记录所有的箱子中的最大值
            maxSample = value;
        }
    }
    
    CGFloat scaleFactor = (size.height / 2) / maxSample;
    
    for (NSUInteger i = 0; i < filteredSamples.count; i++) {
        filteredSamples[i] = @([filteredSamples[i] integerValue] * scaleFactor);
    }

    return filteredSamples;
}

- (SInt16)maxValueInArray:(SInt16[])values ofSize:(NSUInteger)size {
    
    SInt16 maxValue = 0;
    for (int i = 0; i < size; i ++) {
        if (abs(values[i]) > maxValue) {
            maxValue = abs(values[i]);
        }
    }
    return maxValue;
}

@end
