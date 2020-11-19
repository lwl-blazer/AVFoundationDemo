//
//  SampleDataFilter.h
//  WareformView
//
//  Created by luowailin on 2020/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SampleDataFilter : NSObject

- (instancetype)initWithData:(NSData *)sampleData;
- (NSArray *)filteredSamplesForSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
