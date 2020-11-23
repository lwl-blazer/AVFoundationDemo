//
//  BLError.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const CameraErrorDomain;


typedef NS_ENUM(NSInteger, CameraErrorCode) {
    CameraErrorFailedToAddInput = 1000,
    CameraErrorFailedToAddOutput,
    CameraErrorHighFrameRateCaptureNotSupported
};


