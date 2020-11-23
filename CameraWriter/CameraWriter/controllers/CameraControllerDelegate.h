//
//  CameraControllerDelegate.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraControllerDelegate <NSObject>

- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
