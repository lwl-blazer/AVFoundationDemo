//
//  NSFileManager+BLAdditions.m
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import "NSFileManager+BLAdditions.h"

@implementation NSFileManager (BLAdditions)

// Unicode
- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString{
    NSString *mkdTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:templateString];
    
    //把路径传递给UNIX API时需要非常小心，在有些情况里一定不能使用UTF8String,正确的做法使用 fileSystemRepresentation
    const char *templateCString = [mkdTemplate fileSystemRepresentation];
    
    char *buffer = (char *)malloc(strlen(templateCString) + 1);
    strcpy(buffer, templateCString);
    
    NSString *directoryPath = nil;
    
    //创建临时文件和目录，可以跨平台使用，使用完毕需手动清理
    char *result = mkdtemp(buffer);
    if (result) {
        directoryPath = [self stringWithFileSystemRepresentation:buffer
                                                          length:strlen(result)];
    }
    
    free(buffer);
    return directoryPath;
}

@end
