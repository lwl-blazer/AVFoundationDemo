//
//  OverlayView.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import <UIKit/UIKit.h>
#import "Transport.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverlayView : UIView<Transport>

@property(nonatomic, weak) id<TransportDelegate>delegate;

- (void)setCurrentTime:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
