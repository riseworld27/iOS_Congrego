//
//  IGLogOutButton.m
//  IgViewer
//
//  Created by matata on 13/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGLogOutButton.h"

@implementation IGLogoutButton

- (id)initWithDefaultImage:(UIImage *)defaultImage andSelectedImage:(UIImage *)selectedImage
{
    self = [super initWithFrame:CGRectMake(0, 0, defaultImage.size.width, defaultImage.size.height)];
    if (self) {
        defaultImageView = [[UIImageView alloc] initWithImage:defaultImage];
		selectedImageView = [[UIImageView alloc] initWithImage:selectedImage];
		[self addSubview:defaultImageView];
		[self addSubview:selectedImageView];
		[selectedImageView setHighlighted:YES];
		
		[self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchDown];
		[self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    }
    return self;
}

-(void)buttonPressed
{
	[defaultImageView setHidden:YES];
	[selectedImageView setHidden:NO];
}

-(void)buttonReleased
{
	[defaultImageView setHidden:NO];
	[selectedImageView setHidden:YES];
}

@end
