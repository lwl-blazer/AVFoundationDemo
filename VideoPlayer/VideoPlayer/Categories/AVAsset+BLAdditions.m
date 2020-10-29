//
//  AVAsset+Additions.m
//  VideoPlayer
//
//  Created by luowailin on 2020/10/28.
//

#import "AVAsset+BLAdditions.h"

@implementation AVAsset (BLAdditions)

- (NSString *)title{
    AVKeyValueStatus status = [self statusOfValueForKey:@"commonMetadata" error:nil];
    if (status == AVKeyValueStatusLoaded) {
        NSArray *items = [AVMetadataItem metadataItemsFromArray:self.commonMetadata
                                                        withKey:AVMetadataCommonKeyTitle
                                                       keySpace:AVMetadataKeySpaceCommon];
        if (items.count > 0) {
            AVMetadataItem *titleItem = [items firstObject];
            return (NSString *)titleItem.value;
        }
    }
    return nil;
}

@end
