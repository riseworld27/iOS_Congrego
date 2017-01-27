//
//  UpdateHandler.m
//  IgViewer
//
//  Created by matata on 11/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "UpdateHandler.h"
#import "CoreDataHandler.h"
#import "JSONHandler.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Download.h"
#import "AssetDateHashPairing.h"
#import "CMSUtils.h"
#import "AssetDownloadManager.h"
#import "AssetBundles.h"
#import "AssetDownload.h"
#import "Asset.h"
#import "Reachability.h"
#import "LoginProcess.h"
#import "CMSUtils.h"

@interface UpdateHandler()
@property (strong, nonatomic) AssetDownload *iconImagesBundle;
@property (strong, nonatomic) AssetDownload *productImagesBundle;
@end

@implementation UpdateHandler

-(id)init
{
	self = [super init];
	if (self) {
		currentDate = [NSDate date];
		isCheckingForUpdates = NO;
		isPreparingForUpdates = NO;
		updateAttemptCount = 0;
	}
	return self;
}

-(void)checkForUpdates
{
	updateAttemptCount++;
	
	if (!isCheckingForUpdates && !isValidating) {
		if (operationForUpdateCount) {
			[operationForUpdateCount cancel];
			operationForUpdateCount = NULL;
		}
		
		isCheckingForUpdates = YES;
		CLS_LOG(@"Checking for updates...");
		//NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://ropecloud.com/igviewer/json/temp.json"]];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[CMSUtils urlWithPath:@"/api/v1/json/all/data.json" andArguments:[CMSUtils dictionaryForLoginDetails]]]];
		[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
		__block UpdateHandler *blockSelf = self;
		
		operationForUpdateCount = [[AFHTTPRequestOperation alloc] initWithRequest:request];
		[operationForUpdateCount setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			CLS_LOG(@"JSON Loaded for updates...");
			[blockSelf JSONRecievedForUpdateCount];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			CLS_LOG(@"Error fetching JSON:\n%@ (UpdateHandler > checkForUpdates)", error);
			[blockSelf errorFetchingJsonForUpdateCount];
		}];
		[operationForUpdateCount start];
	}
}

-(void)errorFetchingJsonForUpdateCount
{
	isValidating = NO;
	isCheckingForUpdates = NO;
	
	if (updateAttemptCount <= 1) {
		[self attemptUserLoginUpdateWithUpdateType:UpdateHandlerUpdateTypeCount];
	} else {
		[self userLoginFailedFromAutomaticAttempt:NO];
	}
}

-(void)errorFetchingJsonForDownloads
{
	isPreparingForUpdates = NO;
	isValidating = NO;
	
	if (updateAttemptCount <= 1) {
		[self attemptUserLoginUpdateWithUpdateType:UpdateHandlerUpdateTypeDownload];
	} else {
		[self userLoginFailedFromAutomaticAttempt:NO];
	}
}

-(void)attemptUserLoginUpdateWithUpdateType:(UpdateHandlerUpdateType)type
{
	loginProcessUpdateType = type;
	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	tempLoginSessionId = [ud objectForKey:@"sessionId"];
	tempLoginSessionName = [ud objectForKey:@"sessionName"];
	
	[ud removeObjectForKey:@"sessionId"];
	[ud removeObjectForKey:@"sessionName"];
	[ud synchronize];
	
	loginProcess = [[LoginProcess alloc] init];
	[loginProcess setDelegate:self];
	[loginProcess login];
}

-(void)userLoggedInWithCredentials:(LoginSessionCredentials *)credentials
{
	[CMSUtils setUserCredentials:credentials];
	
	if (loginProcessUpdateType == UpdateHandlerUpdateTypeCount) {
		loginProcessUpdateType = UpdateHandlerUpdateTypeNone;
		[self checkForUpdates];
	}
	
	if (loginProcessUpdateType == UpdateHandlerUpdateTypeDownload) {
		loginProcessUpdateType = UpdateHandlerUpdateTypeNone;
		[self validateDatabases];
	}
}

