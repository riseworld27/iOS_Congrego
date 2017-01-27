//
//  JSONHandler.m
//  IgViewer
//
//  Created by matata on 28/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "JSONHandler.h"
#import "CoreDataHandler.h"
#import "Download.h"
#import "Product.h"
#import "Category.h"
#import "Asset.h"
#import "Collection.h"
#import "AssetBundles.h"

static JSONHandler *sharedInstance;

@implementation JSONHandler

@synthesize json, JSONString, bundles, products;

-(id)initWithJSONString:(NSString *)jsonString
{
	self = [super init];
	if (self) {
		JSONString = jsonString;
		sharedInstance = self;
		NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
		NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
		json = (NSDictionary *)[jsonArray objectAtIndex:0];
		bundles = (NSDictionary *)[json objectForKey:@"bundles"];
		products = (NSArray *)[json objectForKey:@"products"];
	}
	return self;
}

-(void)parseProducts
{
	if (products) {
		CLS_LOG(@"Reading products in to Core Data...");
		for (int p=0; p<[products count]; p++) {
			NSDictionary *productDictionary = (NSDictionary *)[products objectAtIndex:p];
			Product *product = [CoreDataHandler productWithDictionary:productDictionary];
			[product setOrderId:[NSNumber numberWithInt:p]];
			
			NSArray *categories = [productDictionary objectForKey:@"categories"];
			for (int c=0; c<[categories count]; c++) {
				NSDictionary *categoryDictionary = (NSDictionary *)[categories objectAtIndex:c];
				Category *category = [CoreDataHandler categoryWithDictionary:categoryDictionary];
				
				NSArray *collections = [categoryDictionary objectForKey:@"assets"];
				for (int d=0; d<[collections count]; d++) {
					NSDictionary *collectionDictionary = (NSDictionary *)[collections objectAtIndex:d];
					Collection *collection = NULL;
					
					if ([collectionDictionary objectForKey:@"isCollection"]) {
						//CLS_LOG(@"Is a collection");
						collection = [CoreDataHandler collectionWithDictionary:collectionDictionary];
						NSArray *collectionAssetsArray = [collectionDictionary objectForKey:@"assets"];
						for (int a=0; a<[collectionAssetsArray count]; a++) {
							NSDictionary *assetDictionary = (NSDictionary *)[collectionAssetsArray objectAtIndex:a];
							Asset *asset = [CoreDataHandler assetWithDictionary:assetDictionary];
							[collection addAssetsObject:asset];
						}
					} else {
                        NSMutableDictionary *assetDictionary = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[collections objectAtIndex:d]];
                        if ([assetDictionary objectForKey:@"assetType"] == [NSNull null])
                        {
                            [assetDictionary setObject:[NSNumber numberWithInt:5] forKey:@"assetType"];
                        }
						Asset *asset = [CoreDataHandler assetWithDictionary:assetDictionary];
						collection = [CoreDataHandler collectionWithAsset:asset addAsset:YES];
						//CLS_LOG(@"Is a singular asset: %@", [asset title]);
					}
					
					if (collection) [category addCollectionsObject:collection];
				}
				
				[product addCategoriesObject:category];
			}
		}
		[CoreDataHandler commit];
	}
}

-(AssetBundles *)parseBundles
{
	AssetBundles *assetBundles = [[AssetBundles alloc] init];
	
	if (bundles) {
		if ([bundles objectForKey:@"icons"]) {
			NSDictionary *iconBundle = (NSDictionary *)[bundles objectForKey:@"icons"];
			NSString *bundleUrl = (NSString *)[iconBundle objectForKey:@"bundleUrl"];
			if (bundleUrl && ![bundleUrl isEqualToString:@""]) [assetBundles setIconBundleUrl:bundleUrl];
		}
		if ([bundles objectForKey:@"products"]) {
			NSDictionary *productsBundle = (NSDictionary *)[bundles objectForKey:@"products"];
			NSString *bundleUrl = (NSString *)[productsBundle objectForKey:@"bundleUrl"];
			if (bundleUrl && ![bundleUrl isEqualToString:@""]) [assetBundles setProductImageBundle:bundleUrl];
		}
		if ([bundles objectForKey:@"webResources"]) {
			NSDictionary *webBundle = (NSDictionary *)[bundles objectForKey:@"products"];
			NSString *bundleUrl = (NSString *)[webBundle objectForKey:@"bundleUrl"];
			if (bundleUrl && ![bundleUrl isEqualToString:@""]) [assetBundles setWebResourcesBundle:bundleUrl];
		}
	}
	
	return assetBundles;
}

@end
