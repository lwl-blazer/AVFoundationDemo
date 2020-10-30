//
//  SubtitleViewController.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/30.
//

#import "SubtitleViewController.h"

@interface SubtitleViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSArray *subtitles;

@end

@implementation SubtitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (instancetype)initWithSubtitles:(NSArray *)subtitles{
    self = [super init];
    if (self) {
        self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"subtitleController"];
        self.subtitles = subtitles;
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subtitles.count;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *subtitle = self.subtitles[indexPath.row];
    cell.textLabel.text = subtitle;
    if ([subtitle isEqualToString:self.selectedSubtitle]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (IBAction)close:(id)sender {
    [self.delegate subtitleSelected:self.selectedSubtitle];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedSubtitle = self.subtitles[indexPath.row];
    [self.tableView reloadData];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
