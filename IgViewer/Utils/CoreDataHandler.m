//
//  CoreDataHandler.m
//  IgViewer
//
//  Created by matata on 25/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "CoreDataHandler.h"
#import "Download.h"
#import "Product.h"
#import "Category.h"
#import "Asset.h"
#import "Collection.h"
#import "AssessmentAnswer.h"
#import "Assessment.h"

@implementation CoreDataHandler

static NSManagedObjectContext *managedObjectContext;

+(void)setContext:(NSManagedObjectContext *)context
{
	managedObjectContext = context;
}

+(NSManagedObjectContext *)context
{
	return managedObjectContext;
}

+(void)emptyEntityWithName:(NSString *)name
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:managedObjectContext];
	
	if (entity) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:entity];
		[request setIncludesPropertyValues:NO];
		
		NSError *error;
		NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
		
		if (mutableFetchResults) {
			for (id result in mutableFetchResults) {
				[managedObjectContext deleteObject:result];
			}
			[self commit];
		} else {
			CLS_LOG(@"Could not reset database, or database is empty.");
		}
	}
}

+(int)numberOfObjectsInEntityWithName:(NSString *)name
{
	NSMutableArray *mutableFetchResults = [[NSMutableArray alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
	[request setIncludesPropertyValues:NO];
	
	NSError *error;
	mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	return (int) [mutableFetchResults count];
}

+(void)clearAllAssessments
{
	[CoreDataHandler emptyEntityWithName:@"Assessment"];
}

+(BOOL)commit
{
	BOOL committed = YES;
	NSError *error;
	
	if (![managedObjectContext save:&error]) {
		CLS_LOG(@"Couldn't save: %@", [error localizedDescription]);
		committed = NO;
	}
	
	return committed;
}

+(void)clearAllDownloads
{
	[CoreDataHandler emptyEntityWithName:@"Download"];
}

+(void)clearDatabasesIncludeAppPopulated:(BOOL)appPopulated
{
	[CoreDataHandler emptyEntityWithName:@"Product"];
	[CoreDataHandler emptyEntityWithName:@"Category"];
	[CoreDataHandler emptyEntityWithName:@"Collection"];
	[CoreDataHandler emptyEntityWithName:@"Asset"];
	if (appPopulated) {
		[CoreDataHandler clearAllAssessments];
		[CoreDataHandler clearAllDownloads];
	}
}

+(NSMutableArray *)fetchAllProducts
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	/*NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(enabled == %i) && (numberOnly == %i)", YES, NO];
	[request setPredicate:predicate];*/
	
	//NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES];
	NSMutableArray *displayNameDescriptors = [NSMutableArray arrayWithObject:sorting];
	[request setSortDescriptors:displayNameDescriptors];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (error) {
		CLS_LOG(@"Error fetching contacts");
	}
	
	return mutableFetchResults;
}

+(NSMutableArray *)fetchProductsWithSearch:(NSString *)search
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS [c]%@)", search, search];
	 [request setPredicate:predicate];
	
	NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSMutableArray *displayNameDescriptors = [NSMutableArray arrayWithObject:sorting];
	[request setSortDescriptors:displayNameDescriptors];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (error) {
		CLS_LOG(@"Error fetching contacts");
	}
	
	return mutableFetchResults;
}

+(Download *)createDownloadedAssetFrom:(NSString *)from to:(NSString *)to
{
	Download *download = NULL;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(downloadUrl == %@) && (localPath == %@)", from, to];
	[request setPredicate:predicate];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if ([mutableFetchResults count] > 0) {
		if ([mutableFetchResults count] > 1) CLS_LOG(@"Strangely, there was more than one Download result fetched, we'll use the first one.");
		download = (Download *)[mutableFetchResults objectAtIndex:0];
	} else {
		download = [NSEntityDescription insertNewObjectForEntityForName:@"Download" inManagedObjectContext:[CoreDataHandler context]];
		[download setDownloadUrl:from];
		[download setLocalPath:to];
	}
	
	return download;
}

