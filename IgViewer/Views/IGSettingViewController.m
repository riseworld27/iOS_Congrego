//
//  IGSettingViewController.m
//  IgViewer
//
//  Created by matata on 13/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGSettingViewController.h"
#import "IGLogoutButton.h"

@interface IGSettingViewController ()

@end

@implementation IGSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view setFrame:CGRectMake(0, 0, 300, 80)];
		[self.view setBackgroundColor:[UIColor whiteColor]];
		
		logoutButton = [[IGLogoutButton alloc] initWithDefaultImage:[UIImage imageNamed:@"logOutButtonDefault.png"] andSelectedImage:[UIImage imageNamed:@"logOutButtonSelected.png"]];
		[logoutButton setFrame:CGRectMake(CENTER_X(logoutButton, self.view), CENTER_Y(logoutButton, self.view), WIDTH(logoutButton), HEIGHT(logoutButton))];
		[self.view addSubview:logoutButton];
		[logoutButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)buttonPressed
{
	if ([[self delegate] respondsToSelector:@selector(shouldLogUserOut)]) {
		[[self delegate] shouldLogUserOut];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
