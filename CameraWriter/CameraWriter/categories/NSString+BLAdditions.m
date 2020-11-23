//
//  NSString+BLAdditions.m
//  CameraWriter
//
//  Created by luowailin on 2020/11/23.
//

#import "NSString+BLAdditions.h"

@implementation NSString (BLAdditions)

- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
    NSTextCheckingResult *result = [expression firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    if (capture < [result numberOfRanges]) {
        NSRange range = [result rangeAtIndex:capture];
        return [self substringWithRange:range];
    }
    return nil;
}

- (BOOL)containsString:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location != NSNotFound;
}

@end
