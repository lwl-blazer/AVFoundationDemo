//
//  PlayerController.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerController : NSObject

- (instancetype)initWithURL:(NSURL *)assetURL;

@property(nonatomic, strong, readonly) UIView *view;

@end

NS_ASSUME_NONNULL_END
