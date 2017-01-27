//
//  IGDetailsViewIcon.h
//  IgViewer
//
//  Created by matata on 05/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGDetailsViewIcon : UIView
{
	UIImageView *iconOpaque;
	UIImageView *iconAlpha;
	UIView *iconOpaqueContainer;
}

-(id)initWithPathForIcon:(NSString *)path;
-(void)updateWithPercent:(float)percent;
-(void)setComplete;

@end
