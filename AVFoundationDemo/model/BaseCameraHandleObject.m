
//
//  BaseCameraHandleObject.m
//  AVFoundationDemo
//
//  Created by blazer on 2019/2/18.
//  Copyright © 2019 blazer. All rights reserved.
//

#import "BaseCameraHandleObject.h"

const CGFloat THZoomRate = 1.0f;

static const NSString *THRampingVideoZoomContext;
static const NSString *THRampingVideoZoomFactorContext;

@implementation BaseCameraHandleObject

//videoZoomFactory的属性，用于控制捕捉设备的缩放等级。 最小值是1.0 不能缩放图片
- (BOOL)cameraSupportsZoom{
    return self.activeCamera.activeFormat.videoMaxZoomFactor > 1.0;
}

//最大值 videoMaxZoomFactor
- (CGFloat)maxZoomFactor{
    return MIN(self.activeCamera.activeFormat.videoMaxZoomFactor, 4.0);
}

- (void)setZoomValue:(CGFloat)zoomValue{
    if (!self.activeCamera.isRampingVideoZoom) {
        NSError *error;
        
        if ([self.activeCamera lockForConfiguration:&error]) {
            CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);   //增长为指数形式，所以要提供范围线性增长的感觉，需要通过计算最大的缩放因子的zoomvalue次幂(0到1)来计算zoomFactor值
            self.activeCamera.videoZoomFactor = zoomFactor;
            
            [self.activeCamera unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWidthError:error];
        }
    }
}


- (void)rampZoomToValue:(CGFloat)zoomValue{
    CGFloat zoomFactory = pow([self maxZoomFactor], zoomValue);
    NSError *error;
    if ([self.activeCamera lockForConfiguration:&error]) {
        [self.activeCamera rampToVideoZoomFactor:zoomFactory withRate:THZoomRate];  //
        [self.activeCamera unlockForConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWidthError:error];
    }
}

- (void)cancelZoom{
    NSError *error;
    if (![self.activeCamera lockForConfiguration:&error]) {
        [self.activeCamera cancelVideoZoomRamp];
        [self.activeCamera unlockForConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWidthError:error];
    }
}

- (BOOL)setupSession:(NSError *)error{
    BOOL success = [super setupSession:error];
    
    if (success) {
        [self.activeCamera addObserver:self
                            forKeyPath:@"videoZoomFactor"
                               options:0 context:&THRampingVideoZoomFactorContext];
        [self.activeCamera addObserver:self
                            forKeyPath:@"ramingVideoZoom"
                               options:0
                               context:&THRampingVideoZoomContext];
    }
    return success;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (context == &THRampingVideoZoomContext) {
        [self updateZoomingDelegate];
    } else if (context == &THRampingVideoZoomFactorContext) {
        if (self.activeCamera.isRampingVideoZoom) {
            [self updateZoomingDelegate];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateZoomingDelegate{
    CGFloat curZoomFactor = self.activeCamera.videoZoomFactor;
    CGFloat maxZoomFactor = [self maxZoomFactor];
    CGFloat value = log(curZoomFactor) / log(maxZoomFactor);
    [self.zoomingDelegate rampedZoomToValue:value];
}

@end
