//
//  IGHeaderButton.m
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGHeaderButton.h"

@implementation IGHeaderButton

- (id)initWithIcon:(UIImage *)icon andTitle:(NSString *)title
{
    UIImage *backgroundImage = [UIImage imageNamed:@"headerButtonBackground.png"];
    self = [super initWithFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    if (self) {
        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:background];
		
		UIImageView *iconImage = [[UIImageView alloc] initWithImage:icon];
		[iconImage setFrame:CGRectMake(CENTER_X(iconImage, self), CENTER_Y(iconImage, self)-8, WIDTH(iconImage), HEIGHT(iconImage))];
		[self addSubview:iconImage];
		
		UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, HEIGHT(self)-20, WIDTH(self), 15)];
        [buttonLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
        [buttonLabel setTextColor:[UIColor whiteColor]];
        [buttonLabel setBackgroundColor:[UIColor clearColor]];
        [buttonLabel setTextAlignment:NSTextAlignmentCenter];
		[buttonLabel setText:title];
		[buttonLabel setAlpha:0.6];
        [self addSubview:buttonLabel];
    }
    return self;
}

@end
