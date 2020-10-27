//
//  LevelMeterView.h
//  VoiceMemo
//
//  Created by luowailin on 2020/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LevelMeterView : UIView

@property(nonatomic, assign)CGFloat level;
@property(nonatomic, assign) CGFloat peakLevel;

- (void)resetLevelMeter;

@end

NS_ASSUME_NONNULL_END