-(void)userLoginFailedFromAutomaticAttempt:(BOOL)automatic
{
	if ([self delegate]) {
		if ([[self delegate] respondsToSelector:@selector(updateFailed)]) {
			[[self delegate] updateFailed];
		}
	}
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Connection error"
						  message: @"There was an error connecting to the server, please try again later."
						  delegate: nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	
	if (tempLoginSessionId && tempLoginSessionName) {
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		[ud setValue:tempLoginSessionId forKey:@"sessionId"];
		[ud setValue:tempLoginSessionName forKey:@"sessionName"];
		[ud synchronize];
	}
	
	tempLoginSessionId = NULL;
	tempLoginSessionName = NULL;
	
	updateAttemptCount = 0;
}

-(void)JSONRecievedForUpdateCount
{	
	JSONHandler *jsonHandler = [[JSONHandler alloc] initWithJSONString:[operationForUpdateCount responseString]];
	
	int updates = 0;
	NSMutableArray *assetHashArray = [[NSMutableArray alloc] init];
	
	if ([jsonHandler bundles]) {
		userDefaults = [NSUserDefaults standardUserDefaults];
		NSInteger lastSyncInterval = [userDefaults integerForKey:@"lastSyncDate"];
		//NSInteger lastSyncInterval = 1337185289;
		NSDate *lastSyncDate = [NSDate dateWithTimeIntervalSince1970:lastSyncInterval];
		NSDictionary *bundles = [jsonHandler bundles];
		if (bundles) {
			if ([bundles objectForKey:@"icons"]) {
				NSDictionary *iconBundle = (NSDictionary *)[bundles objectForKey:@"icons"];
				NSString *iconDateString = (NSString *)[iconBundle objectForKey:@"updated"];
				if (![iconDateString isEqualToString:@""]) {
					NSInteger iconDateInterval = [iconDateString integerValue];
					NSDate *iconDate = [NSDate dateWithTimeIntervalSince1970:iconDateInterval];
					BOOL iconsUpdated = [self hasAssetWithDate:iconDate beenUpdateSince:lastSyncDate];
					if (iconsUpdated) updates++;
				}
			}
			if ([bundles objectForKey:@"products"]) {
				NSDictionary *productsBundle = (NSDictionary *)[bundles objectForKey:@"products"];
				NSString *productDateString = (NSString *)[productsBundle objectForKey:@"updated"];
				if (![productDateString isEqualToString:@""]) {
					NSInteger productDateInterval = [productDateString integerValue];
					NSDate *productDate = [NSDate dateWithTimeIntervalSince1970:productDateInterval];
					BOOL productsUpdated = [self hasAssetWithDate:productDate beenUpdateSince:lastSyncDate];
					if (productsUpdated) updates++;
				}
			}
			if ([bundles objectForKey:@"webResources"]) {
				NSDictionary *webBundle = (NSDictionary *)[bundles objectForKey:@"webResources"];
				NSString *webDateString = (NSString *)[webBundle objectForKey:@"updated"];
				if (![webDateString isEqualToString:@""]) {
					NSInteger webDateInterval = [webDateString integerValue];
					NSDate *webDate = [NSDate dateWithTimeIntervalSince1970:webDateInterval];
					BOOL webUpdated = [self hasAssetWithDate:webDate beenUpdateSince:lastSyncDate];
					if (webUpdated) updates++;
				}
			}
		}
	}
	
	if ([jsonHandler products]) {
		NSArray *products = [jsonHandler products];
		for (int p=0; p<[products count]; p++) {
			NSDictionary *productDictionary = (NSDictionary *)[products objectAtIndex:p];
			NSArray *categories = [productDictionary objectForKey:@"categories"];
			for (int c=0; c<[categories count]; c++) {
				NSDictionary *categoryDictionary = (NSDictionary *)[categories objectAtIndex:c];
				NSArray *collections = [categoryDictionary objectForKey:@"assets"];
				for (int d=0; d<[collections count]; d++) {
					NSDictionary *collectionDictionary = (NSDictionary *)[collections objectAtIndex:d];
					if ([collectionDictionary objectForKey:@"isCollection"]) {
						// IS A COLLECTION
						NSArray *collectionAssetsArray = [collectionDictionary objectForKey:@"assets"];
						for (int a=0; a<[collectionAssetsArray count]; a++) {
							NSDictionary *assetDictionary = (NSDictionary *)[collectionAssetsArray objectAtIndex:a];
							AssetDateHashPairing *pairing = [self createPairingFromDictionary:assetDictionary];
							if (pairing) [assetHashArray addObject:pairing];
						}
					} else {
						NSMutableDictionary *assetDictionary = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[collections objectAtIndex:d]];
                        if ([assetDictionary objectForKey:@"assetType"] == [NSNull null])
                        {
                            [assetDictionary setObject:[NSNumber numberWithInt:5] forKey:@"assetType"];
                        }
						AssetDateHashPairing *pairing = [self createPairingFromDictionary:assetDictionary];
						if (pairing) [assetHashArray addObject:pairing];
					}
				}
			}
		}
		
		NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
		for (int i=0; i<[assetHashArray count]; i++) {
			AssetDateHashPairing *pairing = (AssetDateHashPairing *)[assetHashArray objectAtIndex:i];
			BOOL shouldAdd = YES;
			for (int f=0; f<[filteredArray count]; f++) {
				AssetDateHashPairing *filterPairing = (AssetDateHashPairing *)[filteredArray objectAtIndex:f];
				if ([pairing isEqualToPairing:filterPairing]) shouldAdd = NO;
			}
			if (shouldAdd) {
				[filteredArray addObject:pairing];
			}
		}
		
		if ([filteredArray count] > 0) {
			// LOOP THROUGH DOWNLOADS AND COMPARE
			for (int i=0; i<[filteredArray count]; i++) {
				AssetDateHashPairing *pairing = (AssetDateHashPairing *)[filteredArray objectAtIndex:i];
				Download *download = [CoreDataHandler fetchDownloadWithHash:[pairing hashValue]];
				if (download) {
					if ([self hasAssetWithDate:[pairing date] beenUpdateSince:[download downloadDate]] && [download downloaded]) {
						updates++;
					}
				}
			}
		}
	}
	
	if ([[self delegate] respondsToSelector:@selector(updatesAvailableWithCount:)]) {
		[[self delegate] updatesAvailableWithCount:updates];
	}
	
	isCheckingForUpdates = NO;
	updateAttemptCount = 0;
}

