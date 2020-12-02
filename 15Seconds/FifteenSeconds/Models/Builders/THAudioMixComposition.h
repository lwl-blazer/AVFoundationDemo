//
//  THAudioMixComposition.h
//  FifteenSeconds
//
//  Created by luowailin on 2020/12/1.
//  Copyright © 2020 TapHarmonic, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THComposition.h"

NS_ASSUME_NONNULL_BEGIN

@interface THAudioMixComposition : NSObject<THComposition>

@property(strong, nonatomic, readonly) AVAudioMix *audioMix;
@property(strong, nonatomic, readonly) AVComposition *composition;

+ (instancetype)compositionWithComposition:(AVComposition *)composition
                                  audioMix:(AVAudioMix *)audioMix;

- (instancetype)initWithComposition:(AVComposition *)composition
                           audioMix:(AVAudioMix *)audioMix;

@end

NS_ASSUME_NONNULL_END
