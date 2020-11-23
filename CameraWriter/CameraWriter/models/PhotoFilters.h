//
//  PhotoFilters.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CIFilter;
@interface PhotoFilters : NSObject

+ (NSArray *)filterNames;
+ (NSArray *)filterDisplayNames;
+ (CIFilter *)filterForDisplayName:(NSString *)displayName;
+ (CIFilter *)defaultFilter;

@end

NS_ASSUME_NONNULL_END
