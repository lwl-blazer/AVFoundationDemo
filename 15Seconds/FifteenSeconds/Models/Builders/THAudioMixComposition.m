//
//  THAudioMixComposition.m
//  FifteenSeconds
//
//  Created by luowailin on 2020/12/1.
//  Copyright © 2020 TapHarmonic, LLC. All rights reserved.
//

#import "THAudioMixComposition.h"

@interface THAudioMixComposition ()

@property(nonatomic, strong) AVAudioMix *audioMix;
@property(nonatomic, strong) AVComposition *composition;

@end

@implementation THAudioMixComposition

+ (instancetype)compositionWithComposition:(AVComposition *)composition audioMix:(AVAudioMix *)audioMix{
    return [[self alloc] initWithComposition:composition
                                    audioMix:audioMix];
}

- (instancetype)initWithComposition:(AVComposition *)composition audioMix:(AVAudioMix *)audioMix{
    self = [super init];
    if (self) {
        _composition = composition;
        _audioMix = audioMix;
    }
    return self;
}

- (AVPlayerItem *)makePlayable{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.composition copy]];
    playerItem.audioMix = self.audioMix;
    return playerItem;
}

- (AVAssetExportSession *)makeExportable{
    NSString *preset = AVAssetExportPresetHighestQuality;
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:[self.composition copy]
                                                                      presetName:preset];
    session.audioMix = self.audioMix;
    return session;
}

@end
