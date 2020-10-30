//
//  PlayerView.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/30.
//

#import <UIKit/UIKit.h>
#import "Transport.h"

NS_ASSUME_NONNULL_BEGIN

@class AVPlayer;
@interface PlayerView : UIView

- (instancetype)initWithPlayer:(AVPlayer *)player;
@property(nonatomic, weak) id<Transport>transport;


@end

NS_ASSUME_NONNULL_END
