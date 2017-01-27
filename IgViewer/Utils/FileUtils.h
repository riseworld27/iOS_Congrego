//
//  FileUtils.h
//  IgViewer
//
//  Created by matata on 25/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

+(BOOL)makeDirectory:(NSString *)path;
+(NSString *)userPath;
+(NSString *)newPath:(NSString *)path fromRoot:(NSString *)root;
+(NSString *)newPath:(NSString *)path;
+(BOOL)isFile:(NSString *)file;
+(NSArray *)listFilesAtPath:(NSString *)path andLog:(BOOL)log;
+(NSString *)fileType:(NSString *)file;
+(BOOL)file:(NSString *)file isFileType:(NSString *)type;
+(NSString *)newPath:(NSString *)path create:(BOOL)create;
+(NSString *)newPath:(NSString *)path fromRoot:(NSString *)root create:(BOOL)create;
+(NSArray *)listFilesAtPath:(NSString *)path;
+(BOOL)moveFileAtPath:(NSString *)filePath toPath:(NSString *)path overwrite:(BOOL)overwrite;
+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path;

@end
