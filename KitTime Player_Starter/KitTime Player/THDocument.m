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

#import "THDocument.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "THChapter.h"
#import "THExportWindowController.h"

#define STATUS_KEY @"status"

@interface THDocument ()<THExportWindowControllerDelegate>

@property (weak) IBOutlet AVPlayerView *playerView;

@property(nonatomic, strong) AVAsset *asset;
@property(nonatomic, strong) AVPlayerItem *playerItem;

@property(nonatomic, strong) NSArray *chapters;

@property(nonatomic, strong) AVAssetExportSession *exportSession;
@property(nonatomic, strong) THExportWindowController *exportController;

@end

@implementation THDocument

- (NSString *)windowNibName {
    return @"THDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller {
    [super windowControllerDidLoadNib:controller];
    [self setupPlaybackStackWithURL:[self fileURL]];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return YES;
}

- (void)setupPlaybackStackWithURL:(NSURL *)url{
    self.asset = [AVAsset assetWithURL:url];
    NSArray *keys = @[@"commonMetadata",
                      @"availableChapterLocales"];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    
    [self.playerItem addObserver:self
                      forKeyPath:STATUS_KEY
                         options:0
                         context:NULL];
    
    self.playerView.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView.showsSharingServiceButton = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:STATUS_KEY]) {
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            NSString *title = [self titleForAsset:self.asset];
            if (title) {
                self.windowForSheet.title = title;
            }
            self.chapters = [self chaptersForAsset:self.asset];
            
            if (self.chapters.count > 0) {
                [self setupActionMenu];
            }
        }
        [self.playerItem removeObserver:self forKeyPath:STATUS_KEY];
    }
}

- (NSString *)titleInMetadata:(NSArray *)metadata{
    NSArray *items = [AVMetadataItem metadataItemsFromArray:metadata
                                                    withKey:AVMetadataCommonKeyTitle
                                                   keySpace:AVMetadataKeySpaceCommon];
    
    return [[items firstObject] stringValue];
}

- (NSString *)titleForAsset:(AVAsset *)asset{
    NSString *title = [self titleInMetadata:asset.metadata];
    if (title && ![title isEqualToString:@""]) {
        return title;
    }
    return nil;
}

- (NSArray *)chaptersForAsset:(AVAsset *)asset{
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSArray *metadataGroups = [asset chapterMetadataGroupsBestMatchingPreferredLanguages:languages];
    NSMutableArray *chapters = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < metadataGroups.count; i++) {
        AVTimedMetadataGroup *group = metadataGroups[i];
        
        CMTime time = group.timeRange.start;
        
        NSUInteger number = i + 1;
        
        NSString *title = [self titleInMetadata:group.items];
        
        THChapter *chapter = [THChapter chapterWithTime:time
                                                 number:number
                                                  title:title];
        
        [chapters addObject:chapter];
    }
    return chapters;
}

- (void)setupActionMenu{
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Previous Chapter"
                                                action:@selector(previousChapter:)
                                      keyEquivalent:@""]];
    
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Next Chapter"
                                                action:@selector(nextChapter:)
                                      keyEquivalent:@""]];
    
    self.playerView.actionPopUpButtonMenu = menu;
}

- (void)previousChapter:(id)sender{
    [self skipToChapter:[self findPreviousChapter]];
}

- (void)nextChapter:(id)sender{
    [self skipToChapter:[self findNextChapter]];
}

- (void)skipToChapter:(THChapter *)chapter {
    [self.playerItem seekToTime:chapter.time completionHandler:^(BOOL finished) {
        [self.playerView flashChapterNumber:chapter.number
                               chapterTitle:chapter.title];
    }];
}

- (THChapter *)findPreviousChapter{
    CMTime playerTime = self.playerItem.currentTime;
    CMTime currentTime = CMTimeSubtract(playerTime, CMTimeMake(3, 1));
    CMTime pastTime = kCMTimeNegativeInfinity; // 负无穷大
    
    CMTimeRange timeRange = CMTimeRangeMake(pastTime, currentTime);
    
    return [self findChapterInTimeRange:timeRange
                                reverse:YES]; //YES 后向查找
}

- (THChapter *)findNextChapter{
    CMTime currentTime = self.playerItem.currentTime;
    CMTime futureTime = kCMTimePositiveInfinity; // 正无穷大
    
    CMTimeRange timeRange = CMTimeRangeMake(currentTime, futureTime);
    return [self findChapterInTimeRange:timeRange
                                reverse:NO];
}

- (THChapter *)findChapterInTimeRange:(CMTimeRange)timeRange
                              reverse:(BOOL)reverse {
    __block THChapter *matchingChapter = nil;
    
    NSEnumerationOptions options = reverse ? NSEnumerationReverse : 0;
    [self.chapters enumerateObjectsWithOptions:options
                                    usingBlock:^(THChapter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isInTimeRange:timeRange]) {
            matchingChapter = obj;
            *stop = YES;
        }
    }];
    return matchingChapter;
}

- (IBAction)startTriming:(id)sender{
    [self.playerView beginTrimmingWithCompletionHandler:NULL];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item{
    SEL action = [item action];
    if (action == @selector(startTriming:)) {
        return self.playerView.canBeginTrimming;
    }
    return YES;
}

- (IBAction)startExporting:(id)sender{
    [self.playerView.player pause];
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetModalForWindow:self.windowForSheet
                      completionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            [savePanel orderOut:nil];
            
            NSString *preset = AVAssetExportPresetAppleM4V720pHD;
            self.exportSession = [[AVAssetExportSession alloc] initWithAsset:self.asset
                                                                  presetName:preset];
            
            CMTime startTime = self.playerItem.reversePlaybackEndTime;
            CMTime endTime = self.playerItem.forwardPlaybackEndTime;
            CMTimeRange timeRange = CMTimeRangeMake(startTime, endTime);
            
            self.exportSession.timeRange = timeRange;
            self.exportSession.outputFileType = [self.exportSession.supportedFileTypes firstObject];
            self.exportSession.outputURL = savePanel.URL;
            
            self.exportController = [[THExportWindowController alloc] init];
            self.exportController.exportSession = self.exportSession;
            self.exportController.delegate = self;
            [self.windowForSheet beginSheet:self.exportController.window completionHandler:nil];
            
            [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
                [self.windowForSheet endSheet:self.exportController.window];
                self.exportController = nil;
                self.exportSession = nil;
            }];
        }
    }];
}

- (void)exportDidCancel{
    [self.exportSession cancelExport];
}

@end
