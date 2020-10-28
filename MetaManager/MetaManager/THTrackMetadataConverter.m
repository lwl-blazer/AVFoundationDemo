//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THTrackMetadataConverter.h"
#import "THMetadataKeys.h"

// 转换音轨数据
// 音轨通常包含一首歌在整个唱片中的编号位置信息(比如:"12首歌曲中的第4首"这样的信息) MP3文件以一种简单易懂的方式保存 但M4A就要一些处理生成用于展示的内容

@implementation THTrackMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.13
    NSNumber *number = nil;
    NSNumber *count = nil;
    
    if ([item.value isKindOfClass:[NSString class]]) {
        //MP3音轨信息以@"xx/xx"字符串格式返回
        NSArray *components = [item.stringValue componentsSeparatedByString:@"/"];
        number = @([components[0] integerValue]);
        count = @([components[1] integerValue]);
    } else if ([item.value isKindOfClass:[NSData class]]) {
        //M4A文件 是一个NSData  是4个16位big endian数字数组的十六进制表现形式， 数组中的第2个和第3个元素分别包含音轨编号和音轨计数值
        NSData *data = item.dataValue;
        if (data.length == 8) {
            uint16_t *values = (uint16_t *)[data bytes];
            if (values[1] > 0) {
                number = @(CFSwapInt16BigToHost(values[1]));   //big endian 变换成little endian格式 再打包成NSNumber
            }
            
            if (values[2] > 0) {
                count = @(CFSwapInt16BigToHost(values[2]));
            }
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:number ?: [NSNull null] forKey:THMetadataKeyTrackNumber];
    [dict setObject:count ?: [NSNull null] forKey:THMetadataKeyTrackCount];
    return dict;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.13
    AVMutableMetadataItem *metadataItem = [item mutableCopy];
    
    NSDictionary *trackData = (NSDictionary *)value;
    NSNumber *trackNumber = trackData[THMetadataKeyTrackNumber];
    NSNumber *trackCount = trackData[THMetadataKeyTrackCount];
    
    uint16_t values[4] = {0};
    if (trackNumber && ![trackNumber isKindOfClass:[NSNull class]]) {
        values[1] = CFSwapInt16HostToBig([trackNumber unsignedIntValue]); //将little endian 转换成 big endian
    }
    
    if (trackCount && ![trackCount isKindOfClass:[NSNull class]]) {
        values[2] = CFSwapInt16HostToBig([trackCount unsignedIntValue]);
    }
    
    size_t length = sizeof(values);
    metadataItem.value = [NSData dataWithBytes:values length:length];
        
    return metadataItem;
}

@end
