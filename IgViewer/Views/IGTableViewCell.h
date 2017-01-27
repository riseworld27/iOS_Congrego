//
//  IGTableViewCell.h
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomBadge;

@interface IGTableViewCell : UITableViewCell
{
	UIImageView *icon;
	CustomBadge *badge;
}

@property (nonatomic, retain) UILabel *cellLabel;
@property (nonatomic, retain) UILabel *cellSubLabel;

-(void)setAssetDownloaded:(BOOL)downloaded;
-(void)setIcon:(UIImage *)image;
-(void)updateBadgeWithCount:(int)count;

@end
