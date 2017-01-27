//
//  Analytics.h
//  RepPresent
//
//  Created by matata on 11/12/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    None,
    DimensionContentItemId,
    DimensionUserId,
    DimensionSlideId,
    DimensionUsername
} Dimensions;

@interface Analytics : NSObject

+ (void)startSession;
+ (void)loginWithId:(NSString *)userId username:(NSString *)username;
+ (void)openContentWithId:(NSString *)cmsId title:(NSString *)title;
+ (void)closeContent;

//+ (void)trackScreen:(NSString *)name;
+ (void)trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
+ (void)trackTiming:(NSString *)category name:(NSString *)name label:(NSString *)label interval:(NSNumber *)interval;
+ (void)setDimensionIndex:(int)index toValue:(NSString *)value;

@end
