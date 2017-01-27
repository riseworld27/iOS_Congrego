//
//  IGImageViewController.m
//  IgViewer
//
//  Created by matata on 20/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGImageViewController.h"

@interface IGImageViewController ()

@end

@implementation IGImageViewController

-(id)initWithPathToFile:(NSString *)path
{
	self = [super init];
	if (self) {
		file = [NSURL fileURLWithPath:path];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
	[imageView setBackgroundColor:[UIColor blackColor]];
	[imageView setContentMode:UIViewContentModeScaleAspectFit];
	[self.view addSubview:imageView];
	
	UIImage *image = [UIImage imageWithContentsOfFile:file.path];
	[imageView setImage:image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
