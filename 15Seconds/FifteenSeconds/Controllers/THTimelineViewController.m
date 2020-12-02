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

#import "THTimelineViewController.h"
#import "THVideoItemCollectionViewCell.h"
#import "UIView+THAdditions.h"
#import "THNotifications.h"
#import "THTransitionCollectionViewCell.h"
#import "THTransitionViewController.h"
#import "THTimelineItemViewModel.h"
#import "THTimelineBuilder.h"
#import "THAudioItemCollectionViewCell.h"
#import "THTimelineDataSource.h"
#import "THModels.h"
#import "THBackgroundView.h"
#import "THAppSettings.h"
#import "THFunctions.h"
#import "THPlayheadView.h"

@interface THTimelineViewController ()
@property (strong, nonatomic) NSArray *cellIDs;
@property (strong, nonatomic) THTimelineDataSource *dataSource;
@property (strong, nonatomic) UIPopoverController *transitionPopoverController;
@property (strong, nonatomic) THPlayheadView *playheadView;
@end

@implementation THTimelineViewController


- (void)viewDidLoad {
	[super viewDidLoad];

	self.transitionsEnabled = [THAppSettings sharedSettings].transitionsEnabled;
	self.volumeFadesEnabled = [THAppSettings sharedSettings].volumeFadesEnabled;
	self.duckingEnabled = [THAppSettings sharedSettings].volumeDuckingEnabled;
	self.titlesEnabled = [THAppSettings sharedSettings].titlesEnabled;

	// Register for notifications sent from the "Settings" menu
	[self registerForNotifications];

	// Set up UICollectionView data source and delegate
	self.dataSource = [THTimelineDataSource dataSourceWithController:self];
	[self.collectionView setDelegate:self.dataSource];
	[self.collectionView setDataSource:self.dataSource];

	// Set dark stone background view on UICollectionView instance.
	UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

	UIImage *patternImage = [UIImage imageNamed:@"app_black_background"];

	// Fix for my broken tiled images.  Fix this correctly in Photoshop.
	CGRect insetRect = CGRectMake(2.0f, 2.0f, patternImage.size.width - 2.0f, patternImage.size.width - 2.0f);
	CGImageRef image = CGImageCreateWithImageInRect(patternImage.CGImage, insetRect);
	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithCGImage:image]];
	CGImageRelease(image);

	self.collectionView.backgroundView = backgroundView;

    self.playheadView = [[THPlayheadView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playheadView];
}

- (void)synchronizePlayheadWithPlayerItem:(AVPlayerItem *)playerItem {
    [self.playheadView synchronizeWithPlayerItem:playerItem];
}

#pragma mark - Register Notification Handlers

- (void)registerForNotifications {

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter addObserver:self
						   selector:@selector(toggleTransitionsEnabledState:)
							   name:THTransitionsEnabledStateChangeNotification
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(toggleVolumeFadesEnabledState:)
							   name:THVolumeFadesEnabledStateChangeNotification
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(toggleVolumeDuckingEnabledState:)
							   name:THVolumeDuckingEnabledStateChangeNotification
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(toggleShowTitlesEnabledState:)
							   name:THShowTitlesEnabledStateChangeNotification
							 object:nil];
}

#pragma mark - Notification Handlers

- (void)setTransitionsEnabled:(BOOL)enabled {
	_transitionsEnabled = enabled;
	NSMutableArray *items = [NSMutableArray array];
	for (id item in self.dataSource.timelineItems[THVideoTrack]) {
		if ([item isKindOfClass:[THTimelineItemViewModel class]]) {
			THTimelineItemViewModel *model = (THTimelineItemViewModel *)item;
			if ([model.timelineItem isKindOfClass:[THMediaItem class]]) {
				[items addObject:model];
				if (enabled && (items.count % 2 != 0)) {
					[items addObject:[THVideoTransition disolveTransitionWithDuration:CMTimeMake(1, 2)]];
				}
			}
		}
	}
	if ([[items lastObject] isKindOfClass:[THVideoTransition class]]) {
		[items removeLastObject];
	}
	self.dataSource.timelineItems[THVideoTrack] = items;
}

- (void)toggleTransitionsEnabledState:(NSNotification *)notification {
	BOOL state = [[notification object] boolValue];
	if (self.transitionsEnabled != state) {
		self.transitionsEnabled = state;
		THTimelineLayout *layout = (THTimelineLayout *)self.collectionView.collectionViewLayout;
		layout.reorderingAllowed = !state;
		[self.collectionView reloadData];
	}
}

- (void)toggleVolumeFadesEnabledState:(NSNotification *)notification {
	self.volumeFadesEnabled = [[notification object] boolValue];
	NSArray *items = self.dataSource.timelineItems[THMusicTrack];
	if (items.count > 0) {
		THTimelineItemViewModel *model = [items lastObject];
		THAudioItem *item = (THAudioItem *)model.timelineItem;
		item.volumeAutomation = self.volumeFadesEnabled ? [self buildVolumeFadesForMusicItem:item] : nil;
	}
	[self.collectionView reloadData];
}

