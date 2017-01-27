//
//  AssetDownloadManager.h
//  IgViewer
//
//  Created by matata on 25/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetDownload.h"

@protocol AssetDownloadManagerDelegate <NSObject>

@optional
-(void)queuedDownloadsCompleteWithErrors:(BOOL)errors;

@end

@interface AssetDownloadManager : NSObject <AssetDownloadDelegate>
{
	NSMutableArray *assetDownloadArray;
	NSMutableArray *completedDownloads;
	NSMutableArray *failedDownloads;
	AssetDownload *currentAsset;
}

@property (nonatomic, retain) id <AssetDownloadManagerDelegate> delegate;

-(void)queueDownload:(AssetDownload *)download;
-(void)startDownloadQueue;

@end
