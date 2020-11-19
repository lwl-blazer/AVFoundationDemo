//
//  SampleDataFilter.m
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//
#import <UIKit/UIKit.h>
#import "SampleDataFilter.h"

@interface SampleDataFilter ()

@property(nonatomic, strong) NSData *sampleData;

@end


@implementation SampleDataFilter

- (instancetype)initWithData:(NSData *)sampleData {
    self = [super init];
    if (self) {
        _sampleData = sampleData;
    }
    return self;
}

- (NSArray *)filteredSamplesForSize:(CGSize)size {
    return nil;
}

- (SInt16)maxValueInArray:(SInt16[])values ofSize:(NSUInteger)size {
    return 0;
}

@end
