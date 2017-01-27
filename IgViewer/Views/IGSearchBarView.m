//
//  IGSearchBarView.m
//  IgViewer
//
//  Created by matata on 13/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGSearchBarView.h"

@implementation IGSearchBarView

@synthesize searchField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchBarBackground.png"]];
		[self addSubview:backgroundImage];
		
		searchField = [[UITextField alloc] initWithFrame:CGRectMake(100, 14, 890, 16)];
		[searchField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0]];
		[searchField setTextColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
		[searchField setTextAlignment:NSTextAlignmentLeft];
		[searchField setBackgroundColor:[UIColor clearColor]];
		[searchField setAdjustsFontSizeToFitWidth:NO];
		[searchField setPlaceholder:NSLocalizedString(@"SearchBarDefaultText", NULL)];
		[searchField setReturnKeyType:UIReturnKeyDone];
		[searchField setKeyboardType:UIKeyboardTypeAlphabet];
		//[searchField setDelegate:self];
		[searchField addTarget:self action:@selector(textEditingFinished) forControlEvents:UIControlEventEditingDidEndOnExit];
		//[searchField addTarget:self action:@selector(textEditingChanged) forControlEvents:UIControlEventEditingChanged];
		[searchField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self addSubview:searchField];
    }
    return self;
}

-(void)textEditingFinished
{
	if ([[self delegate] respondsToSelector:@selector(shouldSearchForString:)]) {
		[[self delegate] shouldSearchForString:[searchField text]];
	}
	[searchField resignFirstResponder];
}

-(void)clear
{
	[searchField setText:@""];
	[searchField resignFirstResponder];
}

@end
