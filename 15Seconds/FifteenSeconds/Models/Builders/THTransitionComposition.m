//
//  THTransitionComposition.m
//  FifteenSeconds
//
//  Created by luowailin on 2020/12/1.
//  Copyright © 2020 TapHarmonic, LLC. All rights reserved.
//

#import "THTransitionComposition.h"

@implementation THTransitionComposition

- (instancetype)initWithComposition:(AVComposition *)composition videoComposition:(AVVideoComposition *)videoComposition audioMix:(AVAudioMix *)audioMix{
    self = [super init];
    if (self) {
        _composition = composition;
        _videoComposition = videoComposition;
        _audioMix = audioMix;
    }
    return self;
}

- (AVPlayerItem *)makePlayable{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.composition copy]];
    playerItem.audioMix = self.audioMix;
    playerItem.videoComposition = self.videoComposition;
    return playerItem;
}

- (AVAssetExportSession *)makeExportable{
    NSString *preset = AVAssetExportPresetHighestQuality;
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:[self.composition copy] presetName:preset];
    session.audioMix = self.audioMix;
    session.videoComposition = self.videoComposition;
    return session;
}




@end
