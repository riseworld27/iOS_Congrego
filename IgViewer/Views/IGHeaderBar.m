//
//  IGHeaderBar.m
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGHeaderBar.h"

@implementation IGHeaderBar

- (id)initWithBackgroundImage:(UIImage *)image
{
    int y = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        y = 20;
    }
    
    self = [super initWithFrame:CGRectMake(0, y, image.size.width, image.size.height)];
    if (self) {
        UIImageView *headerBackground = [[UIImageView alloc] initWithImage:image];
        [self addSubview:headerBackground];
    }
    return self;
}

@end
