//
//  IGSectionTitleBar.h
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol IGSectionTitleBarDelegate <UIScrollViewDelegate>

-(void)showAllLists;

@end

@interface IGSectionTitleBar : UIView
{
	UILabel *label;
	UIView *gradientView;
    UIButton *closeButton;
	CAGradientLayer *gradientLayer;
}

@property (nonatomic, weak) id <IGSectionTitleBarDelegate> delegate;

- (id)initWithImage:(UIImage *)image andColor:(UIColor *)color;
- (void) spinTheButton;
-(void)updateTitleForSectionBar:(NSString *)title andColor:(UIColor *)color;
-(void)updateGradientWithColor:(UIColor *)color;

@end
