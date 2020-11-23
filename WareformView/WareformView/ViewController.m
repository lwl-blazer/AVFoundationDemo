//
//  ViewController.m
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//
/**
 * 创建音频波形视图分为三步:
 * 1.读取
 * 2.缩减
 * 3.渲染
 */
#import "ViewController.h"
#import "WaveformView.h"
#import "UIColor+Additions.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet WaveformView *keysWaveformView;
@property (weak, nonatomic) IBOutlet WaveformView *beatWaveformView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
//    NSURL *keysURL = [[NSBundle mainBundle] URLForResource:@"keys"
//                                              withExtension:@"mp3"];
    
    NSURL *keysURL = [[NSBundle mainBundle] URLForResource:@"possible"
                                              withExtension:@"aac"];
    
    NSURL *beatURL  = [[NSBundle mainBundle] URLForResource:@"beat"
                                              withExtension:@"aiff"];
    
    self.keysWaveformView.waveColor = [UIColor blueWaveColor];
    self.keysWaveformView.backgroundColor = [UIColor blueBackgroundColor];
    self.keysWaveformView.asset = [AVURLAsset assetWithURL:keysURL];

    self.beatWaveformView.waveColor = [UIColor greenWaveColor];
    self.beatWaveformView.backgroundColor = [UIColor greenBackgroundColor];
    self.beatWaveformView.asset = [AVURLAsset assetWithURL:beatURL];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
