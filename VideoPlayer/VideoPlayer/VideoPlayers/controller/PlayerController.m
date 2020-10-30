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

@property(nonatomic, strong) AVAssetImageGenerator *imageGenerator;

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
    self.transport.delegate = self;
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
                
                [self generateThumbnails];
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
    [self.player play];
}

- (void)pause{
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
}

- (void)stop{
    [self.player setRate:0.0f]; //相当调用了pause
    [self.transport playbackComplete];
}

- (void)jumpedToTime:(NSTimeInterval)time{
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)scrubbingDidStart {
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
}

- (void)scrubbedToTime:(NSTimeInterval)time{
    //由于移动滑动条位置时会迅速触发，所以首先应该在播放条目上调用cancelPendingSeeks 这是经过性能优化的，如果前一个搜索请求没有完成，则避免操作堆积情况的出现
    [self.playerItem cancelPendingSeeks];
    //seekToTime发起一个新的搜索
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)scrubbingDidEnd{
    [self addPlayerItemTimeObserver];
    if (self.lastPlaybackRate > 0.0f) {
        [self.player play];
    }
}

#pragma mark - Thumbnail Generation
- (void)generateThumbnails {
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    
    self.imageGenerator.maximumSize = CGSizeMake(200.0f, 0.0f);
    
    CMTime duration = self.asset.duration;
    
    NSMutableArray *times = [NSMutableArray array];
    CMTimeValue increment = duration.value / 20;
    CMTimeValue currentValue = kCMTimeZero.value;
    while (currentValue <= duration.value) {
        CMTime time = CMTimeMake(currentValue, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;
    }
    
    __block NSUInteger imageCount = times.count;
    __block NSMutableArray *images = [NSMutableArray array];
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
    completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            Thumbnail *thumbnail = [Thumbnail thumbnailWithImage:image
                                                            time:actualTime];
            [images addObject:thumbnail];
        } else {
            NSLog(@"Failed to create thumbnail image.");
        }
        
        if (--imageCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ThumbnailsGeneratedNotification
                                                                    object:images];
            });
        }
    }];
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
