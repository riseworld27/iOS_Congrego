//
//  Asset.h
//  IgViewer
//
//  Created by matata on 01/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Collection, Download;

@interface Asset : NSManagedObject

@property (nonatomic, retain) NSString * assetDetails;
@property (nonatomic, retain) NSNumber * assetEnabled;
@property (nonatomic, retain) NSNumber * emailable;
@property (nonatomic, retain) NSString * assetFormat;
@property (nonatomic, retain) NSString * assetSize;
@property (nonatomic, retain) NSNumber * assetType;
@property (nonatomic, retain) NSString * assetUrl;
@property (nonatomic, retain) NSString * cmsId;
@property (nonatomic, retain) NSString * downloadApp;
@property (nonatomic, retain) NSString * iconFile;
@property (nonatomic, retain) NSString * installedApp;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * assetHash;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) Collection *collections;
@property (nonatomic, retain) Download *download;

-(BOOL)isEqualToAsset:(Asset *)asset;
-(NSString *)captionForButton;
-(BOOL) isDownloadCancelable;

@end
