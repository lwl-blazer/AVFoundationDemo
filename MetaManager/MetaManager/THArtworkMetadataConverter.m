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

#import "THArtworkMetadataConverter.h"

// 转换Artwork(封面和海报等图片)
// 媒体Artwork元数据会以多种不同的格式返回，比如唱片的封面和电影的海报等。不过最终Artwork数据的字节都保存在一个NSData实例中，但是定位NSData实例有时候需要完成一些额外的工作

@implementation THArtworkMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.11
    NSImage *image = nil;
    if ([item.value isKindOfClass:[NSData class]]) {
        image = [[NSImage alloc] initWithData:(NSData *)item.value];
    } else if ([item.value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)item.value;
        image = [[NSImage alloc] initWithData:dict[@"data"]];
    }
    return image;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.11
    AVMutableMetadataItem *metadataItem = [item mutableCopy];
    NSImage *image = (NSImage *)value;
    metadataItem.value = image.TIFFRepresentation;
    return metadataItem;
}

@end
