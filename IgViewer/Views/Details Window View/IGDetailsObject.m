//
//  IGDetailsObject.m
//  IgViewer
//
//  Created by matata on 12/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGDetailsObject.h"

@implementation IGDetailsObject

@synthesize title,body,size,format,updated;

-(id)init
{
	self = [super init];
	if (self) {
		title = @"Module 1";
		body = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";
		size = @"33 slides";
		format = @"iDetail";
		updated = @"12/01/2013";
	}
	return self;
}

@end
