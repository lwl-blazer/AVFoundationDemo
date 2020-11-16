//
//  CameraController.h
//  CubeCamera
//
//  Created by luowailin on 2020/11/16.
//

#import "BaseCameraController.h"
#import <AVFoundation/AVFoundation.h>

@protocol TextureDelegate <NSObject>

- (void)textureCreatedWithTarget:(GLenum)target name:(GLuint)name;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CameraController : BaseCameraController

@property(nonatomic, weak) id<TextureDelegate>textureDelegate;
- (instancetype)initWithContext:(EAGLContext *)context;


@end

NS_ASSUME_NONNULL_END
