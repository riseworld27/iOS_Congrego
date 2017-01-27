//
//  JSONHandler.h
//  IgViewer
//
//  Created by matata on 28/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AssetBundles;

@interface JSONHandler : NSObject

@property (nonatomic, retain) NSDictionary *json;
@property (nonatomic, retain) NSString *JSONString;
@property (nonatomic, retain) NSDictionary *bundles;
@property (nonatomic, retain) NSArray *products;

-(id)initWithJSONString:(NSString *)jsonString;
-(void)parseProducts;
-(AssetBundles *)parseBundles;

@end
