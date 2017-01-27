//
//  CoreDataDownloadQueue.m
//  IgViewer
//
//  Created by matata on 04/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "CoreDataDownloadQueue.h"
#import "CoreDataHandler.h"
#import "Download.h"
#import "AssetDownload.h"
#import "FileUtils.h"
#import "Asset.h"
#import "AssetDownload.h"

static CoreDataDownloadQueue *sharedInstance;

@implementation CoreDataDownloadQueue

-(id)init
{
	self = [super init];
	if (self) {
		sharedInstance = self;
		CLS_LOG(@"Total number of downloads: %i", [CoreDataHandler numberOfDownloads]);
		downloadArray = [CoreDataHandler fetchAllIncompleteDownloads];
		CLS_LOG(@"Resuming download of %lu assets", (unsigned long)[downloadArray count]);
		failedArray = [[NSMutableArray alloc] init];
		currentIndex = 0;
		isDownloading = NO;
	}
	return self;
}

-(void)processQueue
{
	CLS_LOG(@"Processing %lu downloads in queue.", (unsigned long)[downloadArray count]);
	if ([downloadArray count] > 0 && !isDownloading) {
		isDownloading = YES;
		currentDownload = (Download *)[downloadArray objectAtIndex:0];
		[currentDownload setIsDownloading:[NSNumber numberWithBool:YES]];
		currentAssetDownload = [[AssetDownload alloc] initWithDownload:currentDownload];
		[currentAssetDownload setDelegate:self];
		[currentAssetDownload download];
	} else {
		[self downloadQueueComplete];
	}
}

-(BOOL)isAssetDownloading:(Asset *)asset
{
	BOOL downloading = NO;
	
	if ([asset download] && currentAssetDownload) {
		if ([currentDownload isEqualToDownload:[asset download]]) downloading = YES;
	}
	
	return downloading;
}

-(void)downloadDidUpdateWithPercent:(float)percent
{
	if ([[self progressDelegate] respondsToSelector:@selector(downloadDidUpdateProgressWithPercent:)]) {
		[[self progressDelegate] downloadDidUpdateProgressWithPercent:percent];
	}
}

-(void)assetDownloadComplete
{
	Download *download = (Download *)[downloadArray objectAtIndex:0];
	
	if ([[download fileType] intValue] == AssetFileTypePdf) {
		[currentAssetDownload moveFileToPath:[download localPath]];
	}
	if ([[download fileType] intValue] == AssetFileTypeVideo) {
		[currentAssetDownload moveFileToPath:[download localPath]];
	}
	if ([[download fileType] intValue] == AssetFileTypeAudio) {
		[currentAssetDownload moveFileToPath:[download localPath]];
	}
	if ([[download fileType] intValue] == AssetFileTypeHtml) {
		[currentAssetDownload unzipFileTo:[download localPath]];
	}
	if ([[download fileType] intValue] == AssetFileTypeImage) {
		[currentAssetDownload moveFileToPath:[download localPath]];
    }
    if ([[download fileType] intValue] == AssetFileTypeWordDoc) {
        [currentAssetDownload moveFileToPath:[download localPath]];
    }
	
	[download setDownloaded:[NSNumber numberWithBool:YES]];
	[download setIsDownloading:[NSNumber numberWithBool:NO]];
	[download setDownloadDate:[NSDate date]];
	[downloadArray removeObjectAtIndex:0];
	isDownloading = NO;
	[CoreDataHandler commit];
	[self processQueue];
	
	Download *nextDownload = NULL;
	if ([downloadArray count] > 0) {
		nextDownload = (Download *)[downloadArray objectAtIndex:0];
	}
	if ([[self progressDelegate] respondsToSelector:@selector(downloadDidCompleteDownloadWithNextInQueue:)]) {
		[[self progressDelegate] downloadDidCompleteDownloadWithNextInQueue:nextDownload];
	}
	
	if ([[self delegate] respondsToSelector:@selector(downloadInQueueDidComplete)]) {
		[[self delegate] downloadInQueueDidComplete];
	}
}

-(void)cancelDownloads
{
	if (currentAssetDownload) {
        [currentAssetDownload cancelDownload:NO];
		[currentAssetDownload setDelegate:NULL];
	}
	isDownloading = NO;
}

-(void)assetDownloadFailed
{
    if (downloadArray.count > 0) {
        Download *download = (Download *)[downloadArray objectAtIndex:0];
        [download setDownloaded:[NSNumber numberWithBool:NO]];
        [download setIsDownloading:[NSNumber numberWithBool:NO]];
        [failedArray addObject:download];
        [downloadArray removeObjectAtIndex:0];
        [self processQueue];
        [CoreDataHandler commit];
        
        if ([[self delegate] respondsToSelector:@selector(downloadFailedWithDownload:)]) {
            [[self delegate] downloadFailedWithDownload:download];
        }
    }
}

-(void)downloadQueueComplete
{
	BOOL errors = NO;
	if ([failedArray count] > 0) errors = YES;
	
	CLS_LOG(@"Download completed with errors %@", ((errors) ? @"YES" : @"NO"));
	
	if (errors) {
		for (int i=0; i<[failedArray count]; i++) {
			Download *download = (Download *)[failedArray objectAtIndex:i];
			CLS_LOG(@"------------------------------------------");
			CLS_LOG(@"Could not download: %@", [download file]);
			CLS_LOG(@"From: %@", [download downloadUrl]);
			CLS_LOG(@"To: %@", [download localPath]);
			CLS_LOG(@"------------------------------------------");
			if (download) [CoreDataHandler removeDownloadWithDownload:download];
		}
	}
	
	currentDownload = NULL;
	currentAssetDownload = NULL;
	isDownloading = NO;
	if ([failedArray count] > 0) {
		//downloadArray = [NSMutableArray arrayWithArray:failedArray];
		failedArray = [[NSMutableArray alloc] init];
	}
}

