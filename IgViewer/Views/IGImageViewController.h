//
//  IGImageViewController.h
//  IgViewer
//
//  Created by matata on 20/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGImageViewController : UIViewController
{
	NSURL *file;
	UIImageView *imageView;
}

-(id)initWithPathToFile:(NSString *)path;

@end