- (void)toggleVolumeDuckingEnabledState:(NSNotification *)notification {
	self.duckingEnabled = [[notification object] boolValue];
	[self.collectionView reloadData];
}

- (void)toggleShowTitlesEnabledState:(NSNotification *)notification {
	self.titlesEnabled = [[notification object] boolValue];
	[self.collectionView reloadData];
}

#pragma mark - Build Model States

- (NSArray *)buildVolumeFadesForMusicItem:(THAudioItem *)item {
	CMTime fadeTime = CMTimeMake(3, 1);
	NSMutableArray *automation = [NSMutableArray array];
	CMTimeRange startRange = CMTimeRangeMake(kCMTimeZero, fadeTime);
	[automation addObject:[THVolumeAutomation volumeAutomationWithTimeRange:startRange
																startVolume:0.0f endVolume:1.0f]];

	NSArray *voiceOvers = self.dataSource.timelineItems[THCommentaryTrack];
	for (THTimelineItemViewModel *model in voiceOvers) {
		THTimelineItem *mediaItem = model.timelineItem;
		CMTimeRange timeRange = mediaItem.timeRange;
		CMTime halfSecond = CMTimeMake(1, 2);
		CMTime startTime = CMTimeSubtract(mediaItem.startTimeInTimeline, halfSecond);
		CMTime endRangeStartTime = CMTimeAdd(mediaItem.startTimeInTimeline, timeRange.duration);
		CMTimeRange endRange = CMTimeRangeMake(endRangeStartTime, halfSecond);

		[automation addObject:[THVolumeAutomation volumeAutomationWithTimeRange:CMTimeRangeMake(startTime, halfSecond)
																	startVolume:1.0f endVolume:0.2f]];
		[automation addObject:[THVolumeAutomation volumeAutomationWithTimeRange:endRange
																	startVolume:0.2f endVolume:1.0f]];


	}

	// Add fade out over 2 seconds at the end of the music track
	// The start time will potentially be adjusted if the music track is trimmed
	// to the video track duration when the composition is built.
	CMTime endRangeStartTime = CMTimeSubtract(item.timeRange.duration, fadeTime);
	CMTimeRange endRange = CMTimeRangeMake(endRangeStartTime, fadeTime);
	[automation addObject:[THVolumeAutomation volumeAutomationWithTimeRange:endRange
																startVolume:1.0f endVolume:0.0f]];
	return automation;
}

#pragma mark - Add Timeline Items

- (void)clearTimeline {
    THWeakSelf weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSArray *items = weakSelf.dataSource.timelineItems;
        for (NSUInteger i = 0; i < items.count; i++) {
            for (NSUInteger j = 0; j < [items[i] count]; j++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:j inSection:i]];
            }
        }
        [weakSelf.collectionView deleteItemsAtIndexPaths:indexPaths];
        [weakSelf.dataSource resetTimeline];

    } completion:^(BOOL complete) {
        [weakSelf.collectionView reloadData];
    }];

}

- (void)addTimelineItem:(THTimelineItem *)timelineItem toTrack:(THTrack)track {

	NSMutableArray *items = self.dataSource.timelineItems[track];

    // Enforce 15 second-ness
    if (track == THVideoTrack) {
        if (items.count == 3) {
            return;
        }
        timelineItem.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(5, 1));
    } else if (track == THMusicTrack) {
        if (items.count == 1) {
            return;
        }
        timelineItem.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(15, 1));
    } else if (track == THCommentaryTrack) {
        if (items.count == 1) {
            return;
        }
    }

    THTimelineItemViewModel *model = [THTimelineItemViewModel modelWithTimelineItem:timelineItem];

	NSMutableArray *indexPaths = [NSMutableArray array];


	// insert transition between items
	if (track == THVideoTrack && self.transitionsEnabled && items.count > 0) {
		THVideoTransition *transition = [THVideoTransition disolveTransitionWithDuration:CMTimeMake(1, 2)];
		[items addObject:transition];
		NSIndexPath *path = [NSIndexPath indexPathForItem:(items.count - 1) inSection:track];
		[indexPaths addObject:path];
	}

	if (track == THMusicTrack && self.volumeFadesEnabled) {
		THAudioItem *audioItem = (THAudioItem *)timelineItem;
		audioItem.volumeAutomation = [self buildVolumeFadesForMusicItem:audioItem];
	}

	[items addObject:model];
	NSIndexPath *path = [NSIndexPath indexPathForItem:(items.count - 1) inSection:track];
	[indexPaths addObject:path];

    [self.collectionView insertItemsAtIndexPaths:indexPaths];
}

#pragma mark - Get current THTimeline snapshot

- (THTimeline *)currentTimeline {

	NSArray *timelineItems = self.dataSource.timelineItems;
	return [THTimelineBuilder buildTimelineWithMediaItems:timelineItems];
}

@end