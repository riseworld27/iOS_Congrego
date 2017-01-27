//
//  CoreDataDownloadQueue.h
//  IgViewer
//
//  Created by matata on 04/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetDownload.h"

@class Download, AssetDownload, Asset;

@protocol CoreDataDownloadQueueProgressDelegate <NSObject>

@optional
-(void)downloadDidUpdateProgressWithPercent:(float)percent;
-(void)downloadDidCompleteDownloadWithNextInQueue:(Download *)download;

@end

@protocol CoreDataDownloadQueueDelegate <NSObject>

@optional
-(void)downloadInQueueDidComplete;
-(void)downloadFailedWithDownload:(Download *)download;

@end

@interface CoreDataDownloadQueue : NSObject <AssetDownloadDelegate>
{
	NSMutableArray *downloadArray;
	NSMutableArray *failedArray;
	AssetDownload *currentAssetDownload;
	Download *currentDownload;
	int currentIndex;
	BOOL isDownloading;
}

@property (nonatomic, retain) id <CoreDataDownloadQueueProgressDelegate> progressDelegate;
@property (nonatomic, retain) id <CoreDataDownloadQueueDelegate> delegate;

-(void)processQueue;
-(void)cancelDownload:(Download *) download;
-(BOOL)addDownload:(Download *)download;
-(BOOL)addDownload:(Download *)download andAutoStart:(BOOL)autoStart;
-(int)downloadsInQueue;
-(BOOL)isAssetDownloading:(Asset *)asset;
-(void)cancelDownloads;

+(CoreDataDownloadQueue *)sharedInstance;

@end
