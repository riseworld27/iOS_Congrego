//
//  IGLoginView.m
//  IgViewer
//
//  Created by matata on 06/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGLoginView.h"
#import "IGHeaderBar.h"
#import "IGLoginEntryField.h"
#import "IGLoginButton.h"
#import "LoginProcess.h"
#import "LoginSessionCredentials.h"
#import "CMSUtils.h"

@implementation IGLoginView

- (id)initWithUserName:(NSString *)userName andPassword:(NSString *)password
{
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    if (self) {
        urls = [[NSArray alloc] initWithObjects:@"demo.congregocms.co.uk", @"eusa.reppresentcms.co.uk", @"msd.congregocms.co.uk", @"gedeon-richter.congregocms.co.uk", @"demo.congregocms.co.uk", nil];
        
		container = [[UIView alloc] initWithFrame:CGRectZero];
		
		userField = [[IGLoginEntryField alloc] initWithDefaultText:@"User Name"];
		//[[userField textEntry] setDelegate:self];
		[[userField textEntry] addTarget:self action:@selector(userNameDone) forControlEvents:UIControlEventEditingDidEndOnExit];
		[container addSubview:userField];
		passwordFIeld = [[IGLoginEntryField alloc] initWithDefaultText:@"Password"];
		[[passwordFIeld textEntry] setSecureTextEntry:YES];
		[[passwordFIeld textEntry] addTarget:self action:@selector(passwordDone) forControlEvents:UIControlEventEditingDidEndOnExit];
		[container addSubview:passwordFIeld];
		[passwordFIeld setFrame:CGRectMake(0, AFTER_Y(userField)+10, WIDTH(passwordFIeld), HEIGHT(passwordFIeld))];
        
		button = [[IGLoginButton alloc] initWithDefaultImage:[UIImage imageNamed:@"loginSignInButtonDefault.png"] andSelectedImage:[UIImage imageNamed:@"loginSignInButtonSelected.png"]];
		[button setFrame:CGRectMake(0, AFTER_Y(passwordFIeld)+10, WIDTH(button), HEIGHT(button))];
		[button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:button];
        
        picker = [[UIPickerView alloc] init];
        picker.delegate = self;
        picker.dataSource = self;
        [picker reloadAllComponents];
        
        if ([urls containsObject:[CMSUtils server]]) {
            [picker selectRow:[urls indexOfObject:[CMSUtils server]] inComponent:0 animated:NO];
        } else {
            [picker selectRow:0 inComponent:0 animated:NO];
        }
        
        endpointField = [[IGLoginEntryField alloc] initWithDefaultText:@"Endpoint"];
        endpointField.frame = CGRectMake(0, AFTER_Y(button) + 10, WIDTH(endpointField), HEIGHT(endpointField));
        endpointField.textEntry.text = [CMSUtils server];
//        [endpointField.textEntry addTarget:self action:@selector(endpointChanged:) forControlEvents:UIControlEventEditingChanged];
        endpointField.textEntry.inputView = picker;
        
        // This should appear if it's a Debug build or we're using the Congrego target
#ifdef DEBUG
        [container addSubview:endpointField];
#else
        if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"TargetName"] isEqualToString:@"Congrego"]) {
            [container addSubview:endpointField];
        }
#endif
        CLS_LOG(@"Bundle name: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TargetName"]);
        
		[container setFrame:CGRectMake(0, 0, WIDTH(userField), HEIGHT(userField)+HEIGHT(passwordFIeld)+HEIGHT(button)+HEIGHT(endpointField)+20)];
		[container setFrame:CGRectMake(CENTER_X(container, self), CENTER_Y(container, self)-100, WIDTH(container), HEIGHT(container))];
		//[self addSubview:container];
		
		IGHeaderBar *headerBar = [[IGHeaderBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"Header Bar Background"]];
		[self addSubview:headerBar];
    }
    return self;
}

-(void)userNameDone
{
	[[passwordFIeld textEntry] becomeFirstResponder];
}

- (void)endpointChanged:(UITextField*)textField {
    [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:@"Server"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)passwordDone
{
	[self buttonPressed];
}

-(void)login
{
	if (!login) {
		login = [[LoginProcess alloc] init];
		[login setDelegate:self];
	}
	/*if ([login shouldAttemptAutomaticLogin]) {
		if ([[self delegate] respondsToSelector:@selector(userHasLoggedIn)]) [[self delegate] userHasLoggedIn];
	} else {
		[self addSubview:container];
	}*/
	[login attemptAutomaticLogin];
}

-(void)buttonPressed
{
    [endpointField.inputView resignFirstResponder];
	//if ([[self delegate] respondsToSelector:@selector(userHasLoggedIn)]) [[self delegate] userHasLoggedIn];
	NSString *userNameEntry = [[userField textEntry] text];
	NSString *passwordEntry = [[passwordFIeld textEntry] text];
	if (login && ![userNameEntry isEqualToString:@""] && ![passwordEntry isEqualToString:@""]) {
        [passwordFIeld endEditing:YES];
        [userField endEditing:YES];
        
		[login loginWithUsername:[[userField textEntry] text] andPassword:[[passwordFIeld textEntry] text]];
	}
}

-(void)hideContainer
{
	[container setHidden:YES];
}

-(void)userLoginFailedFromAutomaticAttempt:(BOOL)automatic
{
	CLS_LOG(@"Login failed");
	if (automatic) {
		[self addSubview:container];
	} else {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"Error logging in"
							  message: @"There was an error logging in, please check your username and password are correct."
							  delegate: nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
	}
}

-(void)userLoggedInWithCredentials:(LoginSessionCredentials *)credentials
{
	if ([[self delegate] respondsToSelector:@selector(userLoggedInWithCredentials:)]) [[self delegate] userLoggedInWithCredentials:credentials];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return urls.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return urls[row];
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    endpointField.textEntry.text = urls[row];
    
    [[NSUserDefaults standardUserDefaults] setValue:urls[row] forKey:@"Server"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
