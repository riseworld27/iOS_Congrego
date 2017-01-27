//
//  IGLoginEntryField.m
//  IgViewer
//
//  Created by matata on 06/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGLoginEntryField.h"

@implementation IGLoginEntryField

@synthesize textEntry;

- (id)initWithDefaultText:(NSString *)defaultText
{
	UIImage *image = [UIImage imageNamed:@"loginFieldBackground.png"];
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self) {
        UIImageView *background = [[UIImageView alloc] initWithImage:image];
		[self addSubview:background];
		
		textEntry = [[UITextField alloc] initWithFrame:CGRectMake(20, 15, WIDTH(background)-40, HEIGHT(background)-25)];
		[textEntry setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24]];
		[textEntry setTextColor:[UIColor whiteColor]];
		[textEntry setBackgroundColor:[UIColor clearColor]];
		[textEntry setTextAlignment:NSTextAlignmentLeft];
		[textEntry setSpellCheckingType:UITextSpellCheckingTypeNo];
		[textEntry setReturnKeyType:UIReturnKeyDone];
		[textEntry setAutocorrectionType:UITextAutocorrectionTypeNo];
		[textEntry setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[textEntry setPlaceholder:defaultText];
		[self addSubview:textEntry];
    }
    return self;
}

@end
