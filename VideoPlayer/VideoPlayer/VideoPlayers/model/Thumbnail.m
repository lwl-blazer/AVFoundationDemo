//
//  Thumbnail.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/29.
//

#import "Thumbnail.h"

@implementation Thumbnail

+ (instancetype)thumbnailWithImage:(UIImage *)image time:(CMTime)time{
    return [[self alloc] initWithImage:image time:time];
}

- (instancetype)initWithImage:(UIImage *)image time:(CMTime)time
{
    self = [super init];
    if (self) {
        _image = image;
        _time = time;
    }
    return self;
}

@end

