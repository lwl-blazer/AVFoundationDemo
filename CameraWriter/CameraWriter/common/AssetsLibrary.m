//
//  AssetsLibrary.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "AssetsLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

static NSString *const ThumbnailCreatedNotification = @"ThumbnailCreated";

@interface AssetsLibrary ()


@end


@implementation AssetsLibrary

- (void)writeImage:(UIImage *)image completionHandler:(AssetsLibraryWriteCompletionHandler)completionHandler{
    
}

- (void)writeVideoAtURL:(NSURL *)videoURL completionHandler:(AssetsLibraryWriteCompletionHandler)completionHandler{
    
}

@end
