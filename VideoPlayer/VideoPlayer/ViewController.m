//
//  ViewController.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/28.
//

#import "ViewController.h"
#import "UIAlertController+BLAdditions.h"

#import "PlayerViewController.h"
#import "HCYoutubeParser.h"

#define LOCAL_SEGUE @"localSegue"
#define STREAMING_SEGUE @"streamingSegue"

#define YOUTUBE_URL @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"

@interface ViewController ()

@property(nonatomic, strong) NSURL *localURL;
@property(nonatomic, strong) NSURL *streamingURL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.localURL = [[NSBundle mainBundle] URLForResource:@"hubblecast" withExtension:@"m4v"];
    self.streamingURL = [NSURL URLWithString:YOUTUBE_URL];
//    [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:YOUTUBE_URL] completeBlock:^(NSDictionary *videoDictionary, NSError *error) {
//        self.streamingURL = [NSURL URLWithString:videoDictionary[@"hd720"]];
//    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:LOCAL_SEGUE] && !self.localURL) {
        return [self alertError];
    } else if ([identifier isEqualToString:STREAMING_SEGUE] && !self.streamingURL) {
        return [self alertError];
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSURL *url = [segue.identifier isEqualToString:LOCAL_SEGUE] ? self.localURL : self.streamingURL;
    PlayerViewController *player = [segue destinationViewController];
    player.assetURL = url;
}

- (BOOL)alertError{
    UIAlertController *alert = [UIAlertController showAlertWithTitle:@"Asset Unavailable"
                                                             message:@"The requested asset could not be loaded."];
    [self presentViewController:alert animated:YES completion:NULL];
    return NO;
}

@end
