//
//  ViewController.m
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import "ViewController.h"
#import "PreviewView.h"
#import "OverlayView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet PreviewView *previewView;
@property (weak, nonatomic) IBOutlet OverlayView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)swapCarmers:(UIButton *)sender {
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
