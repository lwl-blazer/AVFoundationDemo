//
//  LevelMeterView.m
//  VoiceMemo
//
//  Created by luowailin on 2020/10/26.
//

#import "LevelMeterView.h"
#import "LevelMeterColorThreshold.h"

@interface LevelMeterView ()

@property(nonatomic, assign) NSUInteger ledCount;
@property(nonatomic, strong) UIColor *ledBackgroundColor;
@property(nonatomic, strong) UIColor *ledBorderColor;
@property(nonatomic, strong) NSArray <LevelMeterColorThreshold *>*colorThresholds;

@end

@implementation LevelMeterView

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
    
    self.ledCount = 20;
    
    self.ledBackgroundColor = [UIColor colorWithWhite:0.0f
                                                alpha:0.35f];
    self.ledBorderColor = [UIColor blackColor];
    
    UIColor *greenColor = [UIColor colorWithRed:0.458 green:1.000 blue:0.396 alpha:1.000];
    UIColor *yellowColor = [UIColor colorWithRed:1.000 green:0.930 blue:0.315 alpha:1.000];
    UIColor *redColor = [UIColor colorWithRed:1.000 green:0.325 blue:0.329 alpha:1.000];
    
    self.colorThresholds = @[[LevelMeterColorThreshold colorThresholdWithMaxValue:0.5
                                                                            color:greenColor
                                                                             name:@"green"],
    [LevelMeterColorThreshold colorThresholdWithMaxValue:0.8
                                                   color:yellowColor
                                                    name:@"yellow"],
    [LevelMeterColorThreshold colorThresholdWithMaxValue:1.0
                                                   color:redColor
                                                    name:@"red"]];
    
}


- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Quartz 转换实现的原理: Quartz把绘图分成两个部分: 用户空间(即和设备无关) 设备空间; 用户空间和设备空间中间存在一个转换矩阵：CTM
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
    CGContextRotateCTM(context, (CGFloat)-M_PI_2);
    CGRect bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    
    CGFloat lightMinValue = 0.0f;
    NSInteger peakLED = -1;
    
    if (self.peakLevel > 0.0f) {
        peakLED = self.peakLevel * self.ledCount;
        if (peakLED >= self.ledCount) {
            peakLED = self.ledCount - 1;
        }
    }
    
    for (int ledIndex = 0; ledIndex < self.ledCount; ledIndex++) {
        UIColor *ledColor = [self.colorThresholds[0] color];
        CGFloat ledMaxValue = (CGFloat)(ledIndex + 1) / self.ledCount;
        
        for (int colorIndex = 0; colorIndex < self.colorThresholds.count - 1; colorIndex++) {
            LevelMeterColorThreshold *currThreshold = self.colorThresholds[colorIndex];
            LevelMeterColorThreshold *nextThreshold = self.colorThresholds[colorIndex + 1];
            if (currThreshold.maxValue <= ledMaxValue) {
                ledColor = nextThreshold.color;
            }
        }
        
        CGFloat height = CGRectGetHeight(bounds);
        CGFloat width = CGRectGetWidth(bounds);
        
        CGRect ledRect = CGRectMake(0.0f, height * ((CGFloat)ledIndex / self.ledCount), width, height * (1.0 / self.ledCount));
        
        
        // Fill background color
        CGContextSetFillColorWithColor(context, self.ledBackgroundColor.CGColor);
        CGContextFillRect(context, ledRect);
        
        //Draw Light
        CGFloat lightIntensity;
        if (ledIndex == peakLED) {
            lightIntensity = 1.0f;
        } else {
            lightIntensity = clamp((self.level - lightMinValue) / (ledMaxValue - lightMinValue));
        }
        
        UIColor *fillColor = nil;
        if (lightIntensity == 1.0f) {
            fillColor = ledColor;
        } else {
            CGColorRef color = CGColorCreateCopyWithAlpha([ledColor CGColor], lightIntensity);
            fillColor = [UIColor colorWithCGColor:color];
            CGColorRelease(color);
        }
        
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:ledRect cornerRadius:2.0];
        CGContextAddPath(context, fillPath.CGPath);
        
        //stroke border
        CGContextSetStrokeColorWithColor(context, self.ledBorderColor.CGColor);
        UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(ledRect, 0.5, 0.5)
                                                              cornerRadius:2.0f];
        CGContextAddPath(context, strokePath.CGPath);
        
        CGContextDrawPath(context, kCGPathFillStroke);
        
        lightMinValue = ledMaxValue;
    }
}




CGFloat clamp(CGFloat intensity) {
    if (intensity < 0.0f) {
        return 0.0f;
    } else if (intensity >= 1.0) {
        return 1.0f;
    } else {
        return intensity;
    }
}

- (void)resetLevelMeter{
    self.level = 0.0f;
    self.peakLevel = 0.0f;
    [self setNeedsDisplay];
}

@end
