//
//  Assessment.h
//  RepPresent
//
//  Created by matata on 20/06/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssessmentAnswer;

@interface Assessment : NSManagedObject

@property (nonatomic, retain) NSString * assessmentId;
@property (nonatomic, retain) NSSet *answers;
@end

@interface Assessment (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(AssessmentAnswer *)value;
- (void)removeAnswersObject:(AssessmentAnswer *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

@end
