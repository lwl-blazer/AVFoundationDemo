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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet WaveformView *keysWaveformView;
@property (weak, nonatomic) IBOutlet WaveformView *beatWaveformView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
