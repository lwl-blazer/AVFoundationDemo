//
//  ImageTarget.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ImageTarget <NSObject>

- (void)setImage:(CIImage *)image;

@end

NS_ASSUME_NONNULL_END
