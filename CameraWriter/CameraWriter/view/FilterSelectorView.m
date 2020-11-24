//
//  FilterSelectorView.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "FilterSelectorView.h"
#import "PhotoFilters.h"
#import "BLNotifications.h"

@interface FilterSelectorView ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property(nonatomic, strong) NSMutableArray *labels;
@property(nonatomic, weak) UILabel *activeLabel;

@end

@implementation FilterSelectorView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupLabels];
    [self setupActions];
}

- (void)setupLabels{
    NSArray *filterNames = [PhotoFilters filterDisplayNames];
    CGRect frame = self.scrollView.bounds;
    self.labels = [NSMutableArray array];
    for (NSString *text in filterNames) {
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0f];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = text;
        [self.scrollView addSubview:label];
        frame.origin.x += frame.size.width;
        [self.labels addObject:label];
    }
    
    self.activeLabel = [self.labels firstObject];
    
    CGFloat width = frame.size.width * filterNames.count;
    self.scrollView.contentSize = CGSizeMake(width, frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
}

- (void)setupActions{
    self.leftButton.enabled = NO;
    [self.leftButton addTarget:self action:@selector(pageLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(pageRight:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)pageLeft:(id)sender {
    NSUInteger labelIndex = [self.labels indexOfObject:self.activeLabel];
    if (labelIndex > 0) {
        UILabel *label = [self.labels objectAtIndex:labelIndex - 1];
        [self.scrollView scrollRectToVisible:label.frame animated:YES];
        self.activeLabel = label;
        self.rightButton.enabled = YES;
        [self postNotificationForChange:label.text];
    }
    self.leftButton.enabled = labelIndex - 1 > 0;
}

- (void)pageRight:(id)sender {
    NSUInteger labelIndex = [self.labels indexOfObject:self.activeLabel];
    if (labelIndex < self.labels.count - 1) {
        UILabel *label = [self.labels objectAtIndex:labelIndex + 1];
        [self.scrollView scrollRectToVisible:label.frame animated:YES];
        self.activeLabel = label;
        self.leftButton.enabled = YES;
        [self postNotificationForChange:label.text];
    }
    self.rightButton.enabled = labelIndex < self.labels.count - 1;
}

- (void)postNotificationForChange:(NSString *)displayName {
    CIFilter *filter = [PhotoFilters filterForDisplayName:displayName];
    [[NSNotificationCenter defaultCenter] postNotificationName:BLFilterSelectionChangedNotification object:filter];
}

@end
