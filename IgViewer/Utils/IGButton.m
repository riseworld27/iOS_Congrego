//
//  IGButton.m
//  IgViewer
//
//  Created by matata on 04/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGButton.h"
#import "FCTileableElementController.h"

@implementation IGButton

@synthesize caption, label;

-(id)initWithTitle:(NSString *)title
{
	return [self initWithTitle:title andFilePrefix:@"detailsViewButton"];
}

-(id)initWithTitle:(NSString *)title andFilePrefix:(NSString *)prefix
{
	FCTileableElementController *buttonDefaultController = [[FCTileableElementController alloc]
															initWithLeftCap:[UIImage imageNamed:[NSString stringWithFormat:@"%@LeftDefault.png", prefix]]
															rightCap:[UIImage imageNamed:[NSString stringWithFormat:@"%@RightDefault.png", prefix]]
															andTile:[UIImage imageNamed:[NSString stringWithFormat:@"%@TileDefault.png", prefix]]];
	FCTileableElementController *buttonSelectedController = [[FCTileableElementController alloc]
															 initWithLeftCap:[UIImage imageNamed:[NSString stringWithFormat:@"%@LeftSelected.png", prefix]]
															 rightCap:[UIImage imageNamed:[NSString stringWithFormat:@"%@RightSelected.png", prefix]]
															 andTile:[UIImage imageNamed:[NSString stringWithFormat:@"%@TileSelected.png", prefix]]];
	
	CGSize textSize = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0]];
	float buttonWidth = textSize.width+buttonDefaultController.leftSection.frame.size.width+buttonDefaultController.rightSection.frame.size.width;
	
	self = [super initWithDefaultControl:buttonDefaultController selectedControl:buttonSelectedController andWidth:[NSNumber numberWithFloat:buttonWidth]];
	if (self) {
		label = [[UILabel alloc] initWithFrame:CGRectMake(buttonDefaultController.leftSection.frame.size.width, 0, textSize.width, buttonDefaultController.leftSection.frame.size.height)];
		[label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0]];
        [label setTextColor:[UIColor colorWithRed:COLOR(113) green:COLOR(120) blue:COLOR(128) alpha:1.0]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:title];
		[label setShadowColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
		[label setShadowOffset:CGSizeMake(0, 1)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:label];
		
		caption = [NSString stringWithString:title];
	}
	return self;
}

-(void)updateTitle:(NSString *)title
{
	caption = [NSString stringWithString:title];
	CGSize textSize = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0]];
	[label setFrame:CGRectMake(X(label), Y(label), textSize.width, HEIGHT(label))];
	[label setText:title];
	[self updateTileableElementControllersTileWith:textSize.width];
}

@end
