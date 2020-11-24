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

// 作为Core Image 的CIImage对象的可视化输出
- (void)setImage:(CIImage *)image;

@end

NS_ASSUME_NONNULL_END
