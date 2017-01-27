//
//  CMSUtils.m
//  IgViewer
//
//  Created by matata on 19/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "CMSUtils.h"
#import "LoginSessionCredentials.h"

static BOOL testing = NO;
static NSString *protocol = @"http";
static LoginSessionCredentials *currentCredentials;

@implementation CMSUtils

+(NSString *)server
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"Server"];
}

+(NSString *)baseUrl
{
	return [NSString stringWithFormat:@"%@://%@", protocol, [self server]];
}

+(NSString *)urlWithPath:(NSString *)path
{
	if ([path hasPrefix:@"/"]) path = [path substringFromIndex:1];
	
	return [NSString stringWithFormat:@"%@/%@", [CMSUtils baseUrl], path];
}

+(NSString *)urlWithPath:(NSString *)path andArguments:(NSDictionary *)dictionary
{
	NSString *url = [CMSUtils urlWithPath:path];
	if (dictionary) url = [url stringByAppendingString:[CMSUtils parseUrlParameters:dictionary]];
	
	return url;
}

+(NSString *)url:(NSString *)url withArguments:(NSDictionary *)dictionary
{
	return [url stringByAppendingString:[CMSUtils parseUrlParameters:dictionary]];
}

+(NSString *)parseUrlParameters:(NSDictionary *)dictionary
{
	NSString *params = @"";
	
	NSMutableArray *paramArray = [[NSMutableArray alloc] init];
	for (NSString *key in dictionary) {
		[paramArray addObject:[NSString stringWithFormat:@"%@=%@", key, [dictionary objectForKey:key]]];
	}
	for (int i=0; i<[paramArray count]; i++) {
		NSString *prefix = (i==0) ? @"?" : @"&";
		params = [params stringByAppendingString:[NSString stringWithFormat:@"%@%@", prefix, (NSString *)[paramArray objectAtIndex:i]]];
	}
	
	return params;
}

+(NSMutableDictionary *)dictionaryForLoginDetails
{
	return [CMSUtils dictionaryForLoginDetailsWithUserCredentials:currentCredentials];
}

+(NSMutableDictionary *)dictionaryForLoginDetailsWithUserCredentials:(LoginSessionCredentials *)credentials
{
	NSMutableDictionary *loginDetails = [[NSMutableDictionary alloc] init];
	if ([credentials sessionId] && [credentials sessionName]) {
		[loginDetails setObject:[credentials sessionId] forKey:@"sessid"];
		[loginDetails setObject:[credentials sessionName] forKey:@"session_name"];
	}
	
	return loginDetails;
}

+(void)setUserCredentials:(LoginSessionCredentials *)credentials
{
	currentCredentials = credentials;
}

+(LoginSessionCredentials *)userCredentials
{
	return currentCredentials;
}

+(void)setServer:(NSString *)baseServer
{
    [[NSUserDefaults standardUserDefaults] setObject:baseServer forKey:@"Server"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isTesting
{
	return testing;
}

@end
