//
//  IGLoginButton.m
//  IgViewer
//
//  Created by matata on 06/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGLoginButton.h"

@implementation IGLoginButton

- (id)initWithDefaultImage:(UIImage *)defaultImage andSelectedImage:(UIImage *)selectedImage
{
    self = [super initWithFrame:CGRectMake(0, 0, defaultImage.size.width, defaultImage.size.height)];
    if (self) {
		selectedBackground = [[UIImageView alloc] initWithImage:selectedImage];
		[self addSubview:selectedBackground];
		[selectedBackground setHidden:YES];
		
		defaultBackground = [[UIImageView alloc] initWithImage:defaultImage];
		[self addSubview:defaultBackground];
		
		[self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchDown];
		[self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    }
    return self;
}

-(void)buttonPressed
{
	[defaultBackground setHidden:YES];
	[selectedBackground setHidden:NO];
}

-(void)buttonReleased
{
	[defaultBackground setHidden:NO];
	[selectedBackground setHidden:YES];
}

@end
