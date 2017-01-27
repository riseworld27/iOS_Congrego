//
//  AssetDownloadManager.m
//  IgViewer
//
//  Created by matata on 25/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "AssetDownloadManager.h"
#import "AssetDownload.h"

@implementation AssetDownloadManager

-(id)init
{
	self = [super init];
	if (self) {
		assetDownloadArray = [[NSMutableArray alloc] init];
		completedDownloads = [[NSMutableArray alloc] init];
		failedDownloads = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)queueDownload:(AssetDownload *)download
{
	if (download) {
		[assetDownloadArray addObject:download];
		[download setDelegate:self];
	}
}

-(void)startDownloadQueue
{
	if ([assetDownloadArray count] > 0) {
		currentAsset = (AssetDownload *)[assetDownloadArray objectAtIndex:0];
		[currentAsset download];
	} else {
		[self downloadQueueComplete];
	}
}

-(void)assetDownloadComplete
{
	[completedDownloads addObject:currentAsset];
	[assetDownloadArray removeObjectAtIndex:0];
	[self startDownloadQueue];
}

-(void)assetDownloadFailed
{
	[failedDownloads addObject:currentAsset];
	[assetDownloadArray removeObjectAtIndex:0];
	[self startDownloadQueue];
}

-(void)downloadQueueComplete
{
	BOOL errors = NO;
	if ([failedDownloads count] > 0) {
		errors = YES;
		assetDownloadArray = [NSMutableArray arrayWithArray:failedDownloads];
		failedDownloads = [[NSMutableArray alloc] init];
	}
	if ([[self delegate] respondsToSelector:@selector(queuedDownloadsCompleteWithErrors:	)]) [[self delegate] queuedDownloadsCompleteWithErrors:errors];
}

@end
