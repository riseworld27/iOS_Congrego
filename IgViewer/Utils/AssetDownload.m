//
//  AssetDownload.m
//  IgViewer
//
//  Created by matata on 27/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "AssetDownload.h"
#import "FileUtils.h"
#import "AFDownloadRequestOperation.h"
#import "CoreDataHandler.h"
#import "Download.h"
#import "SSZipArchive.h"
#import "CMSUtils.h"
#import "NetworkManager.h"
#import "LoginProcess.h"

static NSString *defaultDownloadPath = @"/resources/downloads/";

@implementation AssetDownload

@synthesize downloadUrl, localPath, fileName, assetHasDownloaded, unzipDirectory, progressPercentage, currentDownload, userCredentials;

-(id)initWithDownloadUrl:(NSString *)url
{
	return [self initWithDownloadUrl:url andLocalPath:defaultDownloadPath];
}

-(id)initWithDownloadUrl:(NSString *)url andLocalPath:(NSString *)path
{
	return [self initWithDownloadUrl:url andLocalPath:path fromRoot:YES];
}

-(id)initWithDownloadUrl:(NSString *)url andLocalPath:(NSString *)path fromRoot:(BOOL)root
{
	self = [super init];
	if (self) {
		downloadAttempts = 0;
		downloadUrl = url;
		if (![CMSUtils isTesting]) downloadUrl = [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		
		downloadUrl = [self cleanString:downloadUrl];
        
        localPath = path;
        
        if (!root)
            [FileUtils makeDirectory:[FileUtils newPath:path]];
        
		requestUrl = [NSURL URLWithString:downloadUrl];
		fileName = [requestUrl lastPathComponent];
		assetHasDownloaded = NO;
		userCredentials = YES;
	}
	return self;
}

-(id)initWithDownload:(Download *)download
{
	self = [super init];
	if (self) {
		downloadAttempts = 0;
		downloadUrl = [download downloadUrl];
		if (![CMSUtils isTesting]) downloadUrl = [[download downloadUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		downloadUrl = [self cleanString:downloadUrl];
		
		localPath = defaultDownloadPath;
		[FileUtils makeDirectory:[FileUtils newPath:localPath]];
		requestUrl = [NSURL URLWithString:downloadUrl];
		fileName = [requestUrl lastPathComponent];
		assetHasDownloaded = NO;
		currentDownload = download;
		userCredentials = YES;
	}
	return self;
}

-(NSString *)cleanString:(NSString *)str
{
	NSData *d = [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	return [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
}

-(void)download
{
	if ([[NetworkManager sharedInstance] status] == NetworkManagerStatusNone) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: NSLocalizedString(@"AssetDownloadManagerErrorDownloadingAlertTitle", NULL)
							  message: NSLocalizedString(@"AssetDownloadManagerErrorDownloadingAlertMessage", NULL)
							  delegate: nil
							  cancelButtonTitle:NSLocalizedString(@"AssetDownloadManagerErrorDownloadingAlertOkButton", NULL)
							  otherButtonTitles:nil];
		[alert show];
	}
	
	[self setProgressPercentage:[NSNumber numberWithInt:0]];
	if (!currentDownload) currentDownload = [CoreDataHandler createDownloadedAssetFrom:downloadUrl to:localPath];
	
	BOOL shouldAssetDownload = YES;
	
	if ([FileUtils isFile:fileName]) {
		[currentDownload setFile:fileName];
	} else {
		CLS_LOG(@"URL does not link to a file.");
		shouldAssetDownload = NO;
	}
	__block AssetDownload *safeSelf = self;
	
	BOOL pathAvailable = [FileUtils makeDirectory:[FileUtils newPath:localPath]];
	
	if (pathAvailable) {
		if (shouldAssetDownload) {
			NSURL *url = NULL;
			// ADD USER CREDENTIALS TO URL:
			if (userCredentials) {
				NSString *urlString = [CMSUtils url:downloadUrl withArguments:[CMSUtils dictionaryForLoginDetails]];
				url = [NSURL URLWithString:urlString];
			} else {
				url = [NSURL URLWithString:downloadUrl];
			}
			//
			NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
			operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:[FileUtils newPath:localPath] shouldResume:YES];
			[operation setShouldOverwrite:YES];
			[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
				[safeSelf downloadComplete];
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				CLS_LOG(@"**** ERROR: %@ ****", error);
				[safeSelf downloadFailed];
			}];
			[operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
				double br = (double)totalBytesRead;
				double tb = (double)totalBytesExpectedToRead;
				double percent = (br/tb);
				[safeSelf setProgressPercentage:[NSNumber numberWithDouble:percent]];
			}];
			[operation start];
		} else {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			if (currentDownload) {
				[CoreDataHandler removeDownloadWithDownload:currentDownload];
			}
			
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"AssetDownloadManagerErrorDownloadingAlertMessage", NULL)
								  message:nil
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			
			assetHasDownloaded = NO;
			if ([[self delegate] respondsToSelector:@selector(assetDownloadFailed)]) [[self delegate] assetDownloadFailed];
		}
	} else {
		[self downloadFailed];
	}
}

-(void)setProgressPercentage:(NSNumber *)percent
{
	progressPercentage = percent;
	if ([[self delegate]  respondsToSelector:@selector(downloadDidUpdateWithPercent:)]) {
		[[self delegate] downloadDidUpdateWithPercent:[progressPercentage floatValue]];
	}
}

