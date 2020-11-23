//
//  ContextManager.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

NS_ASSUME_NONNULL_BEGIN
@class CIContext;
@interface ContextManager : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, strong, readonly) EAGLContext *eaglContext;
@property(nonatomic, strong, readonly) CIContext *ciContext;

@end

NS_ASSUME_NONNULL_END
