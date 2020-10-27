//
//  LevelPair.m
//  VoiceMemo
//
//  Created by luowailin on 2020/10/26.
//

#import "LevelPair.h"

@implementation LevelPair

+ (instancetype)levelsWithLevel:(float)level peakLevel:(float)peakLevel{
    return [[self alloc] initWithLevel:level peakLevel:peakLevel];
}

- (instancetype)initWithLevel:(float)level peakLevel:(float)peakLevel{
    self = [super init];
    if (self) {
        _level = level;
        _peakLevel = peakLevel;
    }
    return self;
}

@end
