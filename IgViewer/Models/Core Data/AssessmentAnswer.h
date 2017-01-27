//
//  AssessmentAnswer.h
//  IgViewer
//
//  Created by matata on 12/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AssessmentAnswer : NSManagedObject

@property (nonatomic, retain) NSString * questionId;
@property (nonatomic, retain) NSString * answer;

@end
