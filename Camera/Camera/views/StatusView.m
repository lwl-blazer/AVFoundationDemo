//
//  StatusView.m
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import "StatusView.h"
#import "FlashControl.h"

@interface StatusView ()<FlashControlDelegate>

@end

@implementation StatusView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupView];
}

- (void)setupView{
    self.flashControl.delegate = self;
}

- (void)flashControlWillExpand{
    [UIView animateWithDuration:0.2
                     animations:^{
        self.elapsedTimeLabel.alpha = 0.0f;
    }];
}

- (void)flashControlDidCollapse{
    [UIView animateWithDuration:0.1f
                     animations:^{
        self.elapsedTimeLabel.alpha = 1.0f;
    }];
}

@end
