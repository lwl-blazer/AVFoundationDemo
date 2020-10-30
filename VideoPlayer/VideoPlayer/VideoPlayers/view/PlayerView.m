//
//  PlayerView.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/30.
//

#import "PlayerView.h"
#import "OverlayView.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerView ()

@property(nonatomic, strong) OverlayView *overlayView;

@end

@implementation PlayerView

+ (Class)layerClass{
    return [AVPlayerLayer class];
}

- (instancetype)initWithPlayer:(AVPlayer *)player
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [(AVPlayerLayer *)[self layer] setPlayer:player];
        
        [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
        [self addSubview:self.overlayView];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.overlayView.frame = self.bounds;
}

- (id<Transport>)transport{
    return self.overlayView;
}

@end
