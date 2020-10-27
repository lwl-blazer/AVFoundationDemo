//
//  LevelPair.h
//  VoiceMemo
//
//  Created by luowailin on 2020/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LevelPair : NSObject

@property(nonatomic, readonly) float level;
@property(nonatomic, readonly) float peakLevel;

+ (instancetype)levelsWithLevel:(float)level peakLevel:(float)peakLevel;
- (instancetype)initWithLevel:(float)level peakLevel:(float)peakLevel;

@end

NS_ASSUME_NONNULL_END
