//
//  ViewController.m
//  VoiceMemo
//
//  Created by luowailin on 2020/10/26.
//

#import "ViewController.h"
#import "RecorderController.h"
#import "Memo.h"
#import "MemoCell.h"
#import "LevelMeterView.h"
#import "LevelPair.h"

#define CANCEL_BUTTON 0
#define OK_BUTTON 1

#define MEMO_CELL @"memoCell"
#define MEMOS_ARCHIVE @"memos.archive"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, RecorderControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet LevelMeterView *levelMeterView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *memos;
@property (strong, nonatomic) CADisplayLink *levelTimer;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) RecorderController *controller;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.controller = [[RecorderController alloc] init];
    self.controller.delegate = self;
    self.memos = [NSMutableArray array];
    self.stopButton.enabled = NO;
    
    NSData *data = [NSData dataWithContentsOfURL:[self archiveURL]];
    if (data) {
        self.memos = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        self.memos = [NSMutableArray array];
    }
    
    [self.tableView reloadData];
}

- (IBAction)recordButtonAction:(UIButton *)sender {
    self.stopButton.enabled = YES;
    if ([sender isSelected]) {
        [self stopMeterTimer];
        [self stopTimer];
        [self.controller pause];
    } else {
        [self startTimer];
        [self startMeterTimer];
        [self.controller record];
    }
    [sender setSelected:![sender isSelected]];
}

- (IBAction)stopButtonAction:(UIButton *)sender {
    self.recordButton.selected = NO;
    sender.enabled = NO;
    [self.controller stopWithCompletionHandler:^(BOOL result) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [self showSaveDialog];
        });
    }];
}

- (void)showSaveDialog{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Save Recording"
                                          message:@"Please provide a name"
                                          preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"My Recording", @"Login");
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *filename = [alertController.textFields.firstObject text];
        [self.controller saveRecordingWithName:filename completionHandler:^(BOOL success, id object) {
            if (success) {
                [self.memos addObject:object];
                [self saveMemos];
                [self.tableView reloadData];
            } else {
                NSLog(@"Error saving file: %@", [object localizedDescription]);
            }
        }];
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(updateTimeDisplay)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer
                              forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateTimeDisplay{
    self.timeLabel.text = self.controller.formattedCurrentTime;
}

#pragma mark - Level Metering

- (void)startMeterTimer {
    [self.levelTimer invalidate];
    self.levelTimer = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(updateMeter)];
    self.levelTimer.preferredFramesPerSecond = 5;
    [self.levelTimer addToRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSRunLoopCommonModes];
}

- (void)stopMeterTimer{
    [self.levelTimer invalidate];
    self.levelTimer = nil;
    [self.levelMeterView resetLevelMeter];
}

- (void)updateMeter{
    LevelPair *levels = [self.controller levels];
    self.levelMeterView.level = levels.level;
    self.levelMeterView.peakLevel = levels.peakLevel;
    [self.levelMeterView setNeedsDisplay];
}

#pragma mark -- RecorderControllerDelegate
- (void)interruptionBegan{
    self.recordButton.selected = NO;
    [self stopMeterTimer];
    [self stopTimer];
}


#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MemoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memoCell" forIndexPath:indexPath];
    Memo *memo = self.memos[indexPath.row];
    cell.titleLabel.text = memo.title;
    cell.dateLabel.text = memo.dateString;
    cell.timeLabel.text = memo.timeString;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.memos.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Memo *memo = self.memos[indexPath.row];
        [memo deleteMemo];
        [self.memos removeObjectAtIndex:indexPath.row];
        [self saveMemos];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.controller playbackMemo:self.memos[indexPath.row]];
}

#pragma mark - Memo Archiving
- (void)saveMemos {
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:self.memos];
    [fileData writeToURL:[self archiveURL] atomically:YES];
}

- (NSURL *)archiveURL{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *docsDir = [paths objectAtIndex:0];
    NSString *archivePath = [docsDir stringByAppendingPathComponent:MEMOS_ARCHIVE];
    return [NSURL fileURLWithPath:archivePath];
}

@end
