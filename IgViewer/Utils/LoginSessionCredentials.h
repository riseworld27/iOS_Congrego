//
//  LoginSessionCredentials.h
//  IgViewer
//
//  Created by matata on 13/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginSessionCredentials, AFHTTPRequestOperation;

@protocol LoginSessionCredentialsDelegate <NSObject>

@optional
-(void)sessionCredentialsValidated:(LoginSessionCredentials *)credentials;
-(void)sessionCredentialsValidationFailed;
-(void)sessionLoggedOutWithErrors:(BOOL)errors;

@end

@interface LoginSessionCredentials : NSObject
{
	int loginAttempCount;
}

@property (nonatomic, retain) NSString *sessionId;
@property (nonatomic, retain) NSString *sessionName;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userPassword;
@property (nonatomic) BOOL isValid;
@property (nonatomic, weak) id <LoginSessionCredentialsDelegate> delegate;

-(id)initWithUsername:(NSString *)user andPassword:(NSString *)password;
-(void)validate;
-(void)validateAndTryLogin:(BOOL)tryLogin;
-(void)logout;
-(void)attemptLogoutWithRetry:(BOOL)retry;

@end