+(Product *)createProductWithTitle:(NSString *)title andImageFile:(NSString *)file
{
	Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:[CoreDataHandler context]];
	[product setTitle:title];
	[product setImageFile:file];
	return product;
}

+(Category *)createCategoryWithTitle:(NSString *)title
{
	Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[CoreDataHandler context]];
	[category setTitle:title];
	return category;
}

+(Collection *)createCollectionWithTitle:(NSString *)title subTitle:(NSString *)subTitle andIconFile:(NSString *)file
{
	Collection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:[CoreDataHandler context]];
	[collection setTitle:title];
	[collection setSubTitle:subTitle];
	[collection setIconFile:file];
	return collection;
}

+(Asset *)createAssetWithTitle:(NSString *)title subTitle:(NSString *)subTitle iconFile:(NSString *)file andUrl:(NSString *)url
{
	Asset *asset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:[CoreDataHandler context]];
	[asset setTitle:title];
	[asset setSubTitle:title];
	[asset setIconFile:file];
	[asset setAssetUrl:url];
	return asset;
}

+(Collection *)newCollection
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:[CoreDataHandler context]];
}

+(Product *)productWithDictionary:(NSDictionary *)dictionary
{
	Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:[CoreDataHandler context]];
	if ([dictionary objectForKey:@"title"]) [product setTitle:[dictionary objectForKey:@"title"]];
	if ([dictionary objectForKey:@"imagefile"]) [product setImageFile:[dictionary objectForKey:@"imagefile"]];
	if ([dictionary objectForKey:@"id"]) [product setCmsId:[dictionary objectForKey:@"id"]];
	/*if ([dictionary objectForKey:@"updated"]) {
		NSString *epochString = [dictionary objectForKey:@"updated"];
		if ([epochString intValue] > 0) {
			int epoch = [epochString intValue];
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:epoch];
			[product setUpdated:date];
		}
	}*/
	return product;
}

+(Category *)categoryWithDictionary:(NSDictionary *)dictionary
{
	Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[CoreDataHandler context]];
	if ([dictionary objectForKey:@"title"]) [category setTitle:[dictionary objectForKey:@"title"]];
	if ([dictionary objectForKey:@"id"]) [category setCmsId:[dictionary objectForKey:@"id"]];
	/*if ([dictionary objectForKey:@"updated"]) {
		 NSString *epochString = [dictionary objectForKey:@"updated"];
		 if ([epochString intValue] > 0) {
			 int epoch = [epochString intValue];
			 NSDate *date = [NSDate dateWithTimeIntervalSince1970:epoch];
			 [category setUpdated:date];
		 }
	 }*/
	
	return category;
}

+(Collection *)collectionWithDictionary:(NSDictionary *)dictionary
{
	Collection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:[CoreDataHandler context]];
	if ([dictionary objectForKey:@"iconFile"]) [collection setIconFile:[dictionary objectForKey:@"iconFile"]];
	if ([dictionary objectForKey:@"title"]) [collection setTitle:[dictionary objectForKey:@"title"]];
	if ([dictionary objectForKey:@"subTitle"]) [collection setSubTitle:[dictionary objectForKey:@"subTitle"]];
	
	return collection;
}

+(Collection *)collectionWithAsset:(Asset *)asset addAsset:(BOOL)add
{
	Collection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:[CoreDataHandler context]];
	if ([asset iconFile]) [collection setIconFile:[NSString stringWithString:asset.iconFile]];
	if ([asset title]) [collection setTitle:[NSString stringWithString:asset.title]];
	if ([asset subTitle]) [collection setSubTitle:[NSString stringWithString:asset.subTitle]];
	
	if (add) [collection addAssetsObject:asset];
	
	return collection;
}

