//
//  IGLogOutButton.h
//  IgViewer
//
//  Created by matata on 13/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGLogoutButton : UIControl
{
	UIImageView *defaultImageView;
	UIImageView *selectedImageView;
}

- (id)initWithDefaultImage:(UIImage *)defaultImage andSelectedImage:(UIImage *)selectedImage;

@end
