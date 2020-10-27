//
//  RecorderController.m
//  VoiceMemo
//
//  Created by luowailin on 2020/10/26.
//

#import "RecorderController.h"
#import <AVFoundation/AVFoundation.h>
#import "Memo.h"
#import "LevelPair.h"
#import "MeterTable.h"

@interface RecorderController ()<AVAudioRecorderDelegate>

@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) RecordingStopCompletionHandler completionHandler;
@property(nonatomic, strong) MeterTable *meterTable;

@end

@implementation RecorderController

- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *filePath = [tmpDir stringByAppendingPathComponent:@"memo.caf"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        //Core Audio Format(CAF)通常是最好的容器格式,因为它和内容无关，并可以保存Core Audio支持的任何音频格式
        NSDictionary *setting = @{AVFormatIDKey: @(kAudioFormatAppleIMA4),
                                  AVSampleRateKey: @44100.0f,
                                  AVNumberOfChannelsKey: @1,
                                  AVEncoderBitDepthHintKey: @16,
                                  AVEncoderAudioQualityKey: @(AVAudioQualityMedium)};
        
        NSError *error;
        self.recorder = [[AVAudioRecorder alloc] initWithURL:fileURL
                                                    settings:setting
                                                       error:&error];
        if (self.recorder) {
            self.recorder.delegate = self;
            self.recorder.meteringEnabled = YES;
            [self.recorder prepareToRecord];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(interruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:[AVAudioSession sharedInstance]];
        
        self.meterTable = [[MeterTable alloc] init];
    }
    return self;
}

- (BOOL)record{
    return [self.recorder record];
}

- (void)pause{
    [self.recorder pause];
}

- (void)stopWithCompletionHandler:(RecordingStopCompletionHandler)handler{
    self.completionHandler = handler;
    [self.recorder stop]; //结束音频录制的过程
}

//录制完成
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (self.completionHandler) {
        self.completionHandler(flag);
    }
}

- (void)saveRecordingWithName:(NSString *)name
            completionHandler:(RecordingSaveCompletionHandler)handler{
    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *filename = [NSString stringWithFormat:@"%@-%f.m4a", name, timestamp];
    
    NSString *docsDir = [self documentsDirectory];
    NSString *destPath = [docsDir stringByAppendingPathComponent:filename];
    
    NSURL *srcURL = self.recorder.url;
    NSURL *destURL = [NSURL fileURLWithPath:destPath];
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:srcURL
                                                           toURL:destURL
                                                           error:&error];
    if (success) {
        NSLog(@"%@", destURL);
        handler(YES, [Memo memoWithTitle:name
                                     url:destURL]);
        [self.recorder prepareToRecord];
    } else {
        handler(NO, error);
    }
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

- (LevelPair *)levels{
    [self.recorder updateMeters]; //获取最新值
    
    // averagePowerForChannel peakPowerForChannel 返回一个用于表示声音分贝(dB)等级的浮点值  最大分贝0DB(full scale)和最小分贝或静音的-160DB
    float avgPower = [self.recorder averagePowerForChannel:0];
    float peakPower = [self.recorder peakPowerForChannel:0];
    
    NSLog(@"%lf--%lf", avgPower, peakPower);
    
    //平均值
    float linearLevel = [self.meterTable valueForPower:avgPower];
    //峰值数据
    float linearPeak = [self.meterTable valueForPower:peakPower];
    
    NSLog(@"linear: %lf--%lf", linearLevel, linearPeak);
    
    return [LevelPair levelsWithLevel:linearLevel
                            peakLevel:linearPeak];
}

- (BOOL)playbackMemo:(Memo *)memo{
    [self.player stop];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:memo.url
                                                         error:nil];
    if (self.player) {
        [self.player play];
        return YES;
    }
    return NO;
}

- (NSString *)formattedCurrentTime{
    // currentTime 不能使用KVO
    NSUInteger time = (NSUInteger)self.recorder.currentTime;
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;

    NSString *format = @"%02i:%02i:%02i";
    return [NSString stringWithFormat:format, hours, minutes, seconds];
}

- (void)interruption:(NSNotification *)sender{
    if (self.delegate) {
        [self.delegate interruptionBegan];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:[AVAudioSession sharedInstance]];
}
@end