+(Asset *)assetWithDictionary:(NSDictionary *)dictionary
{
	Asset *asset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:[CoreDataHandler context]];
	if ([dictionary objectForKey:@"id"]) [asset setCmsId:[dictionary objectForKey:@"id"]];
	if ([dictionary objectForKey:@"iconFile"]) [asset setIconFile:[dictionary objectForKey:@"iconFile"]];
	if ([dictionary objectForKey:@"assetUrl"]) [asset setAssetUrl:[dictionary objectForKey:@"assetUrl"]];
	if ([dictionary objectForKey:@"title"]) [asset setTitle:[dictionary objectForKey:@"title"]];
	if ([dictionary objectForKey:@"subTitle"]) [asset setSubTitle:[dictionary objectForKey:@"subTitle"]];
	if ([dictionary objectForKey:@"assetType"]) [asset setAssetType:[dictionary objectForKey:@"assetType"]];
	if ([dictionary objectForKey:@"enabled"]) {
		BOOL assetEnabled = [[dictionary objectForKey:@"enabled"] boolValue];
		[asset setAssetEnabled:[NSNumber numberWithBool:assetEnabled]];
    }
    if ([dictionary objectForKey:@"emailable"]) {
        BOOL assetEmailable = [[dictionary objectForKey:@"emailable"] boolValue];
        [asset setEmailable:[NSNumber numberWithBool:assetEmailable]];
    }
	if ([dictionary objectForKey:@"assetSize"]) [asset setAssetSize:[dictionary objectForKey:@"assetSize"]];
	if ([dictionary objectForKey:@"assetFormat"]) [asset setAssetFormat:[dictionary objectForKey:@"assetFormat"]];
	if ([dictionary objectForKey:@"assetDetails"]) [asset setAssetDetails:[dictionary objectForKey:@"assetDetails"]];
	if ([dictionary objectForKey:@"updated"]) {
		NSString *epochString = [dictionary objectForKey:@"updated"];
		if ([epochString intValue] > 0) {
			int epoch = [epochString intValue];
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:epoch];
			[asset setUpdated:date];
		}
	}
    if ([dictionary objectForKey:@"installedApp"]) [asset setInstalledApp:[dictionary objectForKey:@"installedApp"]];
    if ([dictionary objectForKey:@"downloadApp"]) [asset setDownloadApp:[dictionary objectForKey:@"downloadApp"]];
	
	/*NSString *compoundString = [NSString stringWithFormat:@"%@%@%@%@%@", [asset iconFile], [asset assetUrl], [asset assetFormat], [[asset assetType] stringValue], [asset assetSize]];
	NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"[^0-9A-Za-z]" options:NSRegularExpressionCaseInsensitive error:NULL];
	NSString *hashValue = [regEx stringByReplacingMatchesInString:compoundString options:0 range:NSMakeRange(0, [compoundString length]) withTemplate:@""];*/
	[asset setAssetHash:[CoreDataHandler assetHashFromAsset:asset]];
	
	return asset;
}

+(NSString *)assetHashFromDictionary:(NSDictionary *)dictionary
{
	NSString *iconFile = [dictionary objectForKey:@"iconFile"];
	NSString *assetUrl = [dictionary objectForKey:@"assetUrl"];
	NSString *assetFormat = [dictionary objectForKey:@"assetFormat"];
	NSString *assetType = [[dictionary objectForKey:@"assetType"] stringValue];
	NSString *assetSize = [dictionary objectForKey:@"assetSize"];
	
	NSString *compoundString = [NSString stringWithFormat:@"%@%@%@%@%@", iconFile, assetUrl, assetFormat, assetType, assetSize];
	NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"[^0-9A-Za-z]" options:NSRegularExpressionCaseInsensitive error:NULL];
	NSString *hashValue = [regEx stringByReplacingMatchesInString:compoundString options:0 range:NSMakeRange(0, [compoundString length]) withTemplate:@""];
	
	return hashValue;
}

+(NSString *)assetHashFromAsset:(Asset *)asset
{
	NSString *compoundString = [NSString stringWithFormat:@"%@%@%@%@%@", [asset iconFile], [asset assetUrl], [asset assetFormat], [[asset assetType] stringValue], [asset assetSize]];
	NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"[^0-9A-Za-z]" options:NSRegularExpressionCaseInsensitive error:NULL];
	NSString *hashValue = [regEx stringByReplacingMatchesInString:compoundString options:0 range:NSMakeRange(0, [compoundString length]) withTemplate:@""];
	
	return hashValue;
}

