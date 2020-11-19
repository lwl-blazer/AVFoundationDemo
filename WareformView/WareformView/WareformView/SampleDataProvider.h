//
//  SampleDataProvider.h
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SampleDataCompletionBlock) (NSData *);

@interface SampleDataProvider : NSObject

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                  completionBlock:(SampleDataCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
