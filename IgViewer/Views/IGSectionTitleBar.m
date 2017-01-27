//
//  IGSectionTitleBar.m
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGSectionTitleBar.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Expanded.h"

@implementation IGSectionTitleBar

- (id)initWithImage:(UIImage *)image andColor:(UIColor *)color
{
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:imageView];
		
		gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 1.5, self.frame.size.width, 39)];
		[self addSubview:gradientView];
		
		[self updateGradientWithColor:color];
        
		label = [[UILabel alloc] initWithFrame:self.frame];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0]];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:@""];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:label];
        
        closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [closeButton setImage:[UIImage imageNamed:@"up_arrow.png"] forState:UIControlStateNormal];
        [closeButton setTintColor:[UIColor whiteColor]];
        [closeButton addTarget:self action:@selector(moreButton:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton sizeToFit];
        [closeButton setFrame:CGRectMake(self.frame.size.width -closeButton.frame.size.width - 8, (self.frame.size.height - closeButton.frame.size.height) / 2, closeButton.frame.size.width, closeButton.frame.size.height)];
        [self addSubview:closeButton];
    }
    return self;
}

-(void)updateGradientWithColor:(UIColor *)color
{
	if (gradientLayer) {
		[gradientLayer removeFromSuperlayer];
		gradientLayer = NULL;
	}
	
	if (!color) {
		color = [UIColor colorWithHexString:@"#000000"];
	}
	
	const CGFloat* colors = CGColorGetComponents(color.CGColor);
	
	gradientLayer = [CAGradientLayer layer];
	
    UIColor *leftColor = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:0.0];
    UIColor *midColor = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:1.0];
	UIColor *rightColor = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:0.0];
	
    gradientLayer.colors = [NSArray arrayWithObjects:(id)leftColor.CGColor, midColor.CGColor, rightColor.CGColor, nil];
	
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil];
	
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(1, 0);
	
    gradientLayer.startPoint = startPoint;
    gradientLayer.frame = CGRectMake(0, 0, gradientView.frame.size.width, gradientView.frame.size.height);
    gradientLayer.endPoint = endPoint;
	
    [gradientView.layer addSublayer:gradientLayer];
}

-(void)updateTitleForSectionBar:(NSString *)title andColor:(UIColor *)color
{
	[label setText:title];
	[self updateGradientWithColor:color];
}

-(void)moreButton:(UIButton *)button
{
    [self.delegate showAllLists];
}

- (void) spinTheButton {
    closeButton.transform = CGAffineTransformRotate(closeButton.transform, M_PI);
}

@end
