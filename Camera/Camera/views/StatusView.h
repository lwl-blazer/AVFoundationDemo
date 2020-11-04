//
//  StatusView.h
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FlashControl;
@interface StatusView : UIView

@property (weak, nonatomic) IBOutlet FlashControl *flashControl;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeLabel;

@end

NS_ASSUME_NONNULL_END
