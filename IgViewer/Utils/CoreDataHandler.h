//
//  CoreDataHandler.h
//  IgViewer
//
//  Created by matata on 25/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Download, Product, Category, Collection, Asset, AssessmentAnswer, Assessment;

@interface CoreDataHandler : NSObject

+(Download *)createDownloadedAssetFrom:(NSString *)from to:(NSString *)to;
+(Product *)createProductWithTitle:(NSString *)title andImageFile:(NSString *)file;
+(Category *)createCategoryWithTitle:(NSString *)title;
+(Collection *)createCollectionWithTitle:(NSString *)title subTitle:(NSString *)subTitle andIconFile:(NSString *)file;
+(Asset *)createAssetWithTitle:(NSString *)title subTitle:(NSString *)subTitle iconFile:(NSString *)file andUrl:(NSString *)url;
+(void)clearAllDownloads;
+(BOOL)commit;
+(void)emptyEntityWithName:(NSString *)name;
+(void)setContext:(NSManagedObjectContext *)context;
+(NSManagedObjectContext *)context;
+(void)clearDatabasesIncludeAppPopulated:(BOOL)appPopulated;
+(Collection *)newCollection;
+(NSMutableArray *)fetchAllProducts;
+(Download *)fetchDownloadForAsset:(Asset *)asset;
+(Download *)downloadForAsset:(Asset *)asset;
+(NSMutableArray *)fetchAllDownloadsIncludeCompleted:(BOOL)complete andIncomplete:(BOOL)incomplete;
+(NSMutableArray *)fetchAllDownloads;
+(int)numberOfDownloads;
+(NSString *)assetHashFromAsset:(Asset *)asset;
+(NSString *)assetHashFromDictionary:(NSDictionary *)dictionary;
+(Download *)fetchDownloadWithHash:(NSString *)hashValue;
+(NSMutableArray *)fetchProductsWithSearch:(NSString *)search;
+(NSMutableArray *)fetchAllIncompleteDownloads;
+(NSMutableArray *)fetchAssetsWithHash:(NSString *)hashValue;
+(Product *)productWithDictionary:(NSDictionary *)dictionary;
+(Category *)categoryWithDictionary:(NSDictionary *)dictionary;
+(Collection *)collectionWithAsset:(Asset *)asset addAsset:(BOOL)add;
+(Collection *)collectionWithDictionary:(NSDictionary *)dictionary;
+(Asset *)assetWithDictionary:(NSDictionary *)dictionary;
+(NSMutableArray *)fetchAllCollectionsWithSearch:(NSString *)search;
+(BOOL)removeDownloadWithDownload:(Download *)download;
+(BOOL)removeDownloadForAsset:(Asset *)asset;
+(AssessmentAnswer *)addAnswer:(NSString *)answer forQuestionId:(NSString *)questionId inAssessment:(NSString *)assessmentId;
+(AssessmentAnswer *)addAnswerWithDictionary:(NSDictionary *)dictionary;
+(Assessment *)fetchAssessmentForId:(NSString *)assessmentId;
+(Assessment *)addAssessmentWithId:(NSString *)assessmentId;
+(NSMutableArray *)fetchAllAssessments;
+(AssessmentAnswer *)addAnswerWithArray:(NSArray *)array;
+(void)clearAllAssessments;
+(int)numberOfObjectsInEntityWithName:(NSString *)name;

@end