-(void)cancelDownload:(Download *) download
{
    // Remove object from download array
    if ([downloadArray containsObject:download]) {
        [downloadArray removeObject:download];
    }
    
    // If its the current download, cancel it
    if ([currentDownload isEqualToDownload:download]) {
        [currentAssetDownload cancelDownload:YES];
        currentAssetDownload = nil;
        currentDownload = nil;
    }
    
    // Update download object
    [download setDownloaded:[NSNumber numberWithBool:NO]];
    [download setIsDownloading:[NSNumber numberWithBool:NO]];
    
    isDownloading = NO;
    [CoreDataHandler commit];
    
    // Download the next object if there is one
    [self processQueue];
}

-(BOOL)addDownload:(Download *)download
{
	return [self addDownload:download andAutoStart:YES];
}

-(BOOL)addDownload:(Download *)download andAutoStart:(BOOL)autoStart
{
	BOOL shouldAddDownload = YES;
	for (int i=0; i<[downloadArray count]; i++) {
		Download *dl = (Download *)[downloadArray objectAtIndex:i];
		if ([dl isEqualToDownload:download]) shouldAddDownload = NO;
	}
	
	for (int i=0; i<[failedArray count]; i++) {
		Download *dl = (Download *)[failedArray objectAtIndex:i];
		if ([dl isEqualToDownload:download]) shouldAddDownload = NO;
	}
	
	if (![[download downloaded] boolValue] && shouldAddDownload) {
		if ([[download fileType] intValue] == AssetFileTypePdf) {
			NSString *localPath = @"/resources/pdf/";
			NSString *fileName = [[download downloadUrl] lastPathComponent];
			fileName = [fileName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
			[download setFile:fileName];
			[download setLocalPath:localPath];
			
			CLS_LOG(@"------------------------------------------");
			CLS_LOG(@"Downloading: %@", fileName);
			CLS_LOG(@"From: %@", [download downloadUrl]);
			CLS_LOG(@"To: %@", localPath);
			CLS_LOG(@"------------------------------------------");
        }
        if ([[download fileType] intValue] == AssetFileTypeWordDoc) {
            NSString *localPath = @"/resources/docs/";
            NSString *fileName = [[download downloadUrl] lastPathComponent];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            [download setFile:fileName];
            [download setLocalPath:localPath];
            
            CLS_LOG(@"------------------------------------------");
            CLS_LOG(@"Downloading: %@", fileName);
            CLS_LOG(@"From: %@", [download downloadUrl]);
            CLS_LOG(@"To: %@", localPath);
            CLS_LOG(@"------------------------------------------");
        }
		if ([[download fileType] intValue] == AssetFileTypeVideo) {
			NSString *localPath = @"/resources/video/";
			NSString *fileName = [[download downloadUrl] lastPathComponent];
			fileName = [fileName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
			[download setFile:fileName];
			[download setLocalPath:localPath];
			
			CLS_LOG(@"------------------------------------------");
			CLS_LOG(@"Downloading: %@", fileName);
			CLS_LOG(@"From: %@", [download downloadUrl]);
			CLS_LOG(@"To: %@", localPath);
			CLS_LOG(@"------------------------------------------");
		}
		if ([[download fileType] intValue] == AssetFileTypeHtml) {
			NSString *fileName = [[download downloadUrl] lastPathComponent];
			NSString *fileDirectory = [fileName stringByDeletingPathExtension];
			NSString *localPath = [NSString stringWithFormat:@"/resources/html/%@/", fileDirectory];
			fileName = [fileName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
			[download setFile:fileName];
			[download setLocalPath:localPath];
			
			CLS_LOG(@"------------------------------------------");
			CLS_LOG(@"Downloading: %@", fileName);
			CLS_LOG(@"From: %@", [download downloadUrl]);
			CLS_LOG(@"To: %@", localPath);
			CLS_LOG(@"------------------------------------------");
		}
		if ([[download fileType] intValue] == AssetFileTypeAudio) {
			NSString *localPath = @"/resources/audio/";
			NSString *fileName = [[download downloadUrl] lastPathComponent];
			fileName = [fileName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
			[download setFile:fileName];
			[download setLocalPath:localPath];
			
			CLS_LOG(@"------------------------------------------");
			CLS_LOG(@"Downloading: %@", fileName);
			CLS_LOG(@"From: %@", [download downloadUrl]);
			CLS_LOG(@"To: %@", localPath);
			CLS_LOG(@"------------------------------------------");
		}
		if ([[download fileType] intValue] == AssetFileTypeImage) {
			NSString *localPath = @"/resources/images/";
			NSString *fileName = [[download downloadUrl] lastPathComponent];
			fileName = [fileName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
			[download setFile:fileName];
			[download setLocalPath:localPath];
			
			CLS_LOG(@"------------------------------------------");
			CLS_LOG(@"Downloading: %@", fileName);
			CLS_LOG(@"From: %@", [download downloadUrl]);
			CLS_LOG(@"To: %@", localPath);
			CLS_LOG(@"------------------------------------------");
		}
		[download setQueueDate:[NSDate date]];
		[downloadArray addObject:download];
		[CoreDataHandler commit];
		if (!isDownloading && autoStart) [self processQueue];
	} else {
		shouldAddDownload = NO;
		CLS_LOG(@"Asset is already downloaded.");
	}
	
	return shouldAddDownload;
}

-(int)downloadsInQueue
{
	return (int) [downloadArray count];
}

+(CoreDataDownloadQueue *)sharedInstance
{
	return sharedInstance;
}

@end