-(void)prepareToDownloadUpdates
{
	updateAttemptCount++;
	
	if (!isPreparingForUpdates && !isValidating) {
		if (operationForDownloads) {
			[operationForDownloads cancel];
			operationForDownloads = NULL;
		}
		
		isPreparingForUpdates = YES;
		//NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://ropecloud.com/igviewer/json/temp.json"]];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[CMSUtils urlWithPath:@"/api/v1/json/all/data.json" andArguments:[CMSUtils dictionaryForLoginDetails]]]];
		[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
		__block UpdateHandler *blockSelf = self;
		
		operationForDownloads = [[AFHTTPRequestOperation alloc] initWithRequest:request];
		[operationForDownloads setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			//CLS_LOG(@"JSON Loaded...");
			[blockSelf JSONRecievedForUpdateDownload];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			CLS_LOG(@"Error fetching JSON:\n%@ (UpdateHandler > prepareToDownloadUpdates)", error);
			[operation cancel];
			[blockSelf errorFetchingJsonForDownloads];
		}];
		[operationForDownloads start];
	}
}

-(void)JSONRecievedForUpdateDownload
{
	JSONHandler *jsonHandler = [[JSONHandler alloc] initWithJSONString:[operationForDownloads responseString]];
	
	NSMutableArray *assetHashArray = [[NSMutableArray alloc] init];
	NSMutableArray *downloadsArray = [[NSMutableArray alloc] init];
	
	BOOL downloadBundles = NO;
	
	if ([jsonHandler bundles]) {
		userDefaults = [NSUserDefaults standardUserDefaults];
		NSInteger lastSyncInterval = [userDefaults integerForKey:@"lastSyncDate"];
		//NSInteger lastSyncInterval = 1337185289;
		NSDate *lastSyncDate = [NSDate dateWithTimeIntervalSince1970:lastSyncInterval];
		NSDictionary *bundles = [jsonHandler bundles];
		if (bundles) {
			if ([bundles objectForKey:@"icons"]) {
				NSDictionary *iconBundle = (NSDictionary *)[bundles objectForKey:@"icons"];
				NSString *iconDateString = (NSString *)[iconBundle objectForKey:@"updated"];
				if (![iconDateString isEqualToString:@""]) {
					NSInteger iconDateInterval = [iconDateString integerValue];
					NSDate *iconDate = [NSDate dateWithTimeIntervalSince1970:iconDateInterval];
					BOOL iconsUpdated = [self hasAssetWithDate:iconDate beenUpdateSince:lastSyncDate];
					if (iconsUpdated) downloadBundles = YES;
				}
			}
			if ([bundles objectForKey:@"products"]) {
				NSDictionary *productsBundle = (NSDictionary *)[bundles objectForKey:@"products"];
				NSString *productDateString = (NSString *)[productsBundle objectForKey:@"updated"];
				if (![productDateString isEqualToString:@""]) {
					NSInteger productDateInterval = [productDateString integerValue];
					NSDate *productDate = [NSDate dateWithTimeIntervalSince1970:productDateInterval];
					BOOL productsUpdated = [self hasAssetWithDate:productDate beenUpdateSince:lastSyncDate];
					if (productsUpdated) downloadBundles = YES;
				}
			}
			if ([bundles objectForKey:@"webResources"]) {
				NSDictionary *webBundle = (NSDictionary *)[bundles objectForKey:@"webResources"];
				NSString *webDateString = (NSString *)[webBundle objectForKey:@"updated"];
				if (![webDateString isEqualToString:@""]) {
					NSInteger webDateInterval = [webDateString integerValue];
					NSDate *webDate = [NSDate dateWithTimeIntervalSince1970:webDateInterval];
					BOOL webUpdated = [self hasAssetWithDate:webDate beenUpdateSince:lastSyncDate];
					if (webUpdated) downloadBundles = YES;
				}
			}
		}
	}
	
	if ([jsonHandler products]) {
		NSArray *products = [jsonHandler products];
		for (int p=0; p<[products count]; p++) {
			NSDictionary *productDictionary = (NSDictionary *)[products objectAtIndex:p];
			NSArray *categories = [productDictionary objectForKey:@"categories"];
			for (int c=0; c<[categories count]; c++) {
				NSDictionary *categoryDictionary = (NSDictionary *)[categories objectAtIndex:c];
				NSArray *collections = [categoryDictionary objectForKey:@"assets"];
				for (int d=0; d<[collections count]; d++) {
					NSDictionary *collectionDictionary = (NSDictionary *)[collections objectAtIndex:d];
					if ([collectionDictionary objectForKey:@"isCollection"]) {
						// IS A COLLECTION
						NSArray *collectionAssetsArray = [collectionDictionary objectForKey:@"assets"];
						for (int a=0; a<[collectionAssetsArray count]; a++) {
							NSDictionary *assetDictionary = (NSDictionary *)[collectionAssetsArray objectAtIndex:a];
							AssetDateHashPairing *pairing = [self createPairingFromDictionary:assetDictionary];
							if (pairing) [assetHashArray addObject:pairing];
						}
					} else {
                        NSMutableDictionary *assetDictionary = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[collections objectAtIndex:d]];
                        if ([assetDictionary objectForKey:@"assetType"] == [NSNull null])
                        {
                            [assetDictionary setObject:[NSNumber numberWithInt:5] forKey:@"assetType"];
                        }
						AssetDateHashPairing *pairing = [self createPairingFromDictionary:assetDictionary];
						if (pairing) [assetHashArray addObject:pairing];
					}
				}
			}
		}
		
		NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
		for (int i=0; i<[assetHashArray count]; i++) {
			AssetDateHashPairing *pairing = (AssetDateHashPairing *)[assetHashArray objectAtIndex:i];
			BOOL shouldAdd = YES;
			for (int f=0; f<[filteredArray count]; f++) {
				AssetDateHashPairing *filterPairing = (AssetDateHashPairing *)[filteredArray objectAtIndex:f];
				if ([pairing isEqualToPairing:filterPairing]) shouldAdd = NO;
			}
			if (shouldAdd) {
				[filteredArray addObject:pairing];
			}
		}
		
		if ([filteredArray count] > 0) {
			// LOOP THROUGH DOWNLOADS AND COMPARE
			for (int i=0; i<[filteredArray count]; i++) {
				AssetDateHashPairing *pairing = (AssetDateHashPairing *)[filteredArray objectAtIndex:i];
				Download *download = [CoreDataHandler fetchDownloadWithHash:[pairing hashValue]];
				if (download) {
					if ([self hasAssetWithDate:[pairing date] beenUpdateSince:[download downloadDate]] && [download downloaded]) {
						[downloadsArray addObject:download];
					}
				}
			}
		}
	}
	
	if ([[self delegate] respondsToSelector:@selector(downloadsAvailableForDownloads:andBundles:)] && ([downloadsArray count] > 0 || downloadBundles)) {
		[[self delegate] downloadsAvailableForDownloads:downloadsArray andBundles:downloadBundles];
	}
	
	isPreparingForUpdates = NO;
	updateAttemptCount = 0;
}

