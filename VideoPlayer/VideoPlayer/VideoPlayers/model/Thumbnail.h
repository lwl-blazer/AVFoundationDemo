//
//  Thumbnail.h
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface Thumbnail : NSObject

+ (instancetype)thumbnailWithImage:(UIImage *)image time:(CMTime)time;

@property(nonatomic, assign, readonly) CMTime time;
@property(nonatomic, strong, readonly) UIImage *image;

@end

NS_ASSUME_NONNULL_END
