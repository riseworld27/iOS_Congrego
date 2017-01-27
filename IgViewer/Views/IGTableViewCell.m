//
//  IGTableViewCell.m
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGTableViewCell.h"
#import "CustomBadge.h"

@implementation IGTableViewCell

@synthesize cellLabel, cellSubLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 14, 160, 16)];
        [cellLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
        [cellLabel setTextColor:[UIColor whiteColor]];
        [cellLabel setBackgroundColor:[UIColor clearColor]];
        [cellLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:cellLabel];
		
		cellSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, AFTER_Y(cellLabel)-2, 160, 20)];
        [cellSubLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
        [cellSubLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
        [cellSubLabel setBackgroundColor:[UIColor clearColor]];
        [cellSubLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:cellSubLabel];
		
		icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 45, 45)];
		[icon setFrame:CGRectMake(X(icon), CENTER_Y(icon, self)+7, WIDTH(icon), HEIGHT(icon))];
		[icon setContentMode:UIViewContentModeScaleAspectFit];
		[self addSubview:icon];
        
        [self setBackgroundColor:[UIColor clearColor]];
		
		badge = [CustomBadge customBadgeWithString:@"3" withStringColor:[UIColor colorWithWhite:1.0 alpha:0.8] withInsetColor:[UIColor colorWithWhite:0.0 alpha:0.9] withBadgeFrame:YES withBadgeFrameColor:[UIColor colorWithWhite:1.0 alpha:0.5] withScale:0.6 withShining:YES];
		[badge setBadgeFrameStrokeWidth:1.0];
		[badge setFrame:CGRectMake(AFTER_X(icon)-(WIDTH(badge)/2)-1, AFTER_Y(icon)-(HEIGHT(badge)/2)-3, WIDTH(badge), HEIGHT(badge))];
		[self addSubview:badge];
		[badge setHidden:YES];
    }
    return self;
}

-(void)updateBadgeWithCount:(int)count
{
	if (count > 1) {
		[badge setBadgeText:[NSString stringWithFormat:@"%i", count]];
		[badge setHidden:NO];
	} else {
		[badge setHidden:YES];
	}
}

-(void)setAssetDownloaded:(BOOL)downloaded
{
	float cellAlpha = (downloaded) ? 1.0 : 0.4;
	
	[cellLabel setAlpha:cellAlpha];
	[cellSubLabel setAlpha:cellAlpha];
	[icon setAlpha:cellAlpha];
}

-(void)setIcon:(UIImage *)image
{
	[icon setImage:image];
	/*[icon setFrame:CGRectMake(X(icon), Y(icon), image.size.width, image.size.height)];
	[icon setFrame:CGRectMake(X(icon), CENTER_Y(icon, self)+7, WIDTH(icon), HEIGHT(icon))];*/
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
