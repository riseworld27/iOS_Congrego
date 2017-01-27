//
//  Download.h
//  IgViewer
//
//  Created by matata on 04/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Asset;

@interface Download : NSManagedObject

@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) NSString * downloadHash;
@property (nonatomic, retain) NSString * downloadUrl;
@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) NSNumber * isDownloading;
@property (nonatomic, retain) NSString * localPath;
@property (nonatomic, retain) NSDate * queueDate;
@property (nonatomic, retain) NSDate * downloadDate;
@property (nonatomic, retain) NSSet *assets;
@property (nonatomic, retain) NSNumber *fileType;
@end

@interface Download (CoreDataGeneratedAccessors)

- (void)addAssetsObject:(Asset *)value;
- (void)removeAssetsObject:(Asset *)value;
- (void)addAssets:(NSSet *)values;
- (void)removeAssets:(NSSet *)values;

-(BOOL)isEqualToDownload:(Download *)download;
-(BOOL)isRecognisedType;

-(NSString *)absolutePath;
-(NSString *)absolutePathToFile;

@end
