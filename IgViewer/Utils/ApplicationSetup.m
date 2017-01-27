//
//  ApplicationSetup.m
//  IgViewer
//
//  Created by matata on 27/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "ApplicationSetup.h"
#import "CoreDataHandler.h"
#import "AssetDownload.h"
#import "FileUtils.h"
#import "AssetDownloadArchiveManager.h"
#import "JSONHandler.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPRequestOperation.h"
#import "CMSUtils.h"
#import "LoginSessionCredentials.h"
#import "AssetBundles.h"
#import "CMSUtils.h"

static BOOL forceRebuild = NO;
static BOOL forceBundleUpdate = NO;

@implementation ApplicationSetup

-(void)setup
{
	if ([CMSUtils isTesting]) {
		CLS_LOG(@"***********************************************");
		CLS_LOG(@"**************  TESTING BUILD  **************");
		CLS_LOG(@"*********  CMSUtils > testing = YES;  **********");
		CLS_LOG(@"***********************************************");
	}
	
	[[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (forceRebuild) {
		[CoreDataHandler clearDatabasesIncludeAppPopulated:YES];
		[userDefaults setBool:NO forKey:@"jsonParsed"];
		[userDefaults setBool:NO forKey:@"bundlesInstalled"];
		[userDefaults synchronize];
	}
	
	if (forceBundleUpdate) {
		[userDefaults setBool:NO forKey:@"bundlesInstalled"];
		[userDefaults synchronize];
	}
	
	BOOL jsonParsed = [userDefaults boolForKey:@"jsonParsed"];
	
	if (!jsonParsed) {
		[self fetchJSON];
	} else {
		BOOL bundlesInstalled = [userDefaults boolForKey:@"bundlesInstalled"];
		if (!bundlesInstalled) {
			[self installBundles];
		} else {
			[self setupProcessComplete];
		}
	}
}

-(void)fetchJSON
{
	//NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ropecloud.com/igviewer/json/temp.json"]];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[CMSUtils urlWithPath:@"/api/v1/json/all/data.json" andArguments:[CMSUtils dictionaryForLoginDetails]]]];
	__block ApplicationSetup *blockSelf = self;
	
	operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		CLS_LOG(@"JSON Loaded...");
		[blockSelf parseJSON];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		CLS_LOG(@"Error fetching JSON:\n%@ (ApplicationSetup > fetchJSON)", error);
        if ([[blockSelf delegate] respondsToSelector:@selector(setupError)]) [[blockSelf delegate] setupError];
	}];
	[operation start];
}

-(void)parseJSON
{
	jsonHandler = [[JSONHandler alloc] initWithJSONString:[operation responseString]];
	[jsonHandler parseProducts];
	CLS_LOG(@"JSON Parsed...");
	[userDefaults setBool:YES forKey:@"jsonParsed"];
	[userDefaults synchronize];
	
	BOOL bundlesInstalled = [userDefaults boolForKey:@"bundlesInstalled"];
	if (!bundlesInstalled) {
		[self installBundles];
	} else {
		[self setupProcessComplete];
	}
}

-(void)installBundles
{
	CLS_LOG(@"Downloading bundles....");
	AssetDownloadManager *downloadManager = [[AssetDownloadManager alloc] init];
	[downloadManager setDelegate:self];
	
	AssetBundles *bundles = [jsonHandler parseBundles];
	
	if ([bundles iconBundleUrl]) {
		CLS_LOG(@"Has Icon bundle...");
		//iconImagesBundle = [[AssetDownload alloc] initWithDownloadUrl:@"http://ropecloud.com/igviewer/resources/iconBundle.zip"];
		NSString *iconBundleUrl = [CMSUtils url:[bundles iconBundleUrl] withArguments:[CMSUtils dictionaryForLoginDetails]];
		CLS_LOG(@"Icons url: %@", iconBundleUrl);
		iconImagesBundle = [[AssetDownload alloc] initWithDownloadUrl:iconBundleUrl];
		[iconImagesBundle setUserCredentials:NO];
		[downloadManager queueDownload:iconImagesBundle];
	}
	
	if ([bundles productImageBundle]) {
		CLS_LOG(@"Has Products bundle...");
		//productImagesBundle = [[AssetDownload alloc] initWithDownloadUrl:@"http://ropecloud.com/igviewer/resources/productImagesBundle.zip"];
		NSString *productsBundleUrl = [CMSUtils url:[bundles productImageBundle] withArguments:[CMSUtils dictionaryForLoginDetails]];
		CLS_LOG(@"Products url: %@", productsBundleUrl);
		productImagesBundle = [[AssetDownload alloc] initWithDownloadUrl:productsBundleUrl];
		[productImagesBundle setUserCredentials:NO];
		[downloadManager queueDownload:productImagesBundle];
	}
	
	if ([bundles webResourcesBundle]) {
		
	}
	
	[downloadManager startDownloadQueue];
}

-(void)queuedDownloadsCompleteWithErrors:(BOOL)errors
{
	if (errors) {
		CLS_LOG(@"Downloads not completed...");
	} else {
		CLS_LOG(@"Downloads completed...");
		AssetDownloadArchiveManager *archiveManager = [[AssetDownloadArchiveManager alloc] init];
		[archiveManager setDelegate:self];
		[archiveManager setShouldDeleteFileOnSuccess:YES];
		if (iconImagesBundle) [archiveManager addAsset:iconImagesBundle withPath:@"/resources/bundles/icons/"];
		if (productImagesBundle) [archiveManager addAsset:productImagesBundle withPath:@"/resources/bundles/products/"];
		[archiveManager startUnzipQueue];
	}
}

-(void)queuedFilesUnzippedAndRemoved:(BOOL)removed withErrors:(BOOL)errors
{
	CLS_LOG(@"Files unzipped with errors: %@", ((errors) ? @"YES" : @"NO"));
	//[FileUtils listFilesAtPath:[FileUtils newPath:@"/resources/bundles/icons/" create:YES]];
	//[FileUtils listFilesAtPath:[FileUtils newPath:@"/resources/bundles/products/" create:YES]];
	[userDefaults setBool:YES forKey:@"bundlesInstalled"];
	[userDefaults synchronize];
	[self setupProcessComplete];
}

-(void)setupProcessComplete
{
	NSDate *today = [NSDate date];
	NSInteger interval = [today timeIntervalSince1970];
	
	[userDefaults setInteger:interval forKey:@"lastSyncDate"];
	[userDefaults synchronize];
	
	if ([[self delegate] respondsToSelector:@selector(setupComplete)]) [[self delegate] setupComplete];
}

@end
