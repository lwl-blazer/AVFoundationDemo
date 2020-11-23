//
//  PhotoFilters.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "PhotoFilters.h"
#import "NSString+BLAdditions.h"
#import <CoreImage/CoreImage.h>

@implementation PhotoFilters

+ (NSArray *)filterNames{
    return @[@"CIPhotoEffectChrome",
             @"CIPhotoEffectFade",
             @"CIPhotoEffectInstant",
             @"CIPhotoEffectMono",
             @"CIPhotoEffectNoir",
             @"CIPhotoEffectProcess",
             @"CIPhotoEffectTonal",
             @"CIPhotoEffectTransfer"];
}

+ (NSArray *)filterDisplayNames{
    NSMutableArray *displayNames = [NSMutableArray array];
    for (NSString *filterName in [self filterNames]) {
        [displayNames addObject:[filterName stringByMatchingRegex:@"CIPhotoEffect(.*)" capture:1]];
    }
    return displayNames;
}

+ (CIFilter *)defaultFilter{
    return [CIFilter filterWithName:[[self filterNames] firstObject]];
}

+ (CIFilter *)filterForDisplayName:(NSString *)displayName{
    for (NSString *name in [self filterNames]) {
        if ([name containsString:displayName]) {
            return [CIFilter filterWithName:name];
        }
    }
    return nil;
}

@end
