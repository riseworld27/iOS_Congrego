//
//  AssetDownloadArchiveManager.h
//  IgViewer
//
//  Created by matata on 28/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetDownload.h"

@protocol AssetDownloadArchiveManagerDelegate <NSObject>

@optional
-(void)queuedFilesUnzippedAndRemoved:(BOOL)removed withErrors:(BOOL)errors;

@end

@interface AssetDownloadArchiveManager : NSObject <AssetDownloadDelegate>
{
	NSMutableArray *assetArray;
	NSMutableArray *completedArchives;
	NSMutableArray *failedArchives;
	AssetDownload *currentAsset;
}

@property (nonatomic) BOOL shouldDeleteFileOnSuccess;
@property (nonatomic, retain) id <AssetDownloadArchiveManagerDelegate> delegate;

-(void)addAsset:(AssetDownload *)asset withPath:(NSString *)path;
-(void)startUnzipQueue;

@end
