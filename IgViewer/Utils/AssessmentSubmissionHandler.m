//
//  AssessmentSubmissionHandler.m
//  RepPresent
//
//  Created by matata on 20/06/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "AssessmentSubmissionHandler.h"
#import "NetworkManager.h"
#import "CMSUtils.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPRequestOperation.h"
#import "CoreDataHandler.h"
#import "Assessment.h"
#import "AssessmentAnswer.h"

@implementation AssessmentSubmissionHandler

-(id)init
{
	self = [super init];
	if (self) {
		isSubmitting = NO;
	}
	return self;
}

-(void)submitAnswerWithDictionary:(NSDictionary *)dictionary
{
	if (dictionary) {
		if ([[NetworkManager sharedInstance] isConnectionAvailable]) {
			NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
			
			NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
			[jsonDictionary setObject:[dictionary objectForKey:@"quizId"] forKey:@"assessmentId"];
			
			NSMutableArray *assessmentArray = [[NSMutableArray alloc] init];
			NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
			[dic setObject:[dictionary objectForKey:@"questionId"] forKey:@"questionId"];
			[dic setObject:[dictionary objectForKey:@"answer"] forKey:@"answer"];
			[assessmentArray addObject:dic];
			
			[jsonDictionary setObject:assessmentArray forKey:@"answers"];
			
			[jsonArray addObject:jsonDictionary];
			
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:nil];
			
			NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
			CLS_LOG(@"Submitting JSON: %@", jsonString);
			
			NSMutableDictionary *arguments = [CMSUtils dictionaryForLoginDetails];
			
            AFJSONRequestSerializer *serializer = [[AFJSONRequestSerializer alloc] init];
            NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:[[CMSUtils baseUrl] stringByAppendingString:@"/api/v1/assessment"] parameters:arguments error:nil];
            request.HTTPBody = jsonData;
            request.allHTTPHeaderFields = arguments;
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                CLS_LOG(@"JSON Sent: %@", jsonString);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [CoreDataHandler addAnswerWithDictionary:dictionary];
            }];
			
			[operation start];
		} else {
			[CoreDataHandler addAnswerWithDictionary:dictionary];
		}
	}
}

-(void)submitAnswerWithArray:(NSArray *)array
{
	if (array) {
		if ([[NetworkManager sharedInstance] isConnectionAvailable]) {
			NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
			
			for (int i=0; i<[array count]; i++) {
				NSDictionary *dictionary = (NSDictionary *)[array objectAtIndex:i];
				
				NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
				[jsonDictionary setObject:[dictionary objectForKey:@"quizId"] forKey:@"assessmentId"];
				
				NSMutableArray *assessmentArray = [[NSMutableArray alloc] init];
				NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
				[dic setObject:[dictionary objectForKey:@"questionId"] forKey:@"questionId"];
				[dic setObject:[dictionary objectForKey:@"answer"] forKey:@"answer"];
				[assessmentArray addObject:dic];
				
				[jsonDictionary setObject:assessmentArray forKey:@"answers"];
				
				[jsonArray addObject:jsonDictionary];
			}
			
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:nil];
			
			NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
			CLS_LOG(@"Submitting JSON: %@", jsonString);
			
			NSMutableDictionary *arguments = [CMSUtils dictionaryForLoginDetails];
			
			AFJSONRequestSerializer *serializer = [[AFJSONRequestSerializer alloc] init];
            NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:[[CMSUtils baseUrl] stringByAppendingString:@"/api/v1/assessment"] parameters:arguments error:nil];
            [request setHTTPBody:jsonData];
            [request setAllHTTPHeaderFields:arguments];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                // nothing
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [CoreDataHandler addAnswerWithArray:array];
            }];
			
			[operation start];
		} else {
			[CoreDataHandler addAnswerWithArray:array];
		}
	}
}

-(void)submitStoredAssessments
{
	if (!isSubmitting && [[NetworkManager sharedInstance] isConnectionAvailable]) {
		CLS_LOG(@"Submitting stored assessments");
		
		NSArray *assessments = [CoreDataHandler fetchAllAssessments];
		NSData *jsonData = NULL;
		
		if ([assessments count] > 0) {
			NSMutableArray *assessmentsArray = [[NSMutableArray alloc] init];
			for (int i=0; i<[assessments count]; i++) {
				Assessment *assessment = (Assessment *)[assessments objectAtIndex:i];
				
				NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
				[dictionary setValue:[assessment assessmentId] forKey:@"assessmentId"];
				
				NSMutableArray *answersArray = [[NSMutableArray alloc] init];
				NSMutableArray *assessmentAnswers = [[[assessment answers] allObjects] mutableCopy];
				
				for (int a=0; a<[assessmentAnswers count]; a++) {
					AssessmentAnswer *answer = (AssessmentAnswer *)[assessmentAnswers objectAtIndex:a];
					NSMutableDictionary *answerDictionary = [[NSMutableDictionary alloc] init];
					[answerDictionary setValue:[answer answer] forKey:@"answer"];
					[answerDictionary setValue:[answer questionId] forKey:@"questionId"];
					
					[answersArray addObject:answerDictionary];
				}
				
				[dictionary setValue:answersArray forKey:@"answers"];
				[assessmentsArray addObject:dictionary];
			}
			
			jsonData = [NSJSONSerialization dataWithJSONObject:assessmentsArray options:0 error:nil];
		}
		
		if (jsonData) {
			NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
			CLS_LOG(@"Submitting JSON: %@", jsonString);
			
			NSMutableDictionary *arguments = [CMSUtils dictionaryForLoginDetails];
			
			AFJSONRequestSerializer *serializer = [[AFJSONRequestSerializer alloc] init];
            NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:[[CMSUtils baseUrl] stringByAppendingString:@"/api/v1/assessment"] parameters:arguments error:nil];
            [request setHTTPBody:jsonData];
			[request setAllHTTPHeaderFields:arguments];
			[request addValue:@"application/json" forHTTPHeaderField:@"Conent-Type"];
			
			isSubmitting = YES;
			
			__block AssessmentSubmissionHandler *selfForBlock = self;
			
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [selfForBlock submissionComplete];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [selfForBlock submissionFailed];
            }];
			
			[operation start];
		}
	}
}

-(void)submissionComplete
{
	isSubmitting = NO;
	[CoreDataHandler clearAllAssessments];
	
	/*CLS_LOG(@"Assessments remaining: %i", [CoreDataHandler numberOfObjectsInEntityWithName:@"Assessment"]);
	CLS_LOG(@"Assessment Answers remaining: %i", [CoreDataHandler numberOfObjectsInEntityWithName:@"AssessmentAnswer"]);*/
}

-(void)submissionFailed
{
	isSubmitting = NO;
}

@end
