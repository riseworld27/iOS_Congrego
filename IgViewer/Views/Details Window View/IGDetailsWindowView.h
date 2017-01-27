//
//  IGDetailsWindowView.h
//  IgViewer
//
//  Created by matata on 12/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGDetailsView.h"
#import "CoreDataDownloadQueue.h"

@class Collection, Asset, IGDetailsViewIcon;

@protocol IGDetailsWindowViewDelegate <NSObject>

@optional
-(void)shouldCloseDetailsView;
-(void)shouldQueueDownloadForAsset:(Asset *)asset;
-(void)shouldDisplayMediaForAsset:(Asset *)asset;
-(void)shouldCancelDownloadForAsset:(Asset *)asset;
-(void)requestEmailforAsset:(Asset *)asset;
@end

@interface IGDetailsWindowView : UIView <IGDetailsViewDelegate, CoreDataDownloadQueueProgressDelegate>
{
	Collection *collection;
	IGDetailsViewIcon *icon;
	NSMutableArray *detailViews;
}

@property (nonatomic, retain) id <IGDetailsWindowViewDelegate> delegate;

- (id)initWithCollection:(Collection *)collectionForView;
-(void)checkAssetForDownloadState;

@end
