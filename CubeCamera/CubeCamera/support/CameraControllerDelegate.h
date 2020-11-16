//
//  CameraControllerDelegate.h
//  CubeCamera
//
//  Created by luowailin on 2020/11/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraControllerDelegate <NSObject>

- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
