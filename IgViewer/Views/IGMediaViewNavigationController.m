//
//  IGMediaViewNavigationController.m
//  RepPresent
//
//  Created by matata on 24/06/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGMediaViewNavigationController.h"

@interface IGMediaViewNavigationController ()

@end

@implementation IGMediaViewNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.view setUserInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
