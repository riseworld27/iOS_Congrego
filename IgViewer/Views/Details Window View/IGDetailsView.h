//
//  IGDetailsView.h
//  IgViewer
//
//  Created by matata on 12/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IGDetailsObject, Asset, UISegmentedControl, IGButton;

@protocol IGDetailsViewDelegate <NSObject>

@optional
-(void)shouldBeginDownloadForAsset:(Asset *)asset;
-(void)shouldDisplayDownloadForAsset:(Asset *)asset;
-(void)shouldCancelDownloadForAsset:(Asset *)asset;
-(void)requestEmailforAsset:(Asset *)asset;
@end

@interface IGDetailsView : UIView
{
	Asset *asset;
	IGButton *button;
    IGButton *cancelButton;
	IGButton *deleteButton;
    IGButton *sendEmailButton;
	UIImageView *horizonatlSeparator;
    UILabel *body;
}

@property (nonatomic, retain) id <IGDetailsViewDelegate> delegate;
@property (nonatomic) BOOL useSeparator;

- (id)initWithAsset:(Asset *)assetForView;
-(void)updateCaptionForButton;

@end