-(void)updateBundles
{
	updateAttemptCount++;
	
	CLS_LOG(@"Updating bundles...");
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[CMSUtils urlWithPath:@"/api/v1/json/all/data.json" andArguments:[CMSUtils dictionaryForLoginDetails]]]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	__block UpdateHandler *blockSelf = self;
	
	operationForValidation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[operationForValidation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		CLS_LOG(@"JSON Loaded for bundle updates...");
		[blockSelf JSONRecievedForBundleUpdate];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		CLS_LOG(@"Error fetching JSON:\n%@ (UpdateHandler > updateBundles)", error);
		[operation cancel];
		[blockSelf errorFetchingJsonForUpdateCount];
	}];
	[operationForValidation start];
}

-(void)JSONRecievedForBundleUpdate
{
	[CoreDataHandler clearDatabasesIncludeAppPopulated:NO];
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:NO forKey:@"bundlesInstalled"];
	[userDefaults synchronize];
	
	JSONHandler *jsonHandler = [[JSONHandler alloc] initWithJSONString:[operationForValidation responseString]];
	
	AssetDownloadManager *downloadManager = [[AssetDownloadManager alloc] init];
	[downloadManager setDelegate:self];
	
	AssetBundles *bundles = [jsonHandler parseBundles];
	
	if ([bundles iconBundleUrl]) {
		NSString *iconBundleUrl = [CMSUtils url:[bundles iconBundleUrl] withArguments:[CMSUtils dictionaryForLoginDetails]];
		//CLS_LOG(@"Icons url: %@", iconBundleUrl);
		self.iconImagesBundle = [[AssetDownload alloc] initWithDownloadUrl:iconBundleUrl];
		[self.iconImagesBundle setUserCredentials:NO];
		[downloadManager queueDownload:self.iconImagesBundle];
	}
	
	if ([bundles productImageBundle]) {
		NSString *productsBundleUrl = [CMSUtils url:[bundles productImageBundle] withArguments:[CMSUtils dictionaryForLoginDetails]];
		//CLS_LOG(@"Products url: %@", productsBundleUrl);
		self.productImagesBundle = [[AssetDownload alloc] initWithDownloadUrl:productsBundleUrl];
		[self.productImagesBundle setUserCredentials:NO];
		[downloadManager queueDownload:self.productImagesBundle];
	}
	
	if ([bundles webResourcesBundle]) {
		
	}
	
	[downloadManager startDownloadQueue];
	updateAttemptCount = 0;
}

