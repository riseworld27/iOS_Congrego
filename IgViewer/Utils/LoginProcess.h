//
//  LoginProcess.h
//  IgViewer
//
//  Created by matata on 13/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "LoginSessionCredentials.h"

@protocol LoginProcessDelegate <NSObject>

@optional
-(void)userLoggedInWithCredentials:(LoginSessionCredentials *)credentials;
-(void)userLoginFailed;
-(void)userLoginFailedFromAutomaticAttempt:(BOOL)automatic;

@end

@interface LoginProcess : NSObject <LoginSessionCredentialsDelegate>
{
	BOOL wasAutomaticLoginAttempt;
}

@property (nonatomic, weak) id <LoginProcessDelegate> delegate;

-(void)login;
-(void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;
-(BOOL)attemptAutomaticLogin;
-(BOOL)removeKeychainLoginItems;

@end
