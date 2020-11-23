//
//  BLFunctions.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "BLFunctions.h"

CGRect BLCenterCropImageRect(CGRect sourceRect, CGRect previewRect){
    CGFloat sourceAspectRatio = sourceRect.size.width / sourceRect.size.height;
    
    CGFloat previewAspectRatio = previewRect.size.width / previewRect.size.height;
    
    CGRect drawRect = sourceRect;
    
    if (sourceAspectRatio > previewAspectRatio) {
        CGFloat scaledHeight = drawRect.size.height * previewAspectRatio;
        drawRect.origin.x += (drawRect.size.width - scaledHeight) / 2.0;
        drawRect.size.width = scaledHeight;
    } else {
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspectRatio) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspectRatio;
    }
    
    return drawRect;
}

CGAffineTransform BLTransformForDeviceOrientation(UIDeviceOrientation orientation){
    CGAffineTransform result;
    switch (orientation) {
        case UIDeviceOrientationLandscapeRight:
            result = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            result = CGAffineTransformMakeRotation(M_PI_2 *3);
            
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            result = CGAffineTransformMakeRotation(M_PI_2);
        default:
            result = CGAffineTransformIdentity;
            break;
    }
    return result;
}