-(void)queuedDownloadsCompleteWithErrors:(BOOL)errors
{
	CLS_LOG(@"Bundles update complete");
	
	NSDate *today = [NSDate date];
	NSInteger interval = [today timeIntervalSince1970];
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:interval forKey:@"lastSyncDate"];
	[userDefaults setBool:YES forKey:@"bundlesInstalled"];
	[userDefaults synchronize];
    
    // Unzip zip
    AssetDownloadArchiveManager *archiveManager = [[AssetDownloadArchiveManager alloc] init];
    [archiveManager setDelegate:self];
    [archiveManager setShouldDeleteFileOnSuccess:YES];
    if (self.iconImagesBundle) [archiveManager addAsset:self.iconImagesBundle withPath:@"/resources/bundles/icons/"];
    if (self.productImagesBundle) [archiveManager addAsset:self.productImagesBundle withPath:@"/resources/bundles/products/"];
    [archiveManager startUnzipQueue];
}

-(void)queuedFilesUnzippedAndRemoved:(BOOL)removed withErrors:(BOOL)errors
{
    CLS_LOG(@"Files unzipped with errors: %@", ((errors) ? @"YES" : @"NO"));
    
    if (isValidating) {
        [self updateDatabases];
    } else {
        if ([[self delegate] respondsToSelector:@selector(bundlesUpdated)]) {
            [[self delegate] bundlesUpdated];
        }
    }
}


