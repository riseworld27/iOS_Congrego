//
//  LoginSessionCredentials.m
//  IgViewer
//
//  Created by matata on 13/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "LoginSessionCredentials.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "CMSUtils.h"
#import "Analytics.h"

static NSString *sessionIdKey = @"sessionId";
static NSString *sessionNameKey = @"sessionName";

@implementation LoginSessionCredentials

@synthesize sessionId, sessionName, isValid, userPassword, userName;

-(id)initWithUsername:(NSString *)user andPassword:(NSString *)password
{
	self = [super init];
	if (self) {
		userName = user;
		userPassword = password;
		isValid = NO;
		loginAttempCount = 0;
	}
	return self;
}

-(void)validate
{
	[self validateAndTryLogin:YES];
}

-(void)validateAndTryLogin:(BOOL)tryLogin
{
	BOOL shouldTryLogin = YES;
    
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	NSString *sid = [userDefault stringForKey:sessionIdKey];
	NSString *sn = [userDefault stringForKey:sessionNameKey];
	
	if (sid && sn) {
		if (![sid isEqualToString:@""] && ![sn isEqualToString:@""]) {
			sessionId = sid;
			sessionName = sn;
			isValid = YES;
			shouldTryLogin = NO;
            
		}
	}
	
	if (shouldTryLogin) {
		CLS_LOG(@"Try login...");
		if (tryLogin) {
			[self attemptUserLogin];
		} else {
			[self loginAttemptFailedWithCode:1];
		}
	} else {
		if ([[self delegate] respondsToSelector:@selector(sessionCredentialsValidated:)]) {
			[[self delegate] sessionCredentialsValidated:self];
		}
	}
}

-(void)attemptUserLogin
{
    
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setObject:userName forKey:@"username"];
	[dictionary setObject:userPassword forKey:@"password"];
    __block LoginSessionCredentials *selfBlock = self;
	
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[CMSUtils baseUrl]]];
    [manager POST:@"/api/v1/json/user/login" parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [selfBlock loginSuccessWithResponse:[operation responseString]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLS_LOG(@"Request failed: %@", error);
        
        if (error.code != -1009) {
            [selfBlock loginAttemptFailedWithCode:((int)operation.response.statusCode)];
        }
    }];
}

-(void)loginAttemptFailedWithCode:(int)code
{
	//[self attemptLogoutWithRetry:NO];
    if (code != 401 && code != 406) {
        [self attemptLogout];
    }
	
	if ([[self delegate] respondsToSelector:@selector(sessionCredentialsValidationFailed)]) {
		[[self delegate] sessionCredentialsValidationFailed];
	}
}

-(void)loginSuccessWithResponse:(NSString *)response
{
	CLS_LOG(@"response: %@", response);
	NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
	
	BOOL sessionValid = NO;
	
	if ([jsonDictionary objectForKey:@"sessid"] && [jsonDictionary objectForKey:@"session_name"]) {
		sessionId = [jsonDictionary objectForKey:@"sessid"];
		sessionName = [jsonDictionary objectForKey:@"session_name"];
		
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		[userDefault setObject:sessionId forKey:sessionIdKey];
		[userDefault setObject:sessionName forKey:sessionNameKey];
        NSDictionary *user = jsonDictionary[@"user"];
        [userDefault setObject:user[@"uid"] forKey:@"userId"];
		[userDefault synchronize];
		sessionValid = YES;
        
        [Analytics loginWithId:user[@"uid"] username:user[@"name"]];
        
        [CrashlyticsKit setUserIdentifier:user[@"uid"]];
        [CrashlyticsKit setUserName:user[@"name"]];
        
		if ([[self delegate] respondsToSelector:@selector(sessionCredentialsValidated:)]) {
			[[self delegate] sessionCredentialsValidated:self];
		}
	} else {
		NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
		if ([jsonArray count] > 0) {
			NSString *returnString = [jsonArray objectAtIndex:0];
			NSString *subString = [returnString substringToIndex:13];
			if ([subString isEqualToString:@"Already logged"]) {
				// LOG THE USER OUT AND TRY AGAIN
				CLS_LOG(@"Need to log out.");
				[self attemptLogout];
			}
		}
	}
	
	if (!sessionValid) {
		if ([[self delegate] respondsToSelector:@selector(sessionCredentialsValidationFailed)]) {
			[[self delegate] sessionCredentialsValidationFailed];
		}
	}
}

-(void)attemptLogout
{
	[self attemptLogoutWithRetry:YES];
}

-(void)attemptLogoutWithRetry:(BOOL)retry
{
	loginAttempCount++;
	
	if (loginAttempCount <= 2) {
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		[dictionary setObject:userName forKey:@"username"];
		[dictionary setObject:userPassword forKey:@"password"];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[CMSUtils baseUrl]]];
		[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
		__block LoginSessionCredentials *selfBlock = self;
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[CMSUtils baseUrl]]];
        [manager POST:@"/api/v1/json/user/logout" parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (retry) [selfBlock attemptUserLogin];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (retry) [selfBlock attemptUserLogin];
        }];
		
	} else {
		if ([[self delegate] respondsToSelector:@selector(sessionCredentialsValidationFailed)]) {
			[[self delegate] sessionCredentialsValidationFailed];
		}
	}
}

-(void)logout
{
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setObject:userName forKey:@"username"];
	[dictionary setObject:userPassword forKey:@"password"];
    __block LoginSessionCredentials *selfBlock = self;
	
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[CMSUtils baseUrl]]];
    [manager POST:@"/api/v1/json/user/logout" parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [selfBlock userLoggedOutWithErrors:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [selfBlock userLoggedOutWithErrors:YES];
    }];
}

-(void)userLoggedOutWithErrors:(BOOL)errors
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud removeObjectForKey:@"sessionId"];
	[ud removeObjectForKey:@"sessionName"];
	[ud synchronize];
	
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	for (NSHTTPCookie *cookie in cookies) {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
	}
	
	if ([[self delegate] respondsToSelector:@selector(sessionLoggedOutWithErrors:)]) {
		[[self delegate] sessionLoggedOutWithErrors:errors];
	}
}

@end
