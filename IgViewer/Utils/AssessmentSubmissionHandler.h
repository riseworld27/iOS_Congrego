//
//  AssessmentSubmissionHandler.h
//  RepPresent
//
//  Created by matata on 20/06/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssessmentSubmissionHandler : NSObject
{
	BOOL isSubmitting;
}

-(void)submitAnswerWithDictionary:(NSDictionary *)dictionary;
-(void)submitAnswerWithArray:(NSArray *)array;
-(void)submitStoredAssessments;

@end
