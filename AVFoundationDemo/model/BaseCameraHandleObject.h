//
//  BaseCameraHandleObject.h
//  AVFoundationDemo
//
//  Created by blazer on 2019/2/18.
//  Copyright © 2019 blazer. All rights reserved.
//

#import "CameraHandleObject.h"
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

//设置执行缩放效果是通过居中裁剪由摄像头传感器捕捉到的图片实现

@protocol BaseCameraHandleObjectDelegate <NSObject>

- (void)rampedZoomToValue:(CGFloat)value; //用于界面保持缩放滑动条控件与当前缩放状态的同步

@end

@protocol BLTextureDelegate <NSObject>

- (void)textureCreateWithTarget: (GLenum)target name:(GLuint)name;

@end


@interface BaseCameraHandleObject : CameraHandleObject

@property(nonatomic, weak) id<BaseCameraHandleObjectDelegate>zoomingDelegate;

- (BOOL)cameraSupportsZoom;

- (void)setZoomValue:(CGFloat)zoomValue;
- (void)rampZoomToValue:(CGFloat)zoomValue;
- (void)cancelZoom;


- (instancetype)initWithContext:(EAGLContext *)context;
@property(nonatomic, weak) id<BLTextureDelegate>textureDelegate;

@end

NS_ASSUME_NONNULL_END
