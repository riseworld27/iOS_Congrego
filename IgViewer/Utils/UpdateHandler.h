//
//  UpdateHandler.h
//  IgViewer
//
//  Created by matata on 11/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "AssetDownloadManager.h"
#import "AssetDownloadArchiveManager.h"
#import "LoginProcess.h"

typedef NS_ENUM(NSInteger, UpdateHandlerUpdateType) {
	UpdateHandlerUpdateTypeNone,
    UpdateHandlerUpdateTypeCount,
    UpdateHandlerUpdateTypeDownload
};

@class JSONHandler, LoginProcess;

@protocol UpdateHandlerDelegate <NSObject>

@optional
-(void)updateHandlerReady;
-(void)updatesAvailableWithCount:(int)count;
-(void)downloadsAvailableForDownloads:(NSMutableArray *)downloadArray andBundles:(BOOL)bundles;
-(void)bundlesUpdated;
-(void)databaseValidationComplete;
-(void)updateFailed;

@end

@interface UpdateHandler : NSObject <AssetDownloadArchiveManagerDelegate, AssetDownloadManagerDelegate, LoginProcessDelegate>
{
	NSDate *currentDate;
	NSUserDefaults *userDefaults;
	AFHTTPRequestOperation *operationForUpdateCount;
	AFHTTPRequestOperation *operationForDownloads;
	AFHTTPRequestOperation *operationForValidation;
	LoginProcess *loginProcess;
	UpdateHandlerUpdateType loginProcessUpdateType;
	int updateAttemptCount;
	BOOL isCheckingForUpdates;
	BOOL isPreparingForUpdates;
	BOOL isValidating;
	
	NSString *tempLoginSessionId;
	NSString *tempLoginSessionName;
}

@property (nonatomic, weak) id <UpdateHandlerDelegate> delegate;

-(void)checkForUpdates;
-(void)prepareToDownloadUpdates;
-(void)updateBundles;
-(void)updateDatabases;
-(void)validateDownloads;
-(void)validateDatabases;

@end
