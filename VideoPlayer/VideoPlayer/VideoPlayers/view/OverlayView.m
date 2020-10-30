//
//  OverlayView.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import "OverlayView.h"
#import "FilmstripView.h"
#import "UIView+BLAdditions.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSTimer+BLAdditions.h"

#import "SubtitleViewController.h"

#define ENABLE_AIRPLAY 0
#define ENABLE_SUBTITLES 1

@interface OverlayView ()<SubtitleViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet FilmstripView *filmStripView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *filmstripToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *togglePlaybackButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *scrubberSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;

@property(nonatomic, assign) BOOL controlsHidden;
@property(nonatomic, assign) BOOL filmstripHidden;

@property(nonatomic, strong) NSArray *excludedViews;
@property(nonatomic, assign) CGFloat infoViewOffset;
@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, assign) BOOL scrubbing;

@property (nonatomic, strong) NSArray *subtitles;
@property (nonatomic, copy) NSString *selectedSubtitle;
@property (nonatomic, assign) CGFloat lastPlaybackRate;
@property (nonatomic, strong) MPVolumeView *volumeView;

@end

@implementation OverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.filmstripHidden = YES;
    self.excludedViews = @[self.navigationBar, self.toolBar, self.filmStripView];

    UIImage *thumbNormalImage = [UIImage imageNamed:@"knob"];
    UIImage *thumbHighlightedImage = [UIImage imageNamed:@"knob_highlighted"];
    [self.scrubberSlider setThumbImage:thumbNormalImage forState:UIControlStateNormal];
    [self.scrubberSlider setThumbImage:thumbHighlightedImage forState:UIControlStateHighlighted];

    self.infoView.hidden = YES;

    [self calculateInfoViewOffset];

    // Set up actions
    [self.scrubberSlider addTarget:self action:@selector(showPopupUI) forControlEvents:UIControlEventValueChanged];
    [self.scrubberSlider addTarget:self action:@selector(hidePopupUI) forControlEvents:UIControlEventTouchUpInside];
    [self.scrubberSlider addTarget:self action:@selector(unhidePopupUI) forControlEvents:UIControlEventTouchDown];

    self.filmStripView.layer.shadowOffset = CGSizeMake(0, 2);
    self.filmStripView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.filmStripView.layer.shadowRadius = 2.0f;
    self.filmStripView.layer.shadowOpacity = 0.8f;

    [self enableAirplay];

    [self resetTimer];
}

- (void)enableAirplay {
#if ENABLE_AIRPLAY == 1
    UIImage *airplayImage = [UIImage imageNamed:@"airplay"];
    self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    self.volumeView.showsVolumeSlider = NO;
    self.volumeView.showsRouteButton = YES;
    [self.volumeView setRouteButtonImage:airplayImage forState:UIControlStateNormal];

    [self.volumeView sizeToFit];

    NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbar.items];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.volumeView];
    [items addObject:item];
    self.toolbar.items = items;
#endif
}

- (void)resetTimer {
    [self.timer invalidate];
    if (!self.scrubbing) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 firing:^{
            if (self.timer.isValid && !self.controlsHidden) {
                [self toggleControls:nil];
            }
        }];
    }
}

- (void)calculateInfoViewOffset {
    [self.infoView sizeToFit];
    self.infoViewOffset = ceilf(CGRectGetWidth(self.infoView.frame) / 2);
}



- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (void)showPopupUI {
    self.infoView.hidden = NO;
    CGRect trackRect = [self.scrubberSlider convertRect:self.scrubberSlider.bounds toView:nil];
    CGRect thumbRect = [self.scrubberSlider thumbRectForBounds:self.scrubberSlider.bounds trackRect:trackRect value:self.scrubberSlider.value];
    
    CGRect rect = self.infoView.frame;
    rect.origin.x = (thumbRect.origin.x) - self.infoViewOffset + 16;
    rect.origin.y = self.boundsHeight - 80;
    self.infoView.frame = rect;
    
    self.currentTimeLabel.text = @"-- : --";
    self.remainingTimeLabel.text = @"-- : --";
    
    [self setScrubbingTime:self.scrubberSlider.value];
    [self.delegate scrubbedToTime:self.scrubberSlider.value];
}

- (void)unhidePopupUI {
    self.infoView.hidden = NO;
    self.infoView.alpha = 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        self.infoView.alpha = 1.0f;
    }];
    self.scrubbing = YES;
    [self resetTimer];
    [self.delegate scrubbingDidStart];
}

