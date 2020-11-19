//
//  WaveformView.m
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//

#import "WaveformView.h"
#import "SampleDataProvider.h"
#import "SampleDataFilter.h"
#import <QuartzCore/QuartzCore.h>

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
    
    
    if (@available(iOS 13.0, *)) {
        UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleLarge;
        _loadingView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    } else {
        UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhiteLarge;
        _loadingView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    }
        
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
    
    if (_asset != asset) {
        _asset = asset;
        [SampleDataProvider loadAudioSamplesFromAsset:asset completionBlock:^(NSData * _Nonnull sampleData) {
            self.filter = [[SampleDataFilter alloc] initWithData:sampleData];
            [self.loadingView stopAnimating];
            [self setNeedsDisplay];
        }];
    }
    
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, THWidthScaling, THHeightScaling);
    CGFloat xOffset = self.bounds.size.width - (self.bounds.size.width * THWidthScaling);
    
    CGFloat yOffset = self.bounds.size.height - (self.bounds.size.height * THHeightScaling);
    
    CGContextTranslateCTM(context, xOffset / 2, yOffset / 2 );
    
    NSArray *filteredSamples = [self.filter filteredSamplesForSize:self.bounds.size];
    
    CGFloat midY = CGRectGetMidY(rect);
    
    CGMutablePathRef halfPath = CGPathCreateMutable();
    
    CGPathMoveToPoint(halfPath, NULL, 0.0f, midY);
    
    for (NSUInteger i = 0; i < filteredSamples.count; i ++) {
        float sample = [filteredSamples[i] floatValue];
        CGPathAddLineToPoint(halfPath, NULL, i, midY - sample);
    }
    
    CGPathAddLineToPoint(halfPath, NULL, filteredSamples.count, midY);
    
    CGMutablePathRef fullPath = CGPathCreateMutable();
    CGPathAddPath(fullPath, NULL, halfPath);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(rect));
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGPathAddPath(fullPath, &transform, halfPath);
    
    CGContextAddPath(context, fullPath);
    CGContextSetFillColorWithColor(context, self.waveColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    
    CGPathRelease(halfPath);
    CGPathRelease(fullPath);
}

@end
