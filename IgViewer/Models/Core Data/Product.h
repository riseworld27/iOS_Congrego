//
//  Product.h
//  IgViewer
//
//  Created by matata on 01/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * cmsId;
@property (nonatomic, retain) NSString * imageFile;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSNumber *orderId;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
