//
//  IGListsContainerView.h
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGListView.h"

@class IGListView, Category;

@protocol IGListsContainerViewDelegate <UIScrollViewDelegate>

@optional
-(float)widthForListViews;

@end

@interface IGListsContainerView : UIScrollView
{
    NSMutableArray *listViews;
}

@property (nonatomic, weak) id <IGListsContainerViewDelegate> delegate;

-(IGListView *)addListViewWithTitle:(NSString *)listTitle;
-(IGListView *)addListViewWithCategory:(Category *)category;
-(void)clearAllListViews;
-(void)updateAllListViews;
-(void)addListViewWithTitles:(NSArray *)titles andCollectionArray:(NSArray *)searchResultsArray andDelegate:(id<IGListViewDelegate>)listDelegate;

@end
