//
//  OverlayView.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <UIKit/UIKit.h>
#import "FilterSelectorView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverlayView : UIView

@property(weak, nonatomic) IBOutlet FilterSelectorView *filterSelectorView;

@end

NS_ASSUME_NONNULL_END
