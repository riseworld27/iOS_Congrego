//
//  Download.m
//  IgViewer
//
//  Created by matata on 04/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "Download.h"
#import "Asset.h"
#import "AssetDownload.h"
#import "FileUtils.h"

@implementation Download

@dynamic downloaded;
@dynamic downloadHash;
@dynamic downloadUrl;
@dynamic file;
@dynamic isDownloading;
@dynamic localPath;
@dynamic queueDate;
@dynamic assets;
@dynamic fileType;
@dynamic downloadDate;

-(BOOL)isEqualToDownload:(Download *)download
{
	return [[download downloadHash] isEqualToString:[self downloadHash]];
}

-(BOOL)isRecognisedType
{
	BOOL recognised = NO;
	
	if ([[self fileType] intValue] == AssetFileTypePdf) recognised = YES;
	if ([[self fileType] intValue] == AssetFileTypeVideo) recognised = YES;
	if ([[self fileType] intValue] == AssetFileTypeImage) recognised = YES;
	if ([[self fileType] intValue] == AssetFileTypeAudio) recognised = YES;
    if ([[self fileType] intValue] == AssetFileTypeHtml) recognised = YES;
    if ([[self fileType] intValue] == AssetFileTypeWordDoc) recognised = YES;
	
	return recognised;
}

- (NSString *)absolutePath
{
    return [FileUtils newPath:self.localPath];
}

- (NSString *)absolutePathToFile
{
    return [FileUtils newPath:[self.localPath stringByAppendingPathComponent:self.file]];
}


@end
