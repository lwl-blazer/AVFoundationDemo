//
//  WaveformView.h
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AVAsset;

@interface WaveformView : UIView

@property(nonatomic, strong) AVAsset *asset;
@property(nonatomic, strong) UIColor *waveColor;

@end

NS_ASSUME_NONNULL_END
