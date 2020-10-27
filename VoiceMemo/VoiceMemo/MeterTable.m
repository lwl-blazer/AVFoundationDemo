//
//  MeterTable.m
//  VoiceMemo
//
//  Created by luowailin on 2020/10/26.
//

#import "MeterTable.h"

//解析率 解析等级
#define MIN_DB -60.0
#define TABLE_SIZE 300

@interface MeterTable ()

@property(nonatomic, assign) float scaleFactor;
@property(nonatomic, strong) NSMutableArray *meterTable;

@end

/**
 * 分贝值需要先从对数形式的-160到0范围转换为线性的0到1形式。每次请求这个计量数据，都需要做这个转换，更好的解决方案是只计算一次这些变化，之后按需要进行查找
 *
 * MeterTable类是Apple C++基于MeterTable类的Objective-c 端口
 */

@implementation MeterTable

- (id)init {
    self = [super init];
    if (self) {
        float dbResolution = MIN_DB / (TABLE_SIZE - 1);

        self.meterTable = [NSMutableArray arrayWithCapacity:TABLE_SIZE];
        self.scaleFactor = 1.0f / dbResolution;

        float minAmp = dbToAmp(MIN_DB);
        float ampRange = 1.0 - minAmp;
        float invAmpRange = 1.0 / ampRange;

        for (int i = 0; i < TABLE_SIZE; i++) {
            float decibels = i * dbResolution;
            float amp = dbToAmp(decibels);
            float adjAmp = (amp - minAmp) * invAmpRange;
            self.meterTable[i] = @(adjAmp);
        }
    }
    return self;
}

//转换为线性范围内的值
float dbToAmp(float dB) {
    return powf(10.0f, 0.05f * dB);
}

- (float)valueForPower:(float)power {
    if (power < MIN_DB) {
        return 0.0f;
    } else if (power >= 0.0f) {
        return 1.0f;
    } else {
        int index = (int) (power * self.scaleFactor);
        return [self.meterTable[index] floatValue];
    }
}

@end
