//
//  Analytics.m
//  RepPresent
//
//  Created by matata on 11/12/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "Analytics.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"


@implementation Analytics

static id<GAITracker> tracker;

+ (void)startSession
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 10;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker
    //[[GAI sharedInstance] trackerWithTrackingId:@"UA-3532644-7"]; // FFB dev
    
#ifdef DEBUG
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-47403123-1"]; // Iguazu Dev
#else
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-47403123-2"]; // Iguazu EUSA live
#endif
    
    tracker = [[GAI sharedInstance] defaultTracker];
}

+ (void)loginWithId:(NSString *)userId username:(NSString *)username
{
    [tracker set:[GAIFields customDimensionForIndex:DimensionUserId] value:userId];
    [tracker set:[GAIFields customDimensionForIndex:DimensionUsername] value:username];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Application" action:@"Login" label:username value:nil] build]];
}

+ (void)openContentWithId:(NSString *)cmsId title:(NSString *)title
{
    [tracker set:[GAIFields customDimensionForIndex:DimensionContentItemId] value:cmsId];
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:title];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

+ (void)closeContent
{
    [tracker set:kGAIScreenName value:@"Application"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}


+ (void)trackScreen:(NSString *)name
{
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

+ (void)trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
}

+ (void)trackTiming:(NSString *)category name:(NSString *)name label:(NSString *)label interval:(NSNumber *)interval
{
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:category interval:interval name:name label:label] build]];
}

+ (void)setDimensionIndex:(int)index toValue:(NSString *)value
{
    [tracker set:[GAIFields customDimensionForIndex:index] value:value];
}

@end
