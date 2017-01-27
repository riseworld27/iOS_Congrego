//
//  FCControl.m
//  Falcon
//
//  Created by matata on 08/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "FCControl.h"
#import "FCTileableElementController.h"

@implementation FCControl

@synthesize autoExpandToWidth, persistStates, controlState;

- (id)initWithDefaultControl:(FCTileableElementController *)defaultControl selectedControl:(FCTileableElementController *)selectedControl
{
    self = [self initWithDefaultControl:defaultControl selectedControl:selectedControl andWidth:NULL];
    if (self) {
		autoExpandToWidth = NO;
    }
    return self;
}

- (id)initWithDefaultControl:(FCTileableElementController *)defaultControl selectedControl:(FCTileableElementController *)selectedControl andWidth:(NSNumber *)buttonWidth
{
	float tileWidth = 0;
	autoExpandToWidth = YES;
	persistStates = NO;
	controlState = FCControlStateDefault;
	
	if (buttonWidth) {
		tileWidth = [buttonWidth floatValue]-defaultControl.leftSection.frame.size.width-defaultControl.rightSection.frame.size.width;
		autoExpandToWidth = NO;
	} else {
		buttonWidth = [NSNumber numberWithFloat:(defaultControl.leftSection.frame.size.width+defaultControl.rightSection.frame.size.width)];
	}
	
	self = [super initWithFrame:CGRectMake(0, 0, [buttonWidth floatValue], defaultControl.leftSection.frame.size.height)];
    if (self) {
        buttonBackgroundView = [[UIView alloc] initWithFrame:self.frame];
		[self addSubview:buttonBackgroundView];
		
		defaultController = defaultControl;
		selectedController = selectedControl;
		[defaultController updateTileWidth:tileWidth];
		[selectedController updateTileWidth:tileWidth];
		
		[buttonBackgroundView addSubview:[defaultController container]];
		[buttonBackgroundView addSubview:[selectedController container]];
		
		[[selectedControl container] setHidden:YES];
		[buttonBackgroundView setUserInteractionEnabled:NO];
		
		contentContainer = [[UIView alloc] initWithFrame:CGRectMake(X([defaultController tiledSection]), 0, WIDTH([defaultController tiledSection]), HEIGHT([defaultController tiledSection]))];
		[self addSubview:contentContainer];
		[contentContainer setUserInteractionEnabled:NO];
		
		[self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchDown];
		if (!persistStates) [self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    }
    return self;
}

-(void)setPersistStates:(BOOL)persist
{
	persistStates = persist;
	if (persistStates) {
		[self removeTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
	} else {
		[self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
	}
}

-(void)buttonPressed
{
	if (controlState == FCControlStateDefault) {
		[self setControlStateSelectedAndCallDelegate:YES];
	} else {
		if (persistStates) [self setControlStateDefaultAndCallDelegate:YES];
	}
}

-(void)buttonReleased
{
	[self setControlStateDefaultAndCallDelegate:YES];
}

-(void)setControlStateSelectedAndCallDelegate:(BOOL)call
{
	[[selectedController container] setHidden:NO];
	[[defaultController container] setHidden:YES];
	
	controlState = FCControlStateSelected;
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(controlDidChangeState:forControl:)] && call) [[self delegate] controlDidChangeState:controlState forControl:self];
}

-(void)setControlStateDefaultAndCallDelegate:(BOOL)call
{
	[[selectedController container] setHidden:YES];
	[[defaultController container] setHidden:NO];
	
	controlState = FCControlStateDefault;
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(controlDidChangeState:forControl:)] && call) [[self delegate] controlDidChangeState:controlState forControl:self];
}

-(void)updateTileableElementControllersTileWith:(float)width
{
	[defaultController updateTileWidth:width];
	[selectedController updateTileWidth:width];
	
	float controlWidth = defaultController.leftSection.frame.size.width+defaultController.rightSection.frame.size.width+width;
	[self setFrame:CGRectMake(X(self), Y(self), controlWidth, HEIGHT(self))];
}

-(void)setControlState:(FCControlState)state
{
	controlState = state;
	if (controlState == FCControlStateDefault) [self setControlStateDefaultAndCallDelegate:NO];
	if (controlState == FCControlStateSelected) [self setControlStateSelectedAndCallDelegate:NO];
}

@end
