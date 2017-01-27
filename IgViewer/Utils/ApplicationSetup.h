//
//  ApplicationSetup.h
//  IgViewer
//
//  Created by matata on 27/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetDownloadManager.h"
#import "AssetDownloadArchiveManager.h"
#import "AFHTTPRequestOperation.h"

@class AssetDownload, AFJSONRequestOperation, JSONHandler;

@protocol ApplicationSetupDelegate <NSObject>

@optional
-(void)setupComplete;
-(void)setupError;

@end

@interface ApplicationSetup : NSObject <AssetDownloadManagerDelegate, AssetDownloadArchiveManagerDelegate>
{
	AssetDownload *iconImagesBundle;
	AssetDownload *productImagesBundle;
	AssetDownload *htmlResourcesBundle;
	AFHTTPRequestOperation *operation;
	NSUserDefaults *userDefaults;
	JSONHandler *jsonHandler;
}

@property (nonatomic, retain) id <ApplicationSetupDelegate> delegate;

-(void)setup;

@end