- (void)hidePopupUI {
    [UIView animateWithDuration:0.3f animations:^{
        self.infoView.alpha = 0.0f;
    } completion:^(BOOL complete) {
        self.infoView.alpha = 1.0f;
        self.infoView.hidden = YES;
    }];
    self.scrubbing = NO;
    [self.delegate scrubbingDidEnd];
}


- (IBAction)closeWindow:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    [self.delegate stop];
    self.filmStripView.hidden = YES;
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)filmstripToggle:(id)sender {
    [UIView animateWithDuration:0.35 animations:^{
        if (self.filmstripHidden) {
            self.filmStripView.hidden = NO;
            self.filmStripView.frameY = 0;
        } else {
            self.filmStripView.frameY -= self.filmStripView.frameHeight;
        }
        self.filmstripHidden = !self.filmstripHidden;
    } completion:^(BOOL complete) {
        if (self.filmstripHidden) {
            self.filmStripView.hidden = YES;
        }
    }];
    self.filmstripToggleButton.selected = !self.filmstripToggleButton.selected;
}

- (IBAction)togglePlayback:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate) {
        if (sender.selected) {
            [self.delegate play];
        } else {
            [self.delegate pause];
        }
    }
}

- (IBAction)toggleControls:(id)sender {
    [UIView animateWithDuration:0.35 animations:^{
        if (!self.controlsHidden) {
            if (!self.filmstripHidden) {
                [UIView animateWithDuration:0.35 animations:^{
                    self.filmStripView.frameY -= self.filmStripView.frameHeight;
                    self.filmstripHidden = YES;
                    self.filmstripToggleButton.selected = NO;
                } completion:^(BOOL complete) {
                    self.filmStripView.hidden = YES;
                    [UIView animateWithDuration:0.35 animations:^{
                        self.navigationBar.frameY -= self.navigationBar.frameHeight;
                        self.toolBar.frameY += self.toolBar.frameHeight;
                    }];
                }];
            } else {
                self.navigationBar.frameY -= self.navigationBar.frameHeight;
                self.toolBar.frameY += self.toolBar.frameHeight;
            }
        } else {
            self.navigationBar.frameY += self.navigationBar.frameHeight;
            self.toolBar.frameY -= self.toolBar.frameHeight;
        }
        self.controlsHidden = !self.controlsHidden;
    }];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    [self.delegate jumpedToTime:currentTime];
}

#pragma mark -- Transport
- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    NSInteger currentSeconds = ceilf(time);
    double remainingTime = duration - time;
    self.currentTimeLabel.text = [self formatSeconds:currentSeconds];
    self.remainingTimeLabel.text = [self formatSeconds:remainingTime];
    self.scrubberSlider.minimumValue = 0.0f;
    self.scrubberSlider.maximumValue = duration;
    self.scrubberSlider.value = time;
}

- (void)playbackComplete {
    self.scrubberSlider.value = 0.0f;
    self.togglePlaybackButton.selected = NO;
}

- (void)setScrubbingTime:(NSTimeInterval)time {
    self.timeLabel.text = [self formatSeconds:time];
}

- (void)setTitle:(nonnull NSString *)title {
    self.navigationBar.topItem.title = title ? title : @"Video Player";
}

- (void)setSubtitles:(NSArray *)subtitles {
#if ENABLE_SUBTITLES == 1
    NSMutableArray *filtered = [NSMutableArray array];
    [filtered addObject:@"None"];
    for (NSString *sub in subtitles) {
        if ([sub rangeOfString:@"Forced"].location == NSNotFound) {
            [filtered addObject:sub];
        }
    }
    _subtitles = filtered;
    if (_subtitles && _subtitles.count > 1) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolBar.items];
        UIImage *image = [UIImage imageNamed:@"subtitles"];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(showSubtitles:)];
        [items addObject:item];
        self.toolBar.items = items;
        [self calculateInfoViewOffset];
    }
#endif
}

- (void)showSubtitles:(id)sender {
    [self.timer invalidate];
    [self.delegate pause];
    self.lastPlaybackRate = [[(NSObject *)self.delegate valueForKey:@"lastPlaybackRate"] floatValue];
    SubtitleViewController *controller = [[SubtitleViewController alloc] initWithSubtitles:self.subtitles];
    controller.delegate = self;
    controller.selectedSubtitle = self.selectedSubtitle ? self.selectedSubtitle : self.subtitles[0];
    [self.window.rootViewController.presentedViewController presentViewController:controller
                                                                         animated:YES
                                                                       completion:nil];
}

- (void)subtitleSelected:(NSString *)subtitle{
    self.selectedSubtitle = subtitle;
    [self.delegate subtitleSelected:subtitle];
    if (self.lastPlaybackRate > 0) {
        [self.delegate play];x
    }
}

@synthesize delegate;

@end
