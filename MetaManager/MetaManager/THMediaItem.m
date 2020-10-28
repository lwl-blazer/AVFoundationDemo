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
//

#import "THMediaItem.h"

#import "AVMetadataItem+THAdditions.h"
#import "NSFileManager+DirectoryLocations.h"

#define COMMON_META_KEY     @"commonMetadata"
#define AVAILABLE_META_KEY  @"availableMetadataFormats"

@interface THMediaItem ()
@property (strong) NSURL *url;
@property (strong) AVAsset *asset;
@property (strong) THMetadata *metadata;
@property (strong) NSArray *acceptedFormats;
@property BOOL prepared;
@end

@implementation THMediaItem

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        // Listing 3.3
        _url = url;
        _asset = [AVAsset assetWithURL:url];
        _filename = [url lastPathComponent];
        _filetype = [self fileTypeForURL:url];
        
        _editable = [_filetype isEqualToString:AVFileTypeMPEGLayer3];
        
        _acceptedFormats = @[AVMetadataFormatQuickTimeMetadata,
                             AVMetadataFormatiTunesMetadata,
                             AVMetadataFormatID3Metadata];
    }
    return self;
}

- (NSString *)fileTypeForURL:(NSURL *)url {

    // Listing 3.3
    NSString *ext = [[self.url lastPathComponent] pathExtension];
    NSString *type = nil;
    if ([ext isEqualToString:@"m4a"]) {
        type = AVFileTypeAppleM4A;
    } else if ([ext isEqualToString:@"m4v"]) {
        type = AVFileTypeAppleM4V;
    } else if ([ext isEqualToString:@"mov"]) {
        type = AVFileTypeQuickTimeMovie;
    } else if ([ext isEqualToString:@"mp4"]) {
        type = AVFileTypeMPEG4;
    } else {
        type = AVFileTypeMPEGLayer3;
    }
    return type;
}

- (void)prepareWithCompletionHandler:(THCompletionHandler)completionHandler {
    
    // Listing 3.4
    if (self.prepared) {
        completionHandler(self.prepared);
        return;
    }
    
    //THMetadata 保存AVMetadataItem
    self.metadata = [[THMetadata alloc] init];
    NSArray *keys = @[COMMON_META_KEY, AVAILABLE_META_KEY]; //资源的属性名
    //异步加载
    [self.asset loadValuesAsynchronouslyForKeys:keys
                              completionHandler:^{ //completionHandler 可能会在任意一个队列中被调用 如果对UI操作必须回到主队列
        
        //查询一个给定属性的状态  AVKeyValueStatus--表示当前所请求的属性的状态
        AVKeyValueStatus commonStatus = [self.asset statusOfValueForKey:COMMON_META_KEY
                                                                  error:nil];
        AVKeyValueStatus formatsStatus = [self.asset statusOfValueForKey:AVAILABLE_META_KEY
                                                                   error:nil];
        
        //如果状态不是AVKeyValueStatusLoaded 意味着此时请求属性可能导致程序卡顿
        self.prepared = (commonStatus == AVKeyValueStatusLoaded) && (formatsStatus == AVKeyValueStatusLoaded);
       
        if (self.prepared) { // 一定要成功载入用于后续的进程
            
            for (AVMetadataItem *item in self.asset.commonMetadata) {
                [self.metadata addMetadataItem:item withKey:item.commonKey];
            }
            //availableMetadataFormats，其中包含用于确定媒体元素中可用格式的字符串数组。
            for (id format in self.asset.availableMetadataFormats) {
                if ([self.acceptedFormats containsObject:format]) {
                    NSArray *items = [self.asset metadataForFormat:format];
                    for (AVMetadataItem *item in items) {
                        [self.metadata addMetadataItem:item withKey:item.keyString];
                    }
                }
            }
        }
        completionHandler(self.prepared);
    }];
}

// 保存元数据
- (void)saveWithCompletionHandler:(THCompletionHandler)handler {
    //AVAssetExportSession 用于将AVAsset内容根据导出预设条件进行转码，并将导出资源写入到磁盘中。 功能有：一种格式转换另一种格式，修订资源内容，修改资源的音频和视频行为，写入新的元数据
    
    // Listing 3.17
    NSString *presetName = AVAssetExportPresetPassthrough; //预设值
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:self.asset
                                                                     presetName:presetName];
    
    NSURL *outputURL = [self tempURL];
    session.outputURL = outputURL;
    session.outputFileType = self.filetype;
    session.metadata = [self.metadata metadataItems];
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = session.status;
        BOOL success = (status == AVAssetExportSessionStatusCompleted);
        if (success) { //导出成功
            NSURL *sourceURL = self.url;
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtURL:sourceURL error:nil]; //删除旧资源
            [manager moveItemAtURL:outputURL toURL:sourceURL error:nil]; //改用新导出的版本
            [self reset];
        }
        
        if (handler) {
            handler(success);
        }
    }];
}

- (NSURL *)tempURL {
    NSString *tempDir = NSTemporaryDirectory();
    NSString *ext = [[self.url lastPathComponent] pathExtension];
    NSString *tempName = [NSString stringWithFormat:@"temp.%@", ext];
    NSString *tempPath = [tempDir stringByAppendingPathComponent:tempName];
    return [NSURL fileURLWithPath:tempPath];
}

- (void)reset{
    _prepared = NO;
    _asset = [AVAsset assetWithURL:self.url];
}

@end
