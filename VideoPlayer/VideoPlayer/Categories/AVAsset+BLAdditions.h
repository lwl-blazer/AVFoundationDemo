//
//  AVAsset+Additions.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/28.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (BLAdditions)

@property(nonatomic, readonly) NSString *title;

@end

NS_ASSUME_NONNULL_END
