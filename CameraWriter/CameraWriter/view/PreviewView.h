//
//  PreviewView.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <GLKit/GLKit.h>
#import "ImageTarget.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreviewView : GLKView <ImageTarget>

@property(strong, nonatomic) CIFilter *filter;
@property(strong, nonatomic) CIContext *coreImageContext;

@end

NS_ASSUME_NONNULL_END
