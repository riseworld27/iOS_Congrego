//
//  FileUtils.m
//  IgViewer
//
//  Created by matata on 25/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "FileUtils.h"
#include <sys/xattr.h>

@implementation FileUtils

+(BOOL)makeDirectory:(NSString *)path
{
	BOOL wasCreated = NO;
	
	NSError *error = NULL;
	BOOL isDirectory;
	
	NSFileManager *manager = [[NSFileManager alloc] init];
	if (![manager fileExistsAtPath:path isDirectory:&isDirectory]) {
		if ([manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:NULL error:&error]) {
			wasCreated = YES;
		}
	} else {
		wasCreated = YES;
	}
	
	if (!isDirectory && wasCreated) CLS_LOG(@"FileUtils:makeDirectory - %@ not a directory", path);
	
	return wasCreated;
}

+(NSArray *)listFilesAtPath:(NSString *)path andLog:(BOOL)log
{
	NSFileManager *manager = [[NSFileManager alloc] init];
	
	NSArray *fileList = [manager contentsOfDirectoryAtPath:path error:nil];
	if (log) {
		CLS_LOG(@"-------------------------------------------");
		CLS_LOG(@"Contents of %@:", path);
		for (int i=0; i<[fileList count]; i++) {
			NSString *fileName = (NSString *)[fileList objectAtIndex:i];
			if (![fileName hasPrefix:@"__"] && ![fileName hasPrefix:@"."]) {
				CLS_LOG(@"File: %@", [fileList objectAtIndex:i]);
			}
		}
		CLS_LOG(@"-------------------------------------------");
	}
	
	return fileList;
}

+(NSArray *)listFilesAtPath:(NSString *)path
{
	return [self listFilesAtPath:path andLog:NO];
}

+(NSString *)userPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+(NSString *)newPath:(NSString *)path
{
	return [FileUtils newPath:path fromRoot:[FileUtils userPath]];
}

+(NSString *)newPath:(NSString *)path fromRoot:(NSString *)root
{
	return [root stringByAppendingPathComponent:path];
}

+(NSString *)newPath:(NSString *)path create:(BOOL)create
{
	NSString *newPath = [FileUtils newPath:path];
	if (create) [FileUtils makeDirectory:newPath];
	return newPath;
}

+(NSString *)newPath:(NSString *)path fromRoot:(NSString *)root create:(BOOL)create
{
	NSString *newPath = [FileUtils newPath:path fromRoot:root];
	if (create) [FileUtils makeDirectory:newPath];
	return newPath;
}

+(BOOL)isFile:(NSString *)file
{
	BOOL isFile = NO;
	NSArray *fileComponantsArray = [file componentsSeparatedByString:@"."];
	if ([fileComponantsArray count] == 2) isFile = YES;
	
	return isFile;
}

+(NSString *)fileType:(NSString *)file
{
	NSString *fileType = NULL;
	
	if ([FileUtils isFile:file]) {
		NSArray *fileComponantsArray = [file componentsSeparatedByString:@"."];
		NSString *extension = (NSString *)[fileComponantsArray objectAtIndex:1];
		fileType = [extension uppercaseString];
	} else {
		CLS_LOG(@"%@ is not a file.", file);
	}
	
	return fileType;
}

+(BOOL)file:(NSString *)file isFileType:(NSString *)type
{
	BOOL fileIsType = NO;
	NSString *fileType = [FileUtils fileType:file];
	if ([[type uppercaseString] isEqualToString:fileType]) fileIsType = YES;
	
	return fileIsType;
}

+(BOOL)moveFileAtPath:(NSString *)filePath toPath:(NSString *)path overwrite:(BOOL)overwrite
{
	BOOL moved = NO;
	NSError *error = NULL;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *file = [filePath lastPathComponent];
	NSString *newPathToFile = [FileUtils newPath:[path stringByAppendingPathComponent:file]];
	
	[FileUtils makeDirectory:[FileUtils newPath:path]];
	
	if (overwrite) {
		if ([fileManager fileExistsAtPath:newPathToFile]) {
			[fileManager removeItemAtPath:newPathToFile error:NULL];
		}
	}
	
	if ([fileManager fileExistsAtPath:filePath]) {
		moved = [fileManager moveItemAtPath:filePath toPath:newPathToFile error:&error];
		[FileUtils addSkipBackupAttributeToItemAtPath:newPathToFile];
		if (error) moved = NO;
	}
	
	return moved;
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path
{
	NSURL *url = [NSURL fileURLWithPath:path];
	
    NSError *error = nil;
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        CLS_LOG(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    } else {
		//CLS_LOG(@"Excluded file: %@ from backup", [url path]);
	}
    return success;
}

@end