+(NSMutableArray *)fetchAllDownloadsIncludeCompleted:(BOOL)complete andIncomplete:(BOOL)incomplete
{
	NSMutableArray *mutableFetchResults = [NSMutableArray array];
	
	if (complete || incomplete) {
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:[CoreDataHandler context]];
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(downloaded == %i) OR (downloaded == %i)", complete, !incomplete];
		[request setPredicate:predicate];
		
		NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"queueDate" ascending:YES];
		NSArray *displayNameDescriptors = [NSArray arrayWithObject:sorting];
		[request setSortDescriptors:displayNameDescriptors];
		
		NSError *error;
		mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
		
		if (error) {
			CLS_LOG(@"Error fetching contacts");
		}
	}
	
	return mutableFetchResults;
}

+(NSMutableArray *)fetchAllIncompleteDownloads
{
	NSMutableArray *mutableFetchResults = [NSMutableArray array];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(downloaded == %i)", 0];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"queueDate" ascending:YES];
	NSArray *displayNameDescriptors = [NSArray arrayWithObject:sorting];
	[request setSortDescriptors:displayNameDescriptors];
	
	NSError *error;
	mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (error) {
		CLS_LOG(@"Error fetching contacts");
	}

	return mutableFetchResults;
}

+(NSMutableArray *)fetchAllDownloads
{
	NSMutableArray *mutableFetchResults = [NSMutableArray array];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:[CoreDataHandler context]];
		
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
		
	NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"queueDate" ascending:YES];
	NSArray *displayNameDescriptors = [NSArray arrayWithObject:sorting];
	[request setSortDescriptors:displayNameDescriptors];
		
	NSError *error;
	mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

	if (error) {
		CLS_LOG(@"Error fetching contacts");
	}
	
	return mutableFetchResults;
}

+(Download *)fetchDownloadForAsset:(Asset *)asset
{
	Download *download = NULL;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(downloadHash == %@)", [asset assetHash]];
	 [request setPredicate:predicate];
	
	NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"queueDate" ascending:YES];
	NSArray *displayNameDescriptors = [NSArray arrayWithObject:sorting];
	[request setSortDescriptors:displayNameDescriptors];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (error) {
		CLS_LOG(@"Error fetching contacts");
	}
	
	if ([mutableFetchResults count] > 0) {
		download = (Download *)[mutableFetchResults objectAtIndex:0];
		if ([mutableFetchResults count] > 1) CLS_LOG(@"Odly there was more than one matching download for Asset: %@, well use the first one.", [asset title]);
	}
	
	return download;
}

+(Download *)fetchDownloadWithHash:(NSString *)hashValue
{
	Download *download = NULL;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Download" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(downloadHash == %@)", hashValue];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"queueDate" ascending:YES];
	NSArray *displayNameDescriptors = [NSArray arrayWithObject:sorting];
	[request setSortDescriptors:displayNameDescriptors];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (error) {
		CLS_LOG(@"Error fetching contacts");
	}
	
	if ([mutableFetchResults count] > 0) {
		download = (Download *)[mutableFetchResults objectAtIndex:0];
		if ([mutableFetchResults count] > 1) CLS_LOG(@"Odly there was more than one matching download for Hash: %@, well use the first one.", hashValue);
	}
	
	return download;
}

