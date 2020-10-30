//
//  FilmstripView.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import "FilmstripView.h"
#import "Thumbnail.h"
#import "OverlayView.h"
#import "Notifications.h"

@interface FilmstripView ()

@property(nonatomic, strong) NSArray *thumbnails;
@property(nonatomic, strong) UIScrollView *scrollView;

@end

@implementation FilmstripView

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 43, [UIScreen mainScreen].bounds.size.width, 56.0)];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.scrollView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(buildScrubber:)
            name:ThumbnailsGeneratedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildScrubber:(NSNotification *)notification{
    
    self.thumbnails = [notification object];

    CGFloat currentX = 0.0f;

    CGSize size = [(UIImage *)[[self.thumbnails firstObject] image] size];
    // Scale retina image down to appropriate size
    CGSize imageSize = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(0.5, 0.5));
    CGRect imageRect = CGRectMake(currentX, 0, imageSize.width, imageSize.height);

    CGFloat imageWidth = CGRectGetWidth(imageRect) * self.thumbnails.count;
    self.scrollView.contentSize = CGSizeMake(imageWidth, imageRect.size.height);

    for (NSUInteger i = 0; i < self.thumbnails.count; i++) {
        Thumbnail *timedImage = self.thumbnails[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.adjustsImageWhenHighlighted = NO;
        [button setBackgroundImage:timedImage.image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(imageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(currentX, 0, imageSize.width, imageSize.height);
        button.tag = i;
        [self.scrollView addSubview:button];
        currentX += imageSize.width;
    }
    
}

- (void)imageButtonTapped:(UIButton *)sender {
    Thumbnail *image = self.thumbnails[sender.tag];
    if (image) {
        if ([self.superview respondsToSelector:@selector(setCurrentTime:)]) {
            [(OverlayView *)self.superview setCurrentTime:CMTimeGetSeconds(image.time)];
        }
    }
}

@end
