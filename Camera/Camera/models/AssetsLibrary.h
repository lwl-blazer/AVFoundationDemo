//
//  AssetsLibrary.h
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AssetsLibrary : NSObject

- (void)writeImage:(UIImage *)image;
- (void)writeVideo:(NSURL *)videoURL;

@end

NS_ASSUME_NONNULL_END
