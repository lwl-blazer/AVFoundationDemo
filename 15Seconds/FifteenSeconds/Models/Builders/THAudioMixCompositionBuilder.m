//
//  THAudioMixCompositionBuilder.m
//  FifteenSeconds
//
//  Created by luowailin on 2020/12/1.
//  Copyright © 2020 TapHarmonic, LLC. All rights reserved.
//

#import "THAudioMixCompositionBuilder.h"
#import "THAudioItem.h"
#import "THVolumeAutomation.h"
#import "THAudioMixComposition.h"
#import "THFunctions.h"

@interface THAudioMixCompositionBuilder ()

@property(nonatomic, strong) THTimeline *timeline;
@property(nonatomic, strong) AVMutableComposition *composition;

@end

@implementation THAudioMixCompositionBuilder

- (instancetype)initWithTimeline:(THTimeline *)timeline{
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

- (id<THComposition>)buildComposition{
    self.composition = [AVMutableComposition composition];
    [self addCompositionTrackOfType:AVMediaTypeVideo
                     withMediaItems:self.timeline.videos];
    [self addCompositionTrackOfType:AVMediaTypeAudio
                     withMediaItems:self.timeline.voiceOvers];
    
    AVMutableCompositionTrack *musicTrack = [self addCompositionTrackOfType:AVMediaTypeAudio
                                                             withMediaItems:self.timeline.musicItems];
    
    AVAudioMix *audioMix = [self buildAudioMixWithTrack:musicTrack];
    
    return [THAudioMixComposition compositionWithComposition:self.composition
                                                    audioMix:audioMix];
}

- (AVMutableCompositionTrack *)addCompositionTrackOfType:(NSString *)type
                                     withMediaItems:(NSArray *)mediaItems{
    if (!THIsEmpty(mediaItems)) {
        CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
        AVMutableCompositionTrack *compositionTrack = [self.composition addMutableTrackWithMediaType:type
                                                                                    preferredTrackID:trackID];
        CMTime cursorTime = kCMTimeZero;
        for (THMediaItem *item in mediaItems) {
            if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
                cursorTime = item.startTimeInTimeline;
            }
            
            AVAssetTrack *assetTrack = [[item.asset tracksWithMediaType:type] firstObject];
            
            [compositionTrack insertTimeRange:item.timeRange
                    ofTrack:assetTrack
                    atTime:cursorTime
                                        error:nil];
            
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
        }
        
        return compositionTrack;
    }
    return nil;
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
