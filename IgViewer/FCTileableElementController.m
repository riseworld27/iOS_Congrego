//
//  FCTileableElementController.m
//  Falcon
//
//  Created by matata on 08/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "FCTileableElementController.h"

@implementation FCTileableElementController

@synthesize leftSection, rightSection, tiledSection, container;

- (id)initWithLeftCap:(UIImage *)leftCap rightCap:(UIImage *)rightCap andTile:(UIImage *)tile
{
	self = [super init];
	if (self) {
		leftSection = [[UIImageView alloc] initWithImage:leftCap];
		rightSection = [[UIImageView alloc] initWithImage:rightCap];
		tiledSection = [[UIView alloc] initWithFrame:CGRectMake(WIDTH(leftSection), 0, 0, tile.size.height)];
		[tiledSection setBackgroundColor:[UIColor colorWithPatternImage:tile]];
		[rightSection setFrame:CGRectMake(X(tiledSection)+WIDTH(tiledSection), 0, WIDTH(rightSection), HEIGHT(rightSection))];
		
		container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(leftSection)+WIDTH(tiledSection)+WIDTH(rightSection), HEIGHT(leftSection))];
		[container addSubview:tiledSection];
		[container addSubview:leftSection];
		[container addSubview:rightSection];
	}
	return self;
}

-(void)updateTileWidth:(float)tileWidth
{
	[tiledSection setFrame:CGRectMake(X(tiledSection), 0, tileWidth, HEIGHT(tiledSection))];
	[rightSection setFrame:CGRectMake(X(tiledSection)+WIDTH(tiledSection), 0, WIDTH(rightSection), HEIGHT(rightSection))];
	[container setFrame:CGRectMake(0, 0, WIDTH(leftSection)+WIDTH(tiledSection)+WIDTH(rightSection), HEIGHT(leftSection))];
}

-(float)widthOfButton
{
	return WIDTH(leftSection)+WIDTH(tiledSection)+WIDTH(rightSection);
}

-(float)tileWidth
{
	return WIDTH(tiledSection);
}

@end
