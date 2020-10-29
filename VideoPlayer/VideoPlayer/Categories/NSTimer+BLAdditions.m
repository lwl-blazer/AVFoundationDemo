//
//  NSTimer+Additions.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/28.
//

#import "NSTimer+BLAdditions.h"

@implementation NSTimer (BLAdditions)

+ (void)executeTimerBlock:(NSTimer *)timer {
    TimerFireBlock block = [timer userInfo];
    block();
}

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval
                              firing:(TimerFireBlock)fireBlock{
    return [self scheduledTimerWithTimeInterval:inTimeInterval
                                      repeating:NO
                                         firing:fireBlock];
}

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval
                           repeating:(BOOL)repeat firing:(TimerFireBlock)fireBlock{
    id block = [fireBlock copy];
    return [self scheduledTimerWithTimeInterval:inTimeInterval
                                         target:self
                                         selector:@selector(executeTimerBlock:)
                                         userInfo:block
                                         repeats:repeat];
}



@end
