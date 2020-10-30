//
//  Transport.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TransportDelegate <NSObject>

- (void)play;
- (void)pause;
- (void)stop;

- (void)scrubbingDidStart;
- (void)scrubbedToTime:(NSTimeInterval)time;
- (void)scrubbingDidEnd;

- (void)jumpedToTime:(NSTimeInterval)time;

@optional
- (void)subtitleSelected:(NSString *)subtitle;

@end


@protocol Transport <NSObject>

@property (weak, nonatomic) id<TransportDelegate>delegate;

- (void)setTitle:(NSString *)title;
- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
- (void)setScrubbingTime:(NSTimeInterval)time;
- (void)playbackComplete;
- (void)setSubtitles:(NSArray *)subtitles;

@end

NS_ASSUME_NONNULL_END
