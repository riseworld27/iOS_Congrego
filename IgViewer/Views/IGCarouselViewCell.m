//
//  IGCarouselViewCell.m
//  IgViewer
//
//  Created by matata on 01/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGCarouselViewCell.h"

@implementation IGCarouselViewCell

-(id)initWithImageAtPath:(NSString *)path
{
	self = [super initWithFrame:CGRectMake(0, 0, 380.0, 200.0)];
	if (self) {
		UIImage *image = [UIImage imageWithContentsOfFile:path];
		imageView = [[UIImageView alloc] initWithImage:image];
		[imageView setContentMode:UIViewContentModeScaleAspectFit];
		[imageView setFrame:self.frame];
		
		[self addSubview:imageView];
		
		[self setReflectionGap:0.0];
		[self setReflectionAlpha:0.3];
		[self setReflectionScale:0.1];
		[self setDynamic:YES];
	}
	return self;
}

-(void)updateImageWithImageAtPath:(NSString *)path
{
	UIImage *image = [UIImage imageWithContentsOfFile:path];
	[imageView setImage:image];
}

@end
