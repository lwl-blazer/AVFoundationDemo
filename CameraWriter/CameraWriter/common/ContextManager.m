//
//  ContextManager.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "ContextManager.h"
#import <CoreImage/CoreImage.h>

@implementation ContextManager

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static ContextManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ContextManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSDictionary *options = @{kCIContextWorkingColorSpace:[NSNull null]};
        _ciContext = [CIContext contextWithEAGLContext:_eaglContext
                                               options:options];
    }
    return self;
}


@end
