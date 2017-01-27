//
//  IGListView.m
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGListView.h"
#import "IGTableViewCell.h"
#import "IGCellDataObject.h"
#import "Collection.h"
#import "FileUtils.h"
#import "Asset.h"
#import "Download.h"

@implementation IGListView

@synthesize table, background;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title andItems:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listSectionBackground.png"]];
		[background setFrame:CGRectMake(X(background), Y(background), frame.size.width, frame.size.height)];
        [background setContentMode:UIViewContentModeScaleAspectFill];
		[background setClipsToBounds:YES];
        [self addSubview:background];
        
        listItems = [NSArray arrayWithArray:items];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 25)];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:title];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:label];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(3, AFTER_Y(label)+20, WIDTH(self)-6, self.frame.size.height - 65)];
        [table setDelegate:self];
        [table setDataSource:self];
        [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [table setBackgroundColor:[UIColor clearColor]];
        [self addSubview:table];
        
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IGTableViewCell *cell = (IGTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"igTableViewCell"];
    
    if (!cell) {
        cell = [[IGTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"igTableViewCell"];
    }
    
	[cell setAssetDownloaded:NO];
	Collection *collection = (Collection *)[listItems objectAtIndex:indexPath.row];
	NSArray *assetArray = (NSArray *)[[collection assets] allObjects];
	for (int i=0; i<[assetArray count]; i++) {
		Asset *asset = (Asset *)[assetArray objectAtIndex:i];
		if ([[[asset download] downloaded] boolValue]) {
			[cell setAssetDownloaded:YES];
			break;
		}
        
        // If this is a link to an app
        if ([asset.assetType isEqualToNumber:[NSNumber numberWithInt:7]]) {
            [cell setAssetDownloaded:YES];
            break;
        }
	}

	NSString *iconPath = [FileUtils newPath:@"/resources/bundles/icons/" create:NO];
    iconPath = [iconPath stringByAppendingPathComponent:[collection iconFile]];
	
    //CLS_LOG(@"Asset icon: %@", iconPath);
    [[cell cellLabel] setText:[collection title]];
	[[cell cellSubLabel] setText:[collection subTitle]];
    
	[cell setIcon:[UIImage imageWithContentsOfFile:iconPath]];
	[cell updateBadgeWithCount:((int)[[collection assets] count])];
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Collection *collection = (Collection *)[listItems objectAtIndex:indexPath.row];
	
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(cellSelectedWithCollection:)]) {
		[[self delegate] cellSelectedWithCollection:collection];
	}
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [background setFrame:CGRectMake(X(background), Y(background), frame.size.width, frame.size.height)];
    [table setFrame:CGRectMake(3, table.frame.origin.y, WIDTH(self)-6, self.frame.size.height - 65)];
}

@end
