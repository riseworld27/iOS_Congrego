//
//  IGLoginButton.h
//  IgViewer
//
//  Created by matata on 06/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGLoginButton : UIControl
{
	UIImageView *defaultBackground;
	UIImageView *selectedBackground;
}

- (id)initWithDefaultImage:(UIImage *)defaultImage andSelectedImage:(UIImage *)selectedImage;

@end
