//
//  IGDetailsViewIcon.m
//  IgViewer
//
//  Created by matata on 05/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGDetailsViewIcon.h"
#import <QuartzCore/QuartzCore.h>

@implementation IGDetailsViewIcon

-(id)initWithPathForIcon:(NSString *)path
{
	self = [super initWithFrame:CGRectMake(0, 0, 118, 118)];
	if (self) {
		iconAlpha = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
		[iconAlpha setContentMode:UIViewContentModeScaleAspectFit];
		[iconAlpha setFrame:CGRectMake(0, 0, WIDTH(self), HEIGHT(self))];
		[iconAlpha setAlpha:0.2];
		[self addSubview:iconAlpha];
		
		iconOpaque = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
		[iconOpaque setContentMode:UIViewContentModeScaleAspectFit];
		[iconOpaque setFrame:CGRectMake(0, 0, WIDTH(self), HEIGHT(self))];
		iconOpaqueContainer = [[UIView alloc] initWithFrame:iconOpaque.frame];
		[iconOpaqueContainer addSubview:iconOpaque];
		[iconOpaqueContainer setClipsToBounds:YES];
		[self addSubview:iconOpaqueContainer];
		
		[iconAlpha setHidden:YES];
	}
	return self;
}

-(void)updateWithPercent:(float)percent
{
	[iconAlpha setHidden:NO];
	float newHeight = 118*percent;
	[iconOpaqueContainer setFrame:CGRectMake(X(iconOpaqueContainer), 118-newHeight, WIDTH(iconOpaqueContainer), newHeight)];
	[iconOpaque setFrame:CGRectMake(X(iconOpaque), 0-HEIGHT(iconOpaque)+newHeight, WIDTH(iconOpaque), HEIGHT(iconOpaque))];
}

-(void)setComplete
{
	[iconAlpha setHidden:YES];
	[iconOpaqueContainer setFrame:CGRectMake(X(iconOpaqueContainer), 0, WIDTH(iconOpaqueContainer), 118)];
	[iconOpaque setFrame:CGRectMake(X(iconOpaque), 0, WIDTH(iconOpaque), HEIGHT(iconOpaque))];
}

@end
