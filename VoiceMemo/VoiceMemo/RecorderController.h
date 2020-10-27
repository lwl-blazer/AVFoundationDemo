//
//  RecorderController.h
//  VoiceMemo
//
//  Created by luowailin on 2020/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RecorderControllerDelegate <NSObject>

- (void)interruptionBegan;

@end

typedef void(^RecordingStopCompletionHandler)(BOOL);
typedef void(^RecordingSaveCompletionHandler)(BOOL, id);

@class Memo, LevelPair;
@interface RecorderController : UIView

@property(nonatomic, copy, readonly) NSString *formattedCurrentTime;
@property(nonatomic, weak) id<RecorderControllerDelegate>delegate;

- (BOOL)record;
- (void)pause;
- (void)stopWithCompletionHandler:(RecordingStopCompletionHandler)handler;
- (void)saveRecordingWithName:(NSString *)name
            completionHandler:(RecordingSaveCompletionHandler)handler;
- (LevelPair *)levels;
- (BOOL)playbackMemo:(Memo *)memo;

@end

NS_ASSUME_NONNULL_END
