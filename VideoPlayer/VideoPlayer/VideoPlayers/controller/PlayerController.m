//
//  PlayerController.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import "PlayerController.h"
#import <AVFoundation/AVFoundation.h>

#import "Thumbnail.h"
#import "Transport.h"
#import "PlayerView.h"
#import "AVAsset+BLAdditions.h"
#import "UIAlertController+BLAdditions.h"
#import "Notifications.h"

#define STATUS_KEYPATH @"status"

#define REFRESH_INTERVAL 0.5f

static const NSString *PlayerItemStatusContext;

@interface PlayerController ()<TransportDelegate>

@property(nonatomic, strong) PlayerView *playerView;

@end

@implementation PlayerController


- (instancetype)initWithURL:(NSURL *)assetURL
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)prepareToPlay {
    
}

- (void)addPlayerItemTimeObserver {
    
}

#pragma mark -- TransportDelegate

- (void)play{
    
}

- (void)pause{
    
}

- (void)stop{
    
}

- (void)jumpedToTime:(NSTimeInterval)time{
    
}

- (void)scrubbingDidStart {
    
}

- (void)scrubbedToTime:(NSTimeInterval)time{
    
}

- (void)scrubbingDidEnd{
    
}

#pragma mark - Thumbnail Generation
- (void)generateThumbnails {
    
}

- (void)loadMediaOptions {
    
}

- (void)subtitleSelected:(NSString *)subtitle{
    
}

#pragma mark - Housekeeping
- (UIView *)view{
    return self.playerView;
}

@end
