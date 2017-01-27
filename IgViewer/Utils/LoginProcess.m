//
//  LoginProcess.m
//  IgViewer
//
//  Created by matata on 13/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "LoginProcess.h"
#import <Security/Security.h>
#import "LoginSessionCredentials.h"

static NSString *serviceName = @"com.eusapharma.igViewer";
static NSString *usernameIdentifier = @"IgViewerUserName";
static NSString *passwordIdentifier = @"IgViewerPassword";

@implementation LoginProcess

-(id)init
{
	self = [super init];
	if (self) {
		wasAutomaticLoginAttempt = NO;
	}
	return self;
}

-(BOOL)attemptAutomaticLogin
{
	BOOL attempt = NO;
	wasAutomaticLoginAttempt = YES;
	
	NSString *username = [self userNameInKeychain];
	NSString *password = [self passwordInKeychain];
	
	if (username && password) {
		LoginSessionCredentials *credentials = [[LoginSessionCredentials alloc] initWithUsername:username andPassword:password];
		[credentials setDelegate:self];
		[credentials validateAndTryLogin:NO];
	} else {
		if ([[self delegate] respondsToSelector:@selector(userLoginFailedFromAutomaticAttempt:)]) {
			[[self delegate] userLoginFailedFromAutomaticAttempt:wasAutomaticLoginAttempt];
		}
	}
	
	return attempt;
}

-(void)login
{
	wasAutomaticLoginAttempt = NO;
	
	NSString *username = [self userNameInKeychain];
	NSString *password = [self passwordInKeychain];
	
	[self loginWithUsername:username andPassword:password];
}

-(void)loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
	wasAutomaticLoginAttempt = NO;
    
    CLS_LOG(@"Login attempt with username: %@", username);
	
	BOOL loggedAttempted = NO;
	if (username && password) {
		if (![username isEqualToString:@""] && ![password isEqualToString:@""]) {
			LoginSessionCredentials *credentials = [[LoginSessionCredentials alloc] initWithUsername:username andPassword:password];
			[credentials setDelegate:self];
			[credentials validate];
			loggedAttempted = YES;
			CLS_LOG(@"Login attempted...");
		}
	}
	
	if (!loggedAttempted) {
		if ([[self delegate] respondsToSelector:@selector(userLoginFailed)]) {
			[[self delegate] userLoginFailed];
            CLS_LOG(@"Login failed");
		}
	}

}

-(void)sessionCredentialsValidated:(LoginSessionCredentials *)credentials
{
	[self removeKeychainLoginItems];
	
	BOOL addedToKeychain = [self keychainItemWithUsername:[credentials userName] andPassword:[credentials userPassword]];
	
	if ([[self delegate] respondsToSelector:@selector(userLoggedInWithCredentials:)]) {
		[[self delegate] userLoggedInWithCredentials:credentials];
	}
	
	if (!addedToKeychain) CLS_LOG(@"Error adding credentials to keychain...");
	
	wasAutomaticLoginAttempt = NO;
}

-(void)sessionCredentialsValidationFailed
{
	if ([[self delegate] respondsToSelector:@selector(userLoginFailed)]) {
		[[self delegate] userLoginFailed];
	}
	if ([[self delegate] respondsToSelector:@selector(userLoginFailedFromAutomaticAttempt:)]) {
		[[self delegate] userLoginFailedFromAutomaticAttempt:wasAutomaticLoginAttempt];
	}
	
	wasAutomaticLoginAttempt = NO;
}

-(BOOL)keychainItemWithUsername:(NSString *)username andPassword:(NSString *)password
{
	BOOL success = NO;
	
	BOOL usernameCreated = [self createKeychainItemWithValue:username forIdentifier:usernameIdentifier];
	BOOL passwordCreated = [self createKeychainItemWithValue:password forIdentifier:passwordIdentifier];
	
	if (usernameCreated && passwordCreated) success = YES;
	
	return success;
}

-(BOOL)removeKeychainLoginItems
{
	BOOL success = NO;
	
	BOOL removeUsername = [self removeItemInKeychainWithIdentifier:usernameIdentifier];
	BOOL removePassword = [self removeItemInKeychainWithIdentifier:passwordIdentifier];
	if (removePassword && removeUsername) success = YES;
	
	return success;
}

-(NSString *)userNameInKeychain
{
	NSString *keychainValue = NULL;
	NSData *data = [self dataForKeychainItemWithIdentifier:usernameIdentifier];
	if (data) keychainValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	return keychainValue;
}

-(NSString *)passwordInKeychain
{
	NSString *keychainValue = NULL;
	NSData *data = [self dataForKeychainItemWithIdentifier:passwordIdentifier];
	if (data) keychainValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	return keychainValue;
}

-(NSMutableDictionary *)dictionaryForLoginKeychainWithIdentifier:(NSString *)identifier
{
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	
	[dictionary setObject:(id)CFBridgingRelease(kSecClassGenericPassword) forKey:(id)CFBridgingRelease(kSecClass)];
	
	NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
	[dictionary setObject:encodedIdentifier forKey:(id)CFBridgingRelease(kSecAttrGeneric)];
	[dictionary setObject:encodedIdentifier forKey:(id)CFBridgingRelease(kSecAttrAccount)];
	[dictionary setObject:serviceName forKey:(id)CFBridgingRelease(kSecAttrService)];
	
	return dictionary;
}

-(BOOL)createKeychainItemWithValue:(NSString *)itemValue forIdentifier:(NSString *)identifier
{
	BOOL success = NO;
	
	NSMutableDictionary *dictionary = [self dictionaryForLoginKeychainWithIdentifier:identifier];
	
	NSData *itemValueData = [itemValue dataUsingEncoding:NSUTF8StringEncoding];
	[dictionary setObject:itemValueData forKey:(id)CFBridgingRelease(kSecValueData)];
	
	OSStatus status = SecItemAdd((CFDictionaryRef)CFBridgingRetain(dictionary), NULL);
	
	if (status == errSecSuccess) success = YES;
	
	return success;
}

-(NSData *)dataForKeychainItemWithIdentifier:(NSString *)identifier
{
	NSMutableDictionary *dictionary = [self dictionaryForLoginKeychainWithIdentifier:identifier];
	
	// Add search attributes
	[dictionary setObject:(id)CFBridgingRelease(kSecMatchLimitOne) forKey:(id)CFBridgingRelease(kSecMatchLimit)];
	
	// Add search return types
	[dictionary setObject:(id)kCFBooleanTrue forKey:(id)CFBridgingRelease(kSecReturnData)];
	
	CFTypeRef result = NULL;
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)CFBridgingRetain(dictionary), (CFTypeRef *)&result);
	NSData *data = (NSData *)CFBridgingRelease(result);
	
	if (status != errSecSuccess) CLS_LOG(@"Error retrieving data in keychain.");
	
	return data;
}

-(BOOL)removeItemInKeychainWithIdentifier:(NSString *)identifier
{
	BOOL success = NO;
	
	NSMutableDictionary *dictionary = [self dictionaryForLoginKeychainWithIdentifier:identifier];
	OSStatus status = SecItemDelete((CFDictionaryRef)CFBridgingRetain(dictionary));
	if (status == errSecSuccess) success = YES;
	
	return success;
}

@end
