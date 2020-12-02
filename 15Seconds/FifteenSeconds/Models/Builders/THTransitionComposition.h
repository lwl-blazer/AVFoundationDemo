//
//  THTransitionComposition.h
//  FifteenSeconds
//
//  Created by luowailin on 2020/12/1.
//  Copyright © 2020 TapHarmonic, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THComposition.h"

NS_ASSUME_NONNULL_BEGIN

@interface THTransitionComposition : NSObject<THComposition>

@property(strong, nonatomic, readonly) AVComposition *composition;
@property(strong, nonatomic, readonly) AVVideoComposition *videoComposition;
@property(strong, nonatomic, readonly) AVAudioMix *audioMix;

- (instancetype)initWithComposition:(AVComposition *)composition
                   videoComposition:(AVVideoComposition *)videoComposition
                           audioMix:(AVAudioMix *)audioMix;

@end

NS_ASSUME_NONNULL_END