-(void)updateDatabases
{
	CLS_LOG(@"Updating databases....");
	JSONHandler *jsonHandler = [[JSONHandler alloc] initWithJSONString:[operationForValidation responseString]];
	[jsonHandler parseProducts];
	[self validateDownloads];
}

-(void)validateDownloads
{
	CLS_LOG(@"Validating downloads...");
	NSArray *downloadsArray = [CoreDataHandler fetchAllDownloads];
	for (int i=0; i<[downloadsArray count]; i++) {
		Download *download = (Download *)[downloadsArray objectAtIndex:i];
		NSArray *assetArray = [CoreDataHandler fetchAssetsWithHash:[download downloadHash]];
		for (int a=0; a<[assetArray count]; a++) {
			Asset *asset = (Asset *)[assetArray objectAtIndex:a];
			[asset setDownload:download];
			[download addAssetsObject:asset];
		}
		if ([assetArray count] <= 0) {
			[CoreDataHandler removeDownloadWithDownload:download];
		}
	}
	
	[CoreDataHandler commit];
	
	isValidating = NO;
	
	if ([[self delegate] respondsToSelector:@selector(databaseValidationComplete)]) {
		[[self delegate] databaseValidationComplete];
	}
}

-(void)validateDatabases
{
	isValidating = YES;
	//[CoreDataHandler clearDatabasesIncludeAppPopulated:NO];
	[self updateBundles];
}

-(BOOL)hasAssetWithDate:(NSDate *)assetDate beenUpdateSince:(NSDate *)syncDate
{
	BOOL updated = NO;
	
	if ([syncDate compare:assetDate] == NSOrderedDescending) {
		//CLS_LOG(@"date1 is later than date2");
		updated = NO;
	} else if ([syncDate compare:assetDate] == NSOrderedAscending) {
		//CLS_LOG(@"date1 is earlier than date2");
		updated = YES;
	} else {
		//CLS_LOG(@"dates are the same");
		updated = NO;
	}
	
	return updated;
}

-(AssetDateHashPairing *)createPairingFromDictionary:(NSDictionary *)dictionary
{
	AssetDateHashPairing *pairing = NULL;
	if ([dictionary objectForKey:@"updated"]) {
		NSString *hashValue = [CoreDataHandler assetHashFromDictionary:dictionary];
		NSString *epochString = [dictionary objectForKey:@"updated"];
		int epoch = [epochString intValue];
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:epoch];
		pairing = [[AssetDateHashPairing alloc] init];
		[pairing setDate:date];
		[pairing setHashValue:hashValue];
	}
	return pairing;
}

@end
