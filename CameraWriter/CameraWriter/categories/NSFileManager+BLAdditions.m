//
//  NSFileManager+BLAdditions.m
//  Camera
//
//  Created by luowailin on 2020/11/3.
//

#import "NSFileManager+BLAdditions.h"

@implementation NSFileManager (BLAdditions)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString{
    NSString *mkdTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:templateString];
    
    const char *templateCString = [mkdTemplate fileSystemRepresentation];
    
    char *buffer = (char *)malloc(strlen(templateCString) + 1);
    strcpy(buffer, templateCString);
    
    NSString *directoryPath = nil;
    
    char *result = mkdtemp(buffer);
    if (result) {
        directoryPath = [self stringWithFileSystemRepresentation:buffer
                                                          length:strlen(result)];
    }
    
    free(buffer);
    
    return directoryPath;
}

@end
