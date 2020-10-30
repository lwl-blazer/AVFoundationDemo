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

@property(nonatomic, strong) AVAsset *asset;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) PlayerView *playerView;

@property(nonatomic, weak) id<Transport>transport;

@property(nonatomic, strong) id timeObserver;
@property(nonatomic, strong) id itemEndObserver;
@property(nonatomic, assign) float lastPlaybackRate;

@end

@implementation PlayerController


- (instancetype)initWithURL:(NSURL *)assetURL
{
    self = [super init];
    if (self) {
        self.asset = [AVAsset assetWithURL:assetURL];
        [self prepareToPlay];
    }
    return self;
}

- (void)prepareToPlay {
    NSArray *keys = @[@"tracks", @"duration", @"commonMetadata"];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset
                           automaticallyLoadedAssetKeys:keys];

    [self.playerItem addObserver:self
                      forKeyPath:STATUS_KEYPATH
                         options:0
                         context:&PlayerItemStatusContext];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.playerView = [[PlayerView alloc] initWithPlayer:self.player];
    self.transport = self.playerView.transport;
    self.transport.delgate = self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    if (context == &PlayerItemStatusContext) {
        // AVFoundation 没有指定在哪个线程执行status改变通知
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerItem removeObserver:self
                                 forKeyPath:STATUS_KEYPATH];
            
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                
                CMTime duration = self.playerItem.duration;
                
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero)
                                      duration:CMTimeGetSeconds(duration)];
                
                [self.transport setTitle:self.asset.title];
                
                [self.player play];
            } else {
                NSLog(@"Error Faile to load Video");
            }
        });
    }
}

/** AVPlayer 时间监听
 *
 * 定期监听
 *      addPeriodicTimeObserverForInterval:queue:usingBlock
 *      如果希望以一定的时间间隔获得通知。如果需要随着时间的变化移动播放头位置或者更新时间显示
 *
 * 边界监听
 *      addBoundaryTimeObserverForTimes:queue:usingBlock
 *      一种更有针对性的方法来监听时间，应用程序可以得到播放器时间轴中多个边界点的遍历结果。这个方法主要用于同步用户界面变更或随着视频播放记录一些非可视化数据，比如25% 50% 75%的边界标记
 *
 */
- (void)addPlayerItemTimeObserver {
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    __weak PlayerController *weakSelf = self;
    
    // 调用addPeriodicTimeObserverForInterval 这个方法会返回一个隐含id类型指针，对这些回调必须保持一个强引用， 这个指针还会用于移除监听器
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];
    }];
}


//条目结束监听 当播放完成时，AVPlayerItem会发送一个AVPlayerItemDidPlayToEndTimeNotification通知
- (void)addItemEndObserverForPlayerItem {
    __weak PlayerController *weakSelf = self;
    self.itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                                             object:self.playerItem
                                                                             queue:[NSOperationQueue mainQueue]
                                                                             usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.transport playbackComplete];
        }];
    }];
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


- (void)dealloc{
    if (self.itemEndObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.itemEndObserver
            name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.player.currentItem];
        self.itemEndObserver = nil;
    }
}
@end