-(void)cancelDownload:(BOOL)quietly
{
    cancelRequest = quietly;
	if (operation) [operation cancel];
}

-(void)downloadComplete
{
	[self setProgressPercentage:[NSNumber numberWithInt:100]];
	if (currentDownload) [currentDownload setDownloaded:[NSNumber numberWithBool:YES]];
    [CoreDataHandler commit];
	assetHasDownloaded = YES;
	[FileUtils addSkipBackupAttributeToItemAtPath:[currentDownload absolutePathToFile]];
	if ([[self delegate] respondsToSelector:@selector(assetDownloadComplete)]) [[self delegate] assetDownloadComplete];
}

-(void)downloadFailed
{
    if (!cancelRequest) {
        if (downloadAttempts <= 0) {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud removeObjectForKey:@"sessionId"];
            [ud removeObjectForKey:@"sessionName"];
            [ud synchronize];
            
            loginProcess = [[LoginProcess alloc] init];
            [loginProcess setDelegate:self];
            [loginProcess login];
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (currentDownload) [currentDownload setDownloaded:[NSNumber numberWithBool:NO]];
            assetHasDownloaded = NO;
            if ([[self delegate] respondsToSelector:@selector(assetDownloadFailed)]) [[self delegate] assetDownloadFailed];
        }
        
        downloadAttempts++;
    }
}

-(void)userLoggedInWithCredentials:(LoginSessionCredentials *)credentials
{
	[CMSUtils setUserCredentials:credentials];
	[self download];
}

-(void)userLoginFailedFromAutomaticAttempt:(BOOL)automatic
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (currentDownload) [currentDownload setDownloaded:[NSNumber numberWithBool:NO]];
	assetHasDownloaded = NO;
	if ([[self delegate] respondsToSelector:@selector(assetDownloadFailed)]) [[self delegate] assetDownloadFailed];
}

-(BOOL)moveFileToPath:(NSString *)path
{
	BOOL moved = NO;
	NSString *file = [requestUrl lastPathComponent];
	NSString *pathToFile = [FileUtils newPath:[localPath stringByAppendingPathComponent:file]];
	moved = [FileUtils moveFileAtPath:pathToFile toPath:path overwrite:YES];
	
	if (moved) {
		localPath = path;
		NSString *filePathForAsset = [FileUtils newPath:[localPath stringByAppendingPathComponent:fileName]];
		[FileUtils addSkipBackupAttributeToItemAtPath:filePathForAsset];
		if (currentDownload) [currentDownload setLocalPath:localPath];
	}
	
	return moved;
}

-(BOOL)deleteFile
{
	BOOL removed = YES;
	NSError *error = NULL;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *file = [requestUrl lastPathComponent];
	NSString *pathToFile = [FileUtils newPath:[localPath stringByAppendingPathComponent:file]];
	if ([fileManager fileExistsAtPath:pathToFile]) {
		[fileManager removeItemAtPath:pathToFile error:&error];
		if (currentDownload) [[CoreDataHandler context] deleteObject:currentDownload];
	}
	
	if (error) removed = NO;
	
	return removed;
}

-(BOOL)unzipFileWithDelegate:(id <AssetDownloadDelegate>)unzipDelegate
{
	return [self unzipFileTo:localPath withDelegate:unzipDelegate];
}

-(BOOL)unzipFile
{
	return [self unzipFileTo:localPath withDelegate:NULL];
}

-(BOOL)unzipFileTo:(NSString *)path
{
	return [self unzipFileTo:path withDelegate:NULL];
}

-(BOOL)unzipFileTo:(NSString *)path withDelegate:(id <AssetDownloadDelegate>)unzipDelegate
{
	BOOL unzipped = NO;
	unzipCompletionDelegate = unzipDelegate;
	
	NSError *error = NULL;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *file = [requestUrl lastPathComponent];
    NSString *absPath = [FileUtils newPath:path create:YES];
	NSString *pathToFile = [FileUtils newPath:[localPath stringByAppendingPathComponent:file]];
	
	if ([fileManager fileExistsAtPath:pathToFile] && [FileUtils file:file isFileType:@"zip"]) {
        unzipped = [SSZipArchive unzipFileAtPath:pathToFile toDestination:absPath overwrite:YES password:NULL error:&error delegate:self];
		if (error) {
			unzipped = NO;
			CLS_LOG(@"Error: %@", error);
		} else {
			
		}
	}
	
	if (!unzipped && unzipCompletionDelegate) {
		if ([unzipCompletionDelegate respondsToSelector:@selector(assetUnzipFailed)]) [unzipCompletionDelegate assetUnzipFailed];
	}
	
	return unzipped;
}

-(void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
	if (unzipCompletionDelegate) {
		NSArray *fileArray = [FileUtils listFilesAtPath:unzippedPath];
		for (int i=0; i<[fileArray count]; i++) {
			NSString *file = [unzippedPath stringByAppendingPathComponent:(NSString *)[fileArray objectAtIndex:i]];
			[FileUtils addSkipBackupAttributeToItemAtPath:file];
		}
		
		if ([unzipCompletionDelegate respondsToSelector:@selector(assetUnzipComplete)]) [unzipCompletionDelegate assetUnzipComplete];
		unzipCompletionDelegate = NULL;
	}
}

@end
