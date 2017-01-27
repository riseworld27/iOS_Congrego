//
//  AssetDownload.h
//  IgViewer
//
//  Created by matata on 27/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipArchive.h"
#import "LoginProcess.h"

typedef NS_ENUM(NSInteger, AssetFileType) {
    AssetFileTypePdf,
    AssetFileTypeVideo,
	AssetFileTypeHtml,
	AssetFileTypeAudio,
	AssetFileTypeImage,
    AssetFileTypeWordDoc
};

@class AFDownloadRequestOperation, Download, LoginProcess;

@protocol AssetDownloadDelegate <NSObject>

@optional
-(void)assetDownloadComplete;
-(void)assetDownloadFailed;
-(void)assetUnzipComplete;
-(void)assetUnzipFailed;
-(void)downloadDidUpdateWithPercent:(float)percent;

@end

@interface AssetDownload : NSObject <SSZipArchiveDelegate, LoginProcessDelegate>
{
	AFDownloadRequestOperation *operation;
	NSURL *requestUrl;
	int downloadAttempts;
	LoginProcess *loginProcess;
	 id <AssetDownloadDelegate> unzipCompletionDelegate;
    BOOL cancelRequest;
}

@property (nonatomic, retain) NSString *downloadUrl;
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) id <AssetDownloadDelegate> delegate;
@property (nonatomic) BOOL assetHasDownloaded;
@property (nonatomic, retain) NSString *unzipDirectory;
@property (nonatomic, retain) NSNumber *progressPercentage;
@property (nonatomic, retain) Download *currentDownload;
@property (nonatomic) BOOL userCredentials;

-(id)initWithDownloadUrl:(NSString *)url;
-(id)initWithDownloadUrl:(NSString *)url andLocalPath:(NSString *)path;
-(id)initWithDownloadUrl:(NSString *)url andLocalPath:(NSString *)path fromRoot:(BOOL)root;
-(id)initWithDownload:(Download *)download;
-(void)download;
-(BOOL)moveFileToPath:(NSString *)path;
-(BOOL)deleteFile;
-(BOOL)unzipFileTo:(NSString *)path withDelegate:(id <AssetDownloadDelegate>)unzipDelegate;
-(BOOL)unzipFile;
-(BOOL)unzipFileTo:(NSString *)path;
-(BOOL)unzipFileWithDelegate:(id <AssetDownloadDelegate>)unzipDelegate;
-(void)cancelDownload:(BOOL)quietly;

@end
