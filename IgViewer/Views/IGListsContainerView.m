//
//  IGListsContainerView.m
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGListsContainerView.h"
#import "IGListView.h"
#import "IGCellDataObject.h"
#import "Collection.h"
#import "Category.h"
#import "Asset.h"
#import "CoreDataHandler.h"

@implementation IGListsContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        listViews = [[NSMutableArray alloc] init];
    }
    return self;
}

-(IGListView *)addListViewWithTitle:(NSString *)listTitle
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
	int rndItems = RND(1, 10);
	
	for (int i=0; i<rndItems; i++) {
		IGCellDataObject *obj = [[IGCellDataObject alloc] init];
		[obj setTitle:@"Lorum Ipsum"];
		[obj setSubTitle:@"Sub title"];
		
		int rndIcon = RND(0, 2);
		NSString *iconName = [NSString stringWithFormat:@"icon%i.png", rndIcon];
		[obj setIconFile:iconName];
		
		[obj setDownloaded:(RND(0, 1) > 0) ? YES : NO];
		
		[array addObject:obj];
	}

    IGListView *list = [[IGListView alloc] initWithFrame:CGRectMake(240*[listViews count], 0, 240, self.frame.size.height) title:listTitle andItems:array];
    [self addSubview:list];
    [listViews addObject:list];
    [self setContentSize:CGSizeMake(240*[listViews count], 383)];
    
    return list;
}

-(IGListView *)addListViewWithCategory:(Category *)category
{
    NSArray *collectionArray = [NSArray arrayWithArray:[[category collections] allObjects]];
	NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSMutableArray *displayNameDescriptors = [NSMutableArray arrayWithObject:sorting];
	collectionArray = [collectionArray sortedArrayUsingDescriptors:displayNameDescriptors];
    
	float listWidth = 240;
	if ([[self delegate] respondsToSelector:@selector(widthForListViews)]) {
		listWidth = [[self delegate] widthForListViews];
	}
    IGListView *list = [[IGListView alloc] initWithFrame:CGRectMake(listWidth*[listViews count], 0, listWidth, self.frame.size.height) title:[category title] andItems:collectionArray];
    [self addSubview:list];
    [listViews addObject:list];
    [self setContentSize:CGSizeMake(listWidth*[listViews count], 383)];
    
    return list;
}

-(void)addListViewWithTitles:(NSArray *)titles andCollectionArray:(NSArray *)searchResultsArray andDelegate:(id<IGListViewDelegate>)listDelegate
{
	for (int i=0; i<[searchResultsArray count]; i++) {
		NSArray *collectionArray = (NSArray *)[searchResultsArray objectAtIndex:i];
		NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
		NSMutableArray *displayNameDescriptors = [NSMutableArray arrayWithObject:sorting];
		collectionArray = [collectionArray sortedArrayUsingDescriptors:displayNameDescriptors];
		float listWidth = 240;
		if ([[self delegate] respondsToSelector:@selector(widthForListViews)]) {
			listWidth = [[self delegate] widthForListViews];
		}
		IGListView *list = [[IGListView alloc] initWithFrame:CGRectMake(listWidth*[listViews count], 0, listWidth, 383) title:(NSString *)[titles objectAtIndex:i] andItems:collectionArray];
		[self addSubview:list];
		[listViews addObject:list];
		[self setContentSize:CGSizeMake(listWidth*[listViews count], 383)];
		[list setDelegate:listDelegate];
	}
}

-(void)clearAllListViews
{
	for (int i=0; i<[listViews count]; i++) {
		IGListView *list = (IGListView *)[listViews objectAtIndex:i];
		[list removeFromSuperview];
	}
	
	[listViews removeAllObjects];
}

-(void)updateAllListViews
{
	for (int i=0; i<[listViews count]; i++) {
        IGListView *list = (IGListView *)[listViews objectAtIndex:i];
        [list setFrame:CGRectMake(list.frame.origin.x, list.frame.origin.y, list.frame.size.width, self.frame.size.height)];
		[[list table] reloadData];
	}
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    for (int i = 0; i < listViews.count; i++) {
        IGListView *list = (IGListView *)[listViews objectAtIndex:i];
        [list setFrame:CGRectMake(list.frame.origin.x, list.frame.origin.y, list.frame.size.width, frame.size.height)];
    }
}

@end
