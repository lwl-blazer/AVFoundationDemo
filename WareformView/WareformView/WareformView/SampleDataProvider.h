//
//  SampleDataProvider.h
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//

/**
 * 第一步 获取 
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SampleDataCompletionBlock) (NSData *);

@interface SampleDataProvider : NSObject

// AVAssetReader实例从AVAsset中读取音频样本并返回一个NSData对象
+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                  completionBlock:(SampleDataCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
