//
//  FlashControl.h
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FlashControl;
@protocol FlashControlDelegate <NSObject>

@optional
- (void)flashControlWillExpand;
- (void)flashControlDidExpand;
- (void)flashControlWillCollapse;
- (void)flashControlDidCollapse;

@end

@interface FlashControl : UIControl

@property(nonatomic, assign) NSInteger selectedMode;
@property(nonatomic, weak) id<FlashControlDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
