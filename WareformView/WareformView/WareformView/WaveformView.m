//
//  WaveformView.m
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//

#import "WaveformView.h"
#import "SampleDataProvider.h"
#import "SampleDataFilter.h"

static const CGFloat THWidthScaling = 0.95;
static const CGFloat THHeightScaling = 0.85;


@interface WaveformView ()

@property (strong, nonatomic) SampleDataFilter *filter;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;


@end


@implementation WaveformView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    self.backgroundColor = [UIColor clearColor];
    self.waveColor = [UIColor whiteColor];
    
    self.layer.cornerRadius = 2.0f;
    self.layer.masksToBounds = YES;
    
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleLarge;
    _loadingView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    
    CGSize size = _loadingView.frame.size;
    CGFloat x = (self.bounds.size.width - size.width) / 2;
    CGFloat y = (self.bounds.size.height - size.height) / 2;
    _loadingView.frame = CGRectMake(x, y, size.width, size.height);
    [self addSubview:_loadingView];
    
    [_loadingView startAnimating];
}

- (void)setWaveColor:(UIColor *)waveColor {
    _waveColor = waveColor;
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = waveColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setAsset:(AVAsset *)asset {
}

- (void)drawRect:(CGRect)rect {
}

@end
