//
//  NSTimer+Additions.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TimerFireBlock)(void);

@interface NSTimer (BLAdditions)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval
                              firing:(TimerFireBlock)fireBlock;

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval
                                repeating:(BOOL)repeat
                              firing:(TimerFireBlock)fireBlock;

@end

NS_ASSUME_NONNULL_END
