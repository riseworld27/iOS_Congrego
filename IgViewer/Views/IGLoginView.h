//
//  IGLoginView.h
//  IgViewer
//
//  Created by matata on 06/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginProcess.h"

@class IGLoginButton, LoginProcess, IGLoginEntryField, LoginSessionCredentials;

@protocol IGLoginViewDelegate <NSObject>

@optional
-(void)userLoggedInWithCredentials:(LoginSessionCredentials *)credentials;

@end

@interface IGLoginView : UIView <LoginProcessDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
	UIView *container;
	IGLoginButton *button;
	LoginProcess *login;
	IGLoginEntryField *userField;
	IGLoginEntryField *passwordFIeld;
    IGLoginEntryField *endpointField;
    UIPickerView *picker;
    
    NSArray *urls;

}

@property (nonatomic, retain) id <IGLoginViewDelegate> delegate;

- (id)initWithUserName:(NSString *)userName andPassword:(NSString *)password;
-(void)hideContainer;
-(void)login;

@end