+(NSMutableArray *)fetchAssetsWithHash:(NSString *)hashValue
{
	NSMutableArray *mutableFetchResults = [[NSMutableArray alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Asset" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(assetHash == %@)", hashValue];
	[request setPredicate:predicate];
	
	NSError *error;
	mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (error) {
		CLS_LOG(@"Error fetching assets with hash: %@", hashValue);
	}
	
	return mutableFetchResults;
}

+(Download *)downloadForAsset:(Asset *)asset
{
	Download *download = [CoreDataHandler fetchDownloadForAsset:asset];
	if (!download) {
		download = [NSEntityDescription insertNewObjectForEntityForName:@"Download" inManagedObjectContext:[CoreDataHandler context]];
		[download setDownloadHash:[NSString stringWithString:[asset assetHash]]];
		[download setDownloadUrl:[NSString stringWithString:[asset assetUrl]]];
		[download setQueueDate:[NSDate date]];
		[download setFileType:[NSNumber numberWithInt:[[asset assetType] intValue]]];
	}
	[download addAssetsObject:asset];
	[asset setDownload:download];
	[CoreDataHandler commit];
	
	return download;
}

+(NSMutableArray *)fetchAllCollectionsWithSearch:(NSString *)search
{
	NSMutableArray *mutableFetchResults = [[NSMutableArray alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Collection" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY assets.title CONTAINS [c]%@) OR (ANY assets.subTitle CONTAINS [c]%@) OR (ANY assets.assetFormat CONTAINS [c]%@) OR (title CONTAINS [c]%@) OR (subTitle CONTAINS [c]%@)", search, search, search, search, search];
	[request setPredicate:predicate];
	
	NSError *error;
	mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (error) {
		CLS_LOG(@"Error fetching assets with search: %@", search);
	}
	
	return mutableFetchResults;
}

+(Assessment *)fetchAssessmentForId:(NSString *)assessmentId
{
	Assessment *assessment = NULL;
	NSMutableArray *mutableFetchResults = [[NSMutableArray alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assessment" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assessmentId == %@", assessmentId];
	[request setPredicate:predicate];
	
	NSError *error;
	mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (error) {
		CLS_LOG(@"Error fetching assessment with ID: %@", assessmentId);
	}
	
	if ([mutableFetchResults count] > 0) {
		if ([mutableFetchResults count] > 1) CLS_LOG(@"More than one assessment was found, we'll use the first.");
		assessment = (Assessment *)[mutableFetchResults objectAtIndex:0];
	} else {
		assessment = [self addAssessmentWithId:assessmentId];
	}
	
	return assessment;
}

+(NSMutableArray *)fetchAllAssessments
{
	NSMutableArray *mutableFetchResults = [[NSMutableArray alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assessment" inManagedObjectContext:[CoreDataHandler context]];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSError *error;
	mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (error) {
		CLS_LOG(@"Error fetching all assessments");
	}
	
	return mutableFetchResults;
}

+(Assessment *)addAssessmentWithId:(NSString *)assessmentId
{
	Assessment *assessment = [NSEntityDescription insertNewObjectForEntityForName:@"Assessment" inManagedObjectContext:[CoreDataHandler context]];
	if (assessment) [assessment setAssessmentId:assessmentId];
	
	return assessment;
}

+(AssessmentAnswer *)addAnswer:(NSString *)answer forQuestionId:(NSString *)questionId inAssessment:(NSString *)assessmentId
{
	Assessment *assessment = [CoreDataHandler fetchAssessmentForId:assessmentId];
	if (!assessment) [self addAssessmentWithId:assessmentId];
	
	AssessmentAnswer *assessmentAnswer = [NSEntityDescription insertNewObjectForEntityForName:@"AssessmentAnswer" inManagedObjectContext:[CoreDataHandler context]];
	[assessmentAnswer setAnswer:answer];
	[assessmentAnswer setQuestionId:questionId];
	if (assessment) [assessment addAnswersObject:assessmentAnswer];
	
	return assessmentAnswer;
}

+(AssessmentAnswer *)addAnswerWithDictionary:(NSDictionary *)dictionary
{
	AssessmentAnswer *assessmentAnswer = NULL;
	
	if ([dictionary objectForKey:@"quizId"] && [dictionary objectForKey:@"questionId"] && [dictionary objectForKey:@"answer"]) {
		Assessment *assessment = [CoreDataHandler fetchAssessmentForId:[dictionary objectForKey:@"quizId"]];
		if (!assessment) [self addAssessmentWithId:[dictionary objectForKey:@"quizId"]];
		
		assessmentAnswer = [NSEntityDescription insertNewObjectForEntityForName:@"AssessmentAnswer" inManagedObjectContext:[CoreDataHandler context]];
        
        id answerId = [dictionary objectForKey:@"answer"];
        if ([answerId isKindOfClass:[NSString class]]) {
            [assessmentAnswer setAnswer:answerId];
        } else if ([answerId isKindOfClass:[NSNumber class]]) {
            [assessmentAnswer setAnswer:[((NSNumber *) answerId) stringValue]];
        }
        id questionId = [dictionary objectForKey:@"questionId"];
        if ([questionId isKindOfClass:[NSString class]]) {
            [assessmentAnswer setQuestionId:questionId];
        } else if ([questionId isKindOfClass:[NSNumber class]]) {
            [assessmentAnswer setQuestionId:[((NSNumber *) questionId) stringValue]];
        }
        
		if (assessment) [assessment addAnswersObject:assessmentAnswer];
		
		CLS_LOG(@"Added answer for assessment: %@", [assessment assessmentId]);
		CLS_LOG(@"Question ID: %@", [assessmentAnswer questionId]);
		CLS_LOG(@"Answer: %@", [assessmentAnswer answer]);
	}
	
	[CoreDataHandler commit];
	
	return assessmentAnswer;
}

+(NSArray *)addAnswerWithArray:(NSArray *)array
{
	NSMutableArray *assessmentArray = [[NSMutableArray alloc] init];
	
	for (int i=0; i<[array count]; i++) {
		NSDictionary *dictionary = (NSDictionary *)[array objectAtIndex:i];
		
		if ([dictionary objectForKey:@"quizId"] && [dictionary objectForKey:@"questionId"] && [dictionary objectForKey:@"answer"]) {
			Assessment *assessment = [CoreDataHandler fetchAssessmentForId:[dictionary objectForKey:@"quizId"]];
			if (!assessment) [self addAssessmentWithId:[dictionary objectForKey:@"quizId"]];
			
			AssessmentAnswer *assessmentAnswer = [NSEntityDescription insertNewObjectForEntityForName:@"AssessmentAnswer" inManagedObjectContext:[CoreDataHandler context]];
            
            id answerId = [dictionary objectForKey:@"answer"];
            if ([answerId isKindOfClass:[NSString class]]) {
                [assessmentAnswer setAnswer:answerId];
            } else if ([answerId isKindOfClass:[NSNumber class]]) {
                [assessmentAnswer setAnswer:[((NSNumber *) answerId) stringValue]];
            }
            id questionId = [dictionary objectForKey:@"questionId"];
            if ([questionId isKindOfClass:[NSString class]]) {
                [assessmentAnswer setQuestionId:questionId];
            } else if ([questionId isKindOfClass:[NSNumber class]]) {
                [assessmentAnswer setQuestionId:[((NSNumber *) questionId) stringValue]];
            }
			if (assessment) [assessment addAnswersObject:assessmentAnswer];
			
			[assessmentArray addObject:assessmentAnswer];
			
			CLS_LOG(@"Added answer for assessment: %@", [assessment assessmentId]);
			CLS_LOG(@"Question ID: %@", [assessmentAnswer questionId]);
			CLS_LOG(@"Answer: %@", [assessmentAnswer answer]);
		}
	}
	
	[CoreDataHandler commit];
	
	return assessmentArray;
}

+(BOOL)removeDownloadWithDownload:(Download *)download
{
	NSError *error = NULL;
	NSFileManager *fileManager = [[NSFileManager alloc] init];

    if ([fileManager fileExistsAtPath:download.absolutePathToFile]) {
		[fileManager removeItemAtPath:download.absolutePathToFile error:&error];
	}
	[[CoreDataHandler context] deleteObject:download];
	
	return (error) ? NO : YES;
}

+(BOOL)removeDownloadForAsset:(Asset *)asset
{
	BOOL removed = NO;
	
	if ([asset download]) {
		Download *download = (Download *)[asset download];
		removed = [CoreDataHandler removeDownloadWithDownload:download];
	}
	
	return removed;
}

+(int)numberOfDownloads
{
	return (int) [[CoreDataHandler fetchAllDownloads] count];
}

@end
