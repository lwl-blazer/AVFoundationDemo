//
//  THTransitionCompositionBuilder.m
//  FifteenSeconds
//
//  Created by luowailin on 2020/12/1.
//  Copyright © 2020 TapHarmonic, LLC. All rights reserved.
//

#import "THTransitionCompositionBuilder.h"

#import "THVideoItem.h"
#import "THAudioItem.h"
#import "THAudioItem.h"
#import "THVolumeAutomation.h"
#import "THVolumeAutomation.h"
#import "THTransitionComposition.h"
#import "THFunctions.h"

@interface THTransitionCompositionBuilder ()

@property(nonatomic, strong) THTimeline *timeline;
@property(nonatomic, strong) AVMutableComposition *composition;
@property(nonatomic, weak) AVMutableCompositionTrack *musicTrack;

@end


@implementation THTransitionCompositionBuilder

- (instancetype)initWithTimeline:(THTimeline *)timeline{
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

- (id<THComposition>)buildComposition{
    self.composition = [AVMutableComposition composition];
    [self buildCompositionTracks];
    AVVideoComposition *videoComposition = [self buildVideoComposition];
    AVAudioMix *audioMix = [self buildAudioMixWithTrack:self.musicTrack];
    return [[THTransitionComposition alloc] initWithComposition:self.composition
                                               videoComposition:videoComposition
                                               audioMix:audioMix];
}

- (void)buildCompositionTracks{
    CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
    AVMutableCompositionTrack *compositionTrackA = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                 preferredTrackID:trackID];
    AVMutableCompositionTrack *compositionTrackB = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                 preferredTrackID:trackID];
    
    NSArray *videoTracks = @[compositionTrackA, compositionTrackB];
    
    CMTime cursorTime = kCMTimeZero;
    CMTime transitionDuration = kCMTimeZero;
    
    if (!THIsEmpty(self.timeline.transitions)) {
        transitionDuration = 
    }
}

- (AVVideoComposition *)buildVideoComposition{
    
}


- (AVAudioMix *)buildAudioMixWithTrack:(AVMutableCompositionTrack *)track{
    THAudioItem *item = [self.timeline.musicItems firstObject];
    if (item) {
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        
        AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
        
        for (THVolumeAutomation *automation in item.volumeAutomation) {
            [parameters setVolumeRampFromStartVolume:automation.startVolume
                    toEndVolume:automation.endVolume
                                           timeRange:automation.timeRange];
        }
        audioMix.inputParameters = @[parameters];
        return audioMix;
    }
    return nil;
}

@end
