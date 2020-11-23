//
//  NSString+BLAdditions.h
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (BLAdditions)

- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture;
- (BOOL)containsString:(NSString *)substring;

@end

NS_ASSUME_NONNULL_END
