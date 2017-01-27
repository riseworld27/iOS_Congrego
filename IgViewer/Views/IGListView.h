//
//  IGListView.h
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IGCellDataObject, Collection;

@protocol IGListViewDelegate <NSObject>

@optional
-(void)cellSelectedWithCollection:(Collection *)collection;

@end

@interface IGListView : UIView <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *listItems;
}

@property (nonatomic, retain) id <IGListViewDelegate> delegate;
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) UIImageView *background;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title andItems:(NSArray *)items;

@end
