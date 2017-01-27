//
//  Category.h
//  IgViewer
//
//  Created by matata on 01/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Collection, Product;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * cmsId;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *collections;
@property (nonatomic, retain) Product *products;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addCollectionsObject:(Collection *)value;
- (void)removeCollectionsObject:(Collection *)value;
- (void)addCollections:(NSSet *)values;
- (void)removeCollections:(NSSet *)values;

@end
