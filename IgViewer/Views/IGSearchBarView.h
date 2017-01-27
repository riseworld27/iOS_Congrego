//
//  IGSearchBarView.h
//  IgViewer
//
//  Created by matata on 13/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IGSearchBarViewDelegate <NSObject>

@optional
-(void)shouldSearchForString:(NSString *)search;

@end

@interface IGSearchBarView : UIView

@property (nonatomic, weak) id <IGSearchBarViewDelegate> delegate;
@property (nonatomic, retain) UITextField *searchField;

-(void)clear;

@end
