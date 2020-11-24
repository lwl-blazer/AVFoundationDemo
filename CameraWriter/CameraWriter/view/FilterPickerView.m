//
//  FilterPickerView.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "FilterPickerView.h"
#import "BLNotifications.h"

@interface FilterPickerView ()

@property(nonatomic, strong) NSArray *thumbnails;
@property(nonatomic, strong) UIScrollView *scrollView;

@end


@implementation FilterPickerView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)setupView {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_scrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildScrubber:(NSNotification *)notification {

}


@end
