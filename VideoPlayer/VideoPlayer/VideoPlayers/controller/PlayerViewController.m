//
//  PlayerViewController.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import "PlayerViewController.h"
#import "PlayerController.h"

@interface PlayerViewController ()

@property(nonatomic, strong) PlayerController *controller;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.controller = [[PlayerController alloc] initWithURL:self.assetURL];
    UIView *playerView = self.controller.view;
    playerView.frame = self.view.frame;
    [self.view addSubview:playerView];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
