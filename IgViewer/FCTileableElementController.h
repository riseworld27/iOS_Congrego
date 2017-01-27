//
//  FCTileableElementController.h
//  Falcon
//
//  Created by matata on 08/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCTileableElementController : NSObject

@property (nonatomic, retain) UIImageView *leftSection;
@property (nonatomic, retain) UIImageView *rightSection;
@property (nonatomic, retain) UIView *tiledSection;
@property (nonatomic, retain) UIView *container;

- (id)initWithLeftCap:(UIImage *)leftCap rightCap:(UIImage *)rightCap andTile:(UIImage *)tile;
-(void)updateTileWidth:(float)tileWidth;
-(float)widthOfButton;
-(float)tileWidth;

@end
