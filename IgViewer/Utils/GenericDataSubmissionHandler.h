//
//  GenericDataSubmissionHandler.h
//  RepPresent
//
//  Created by Mark Elliott on 27/05/2015.
//  Copyright (c) 2015 BWO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericDataSubmissionHandler : NSObject

-(void)submitGenericDataWithKey:(NSString *)key;
-(void)submitAllGenericData;

@end
