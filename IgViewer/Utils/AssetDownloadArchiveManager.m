//
//  AssetDownloadArchiveManager.m
//  IgViewer
//
//  Created by matata on 28/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "AssetDownloadArchiveManager.h"
#import "AssetDownload.h"

@implementation AssetDownloadArchiveManager

@synthesize shouldDeleteFileOnSuccess;

-(id)init
{
	self = [super init];
	if (self) {
		assetArray = [[NSMutableArray alloc] init];
		completedArchives = [[NSMutableArray alloc] init];
		failedArchives = [[NSMutableArray alloc] init];
		shouldDeleteFileOnSuccess = NO;
	}
	return self;
}

-(void)addAsset:(AssetDownload *)asset withPath:(NSString *)path
{
	[asset setUnzipDirectory:path];
	[assetArray addObject:asset];
}

-(void)startUnzipQueue
{
	if ([assetArray count] > 0) {
		currentAsset = [assetArray objectAtIndex:0];
		if ([currentAsset unzipDirectory]) {
			[currentAsset moveFileToPath:[currentAsset unzipDirectory]];
			[currentAsset unzipFileWithDelegate:self];
		} else {
			[self assetUnzipFailed];
		}
	} else {
		[self unzipQueueComplete];
	}
}

-(void)assetUnzipComplete
{
	if (shouldDeleteFileOnSuccess) {
		[currentAsset deleteFile];
	} else {
		[completedArchives addObject:currentAsset];
	}
	[assetArray removeObjectAtIndex:0];
	[self startUnzipQueue];
}

-(void)assetUnzipFailed
{
	[failedArchives addObject:currentAsset];
	[assetArray removeObjectAtIndex:0];
	[self startUnzipQueue];
}

-(void)unzipQueueComplete
{
	BOOL errors = NO;
	if ([failedArchives count] > 0) {
		errors = YES;
		assetArray = [NSMutableArray arrayWithArray:failedArchives];
		failedArchives = [[NSMutableArray alloc] init];
	}
	if ([[self delegate] respondsToSelector:@selector(queuedFilesUnzippedAndRemoved:withErrors:)]) [[self delegate] queuedFilesUnzippedAndRemoved:shouldDeleteFileOnSuccess withErrors:errors];
}

@end
