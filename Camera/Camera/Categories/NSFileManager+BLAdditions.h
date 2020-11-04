//
//  NSFileManager+BLAdditions.h
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (BLAdditions)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString;

@end

NS_ASSUME_NONNULL_END
