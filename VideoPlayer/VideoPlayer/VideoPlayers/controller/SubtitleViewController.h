//
//  SubtitleViewController.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SubtitleViewControllerDelegate <NSObject>

- (void)subtitleSelected:(NSString *)subtitle;

@end

@interface SubtitleViewController : UIViewController

- (instancetype)initWithSubtitles:(NSArray *)subtitles;

@property(nonatomic, copy) NSString *selectedSubtitle;
@property(nonatomic, weak) id<SubtitleViewControllerDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
