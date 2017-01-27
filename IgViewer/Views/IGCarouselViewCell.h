//
//  IGCarouselViewCell.h
//  IgViewer
//
//  Created by matata on 01/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReflectionView.h"

@interface IGCarouselViewCell : ReflectionView
{
	UIImageView *imageView;
}

@property (nonatomic, retain) NSString *imageBasePath;

-(id)initWithImageAtPath:(NSString *)path;
-(void)updateImageWithImageAtPath:(NSString *)path;

@end
