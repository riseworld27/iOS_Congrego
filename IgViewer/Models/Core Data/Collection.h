//
//  Collection.h
//  IgViewer
//
//  Created by matata on 01/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Asset, Category;

@interface Collection : NSManagedObject

@property (nonatomic, retain) NSString * cmsId;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * iconFile;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *assets;
@property (nonatomic, retain) Category *categories;
@end

@interface Collection (CoreDataGeneratedAccessors)

- (void)addAssetsObject:(Asset *)value;
- (void)removeAssetsObject:(Asset *)value;
- (void)addAssets:(NSSet *)values;
- (void)removeAssets:(NSSet *)values;

@end
