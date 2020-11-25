//
//  AssetsLibrary.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AssetsLibraryWriteCompletionHandler)(BOOL success, NSError *error);

@interface BLAssetsLibrary : NSObject

- (void)writeImage:(UIImage *)image completionHandler:(AssetsLibraryWriteCompletionHandler)completionHandler;
- (void)writeVideoAtURL:(NSURL *)videoURL completionHandler:(AssetsLibraryWriteCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
