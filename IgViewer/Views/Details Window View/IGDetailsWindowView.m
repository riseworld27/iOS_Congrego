//
//  IGDetailsWindowView.m
//  IgViewer
//
//  Created by matata on 12/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGDetailsWindowView.h"
#import "IGDetailsView.h"
#import "IGDetailsObject.h"
#import "Collection.h"
#import "FileUtils.h"
#import "IGDetailsViewIcon.h"
#import "CoreDataDownloadQueue.h"
#import "Download.h"
#import "Asset.h"

@implementation IGDetailsWindowView

- (id)initWithCollection:(Collection *)collectionForView
{
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    if (self) {
		collection = collectionForView;
		
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
		
		UIImage *image = [UIImage imageNamed:@"detailsWindowHeaderBarBackground.png"];
		UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
		
		UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailsWindowBackground.png"]];
		[backgroundImage setFrame:CGRectMake(0, image.size.height-2, WIDTH(backgroundImage), HEIGHT(backgroundImage))];
		[container addSubview:backgroundImage];
		
        UIImageView *headerBar = [[UIImageView alloc] initWithImage:image];
		[headerBar setFrame:CGRectMake(0, 0, WIDTH(headerBar), HEIGHT(headerBar))];
		[container addSubview:headerBar];
		
		UILabel *label = [[UILabel alloc] initWithFrame:headerBar.frame];
		[label setText:[collection title]];
		[label setTextColor:[UIColor colorWithRed:COLOR(113) green:COLOR(120) blue:COLOR(128) alpha:1.0]];
		[label setShadowColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
		[label setShadowOffset:CGSizeMake(0, 1)];
		[label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0]];
		[label setUserInteractionEnabled:NO];
		[label setTextAlignment:NSTextAlignmentCenter];
		[label setBackgroundColor:[UIColor clearColor]];
		[container addSubview:label];
		
        UIButton *newBackButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [newBackButton setTitle:NSLocalizedString(@"DetailsWindowBackButton", NULL) forState:UIControlStateNormal];
        [newBackButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newBackButton setFrame:CGRectMake(10, 7, WIDTH(newBackButton), HEIGHT(newBackButton))];
        [newBackButton setTintColor:[UIColor colorWithRed:COLOR(113) green:COLOR(120) blue:COLOR(128) alpha:1.0]];
        [newBackButton sizeToFit];
        [container addSubview:newBackButton];
		
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(170, AFTER_Y(headerBar), 770, backgroundImage.frame.size.height-2)];
		[container addSubview:scrollView];
		
		detailViews = [[NSMutableArray alloc] init];
		
		CoreDataDownloadQueue *queue = [CoreDataDownloadQueue sharedInstance];
		Asset *currentlyDownloadingAsset = NULL;
		
		NSArray *assetArray = [NSArray arrayWithArray:[[collection assets] allObjects]];
		
		NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
		NSMutableArray *displayNameDescriptors = [NSMutableArray arrayWithObject:sorting];
		assetArray = [assetArray sortedArrayUsingDescriptors:displayNameDescriptors];
		
		float cumulativeHeight = 0;
		for (int i = 0; i<[assetArray count]; i++) {
			Asset *asset = (Asset *)[assetArray objectAtIndex:i];
			IGDetailsView *detailsView = [[IGDetailsView alloc] initWithAsset:asset];
			[detailsView setFrame:CGRectMake(0, cumulativeHeight, WIDTH(detailsView), HEIGHT(detailsView))];
			cumulativeHeight += HEIGHT(detailsView);
			[detailsView setDelegate:self];
			[scrollView addSubview:detailsView];
			
			if ([queue isAssetDownloading:asset]) currentlyDownloadingAsset = asset;
			
			if (i == [assetArray count]-1) {
				[detailsView setUseSeparator:NO];
			}
			
			[detailViews addObject:detailsView];
		}
		
		if (currentlyDownloadingAsset) {
			[queue setProgressDelegate:self];
		}
		
		[scrollView setContentSize:CGSizeMake(770, cumulativeHeight)];
		
		NSString *iconPath = [FileUtils newPath:@"/resources/bundles/icons/" create:NO];
		iconPath = [iconPath stringByAppendingPathComponent:[collection iconFile]];
		
		icon = [[IGDetailsViewIcon alloc] initWithPathForIcon:iconPath];
		[icon setFrame:CGRectMake(25, AFTER_Y(headerBar)+20, WIDTH(icon), HEIGHT(icon))];
		[container addSubview:icon];
		
		float windowHeight = HEIGHT(headerBar)+cumulativeHeight;
		if (cumulativeHeight > backgroundImage.frame.size.height) windowHeight = backgroundImage.frame.size.height+HEIGHT(headerBar);
		
		[container setClipsToBounds:YES];
		[container setFrame:CGRectMake(0, 0, WIDTH(headerBar), windowHeight)];
		[container setFrame:CGRectMake(CENTER_X(container, self), CENTER_Y(container, self), WIDTH(container), HEIGHT(container))];
		[self addSubview:container];
    }
    return self;
}

-(void)downloadDidUpdateProgressWithPercent:(float)percent
{
	[icon updateWithPercent:percent];
}

-(void)downloadDidCompleteDownloadWithNextInQueue:(Download *)download
{
	[icon setComplete];
	CoreDataDownloadQueue *queue = [CoreDataDownloadQueue sharedInstance];
	if (download) {
		Asset *currentlyDownloadingAsset = NULL;
		NSArray *assetArray = [NSArray arrayWithArray:[[collection assets] allObjects]];
		for (int i = 0; i<[assetArray count]; i++) {
			Asset *asset = (Asset *)[assetArray objectAtIndex:i];
			if ([asset download]) {
				if ([download isEqualToDownload:[asset download]]) currentlyDownloadingAsset = asset;
			}
		}
		if (!currentlyDownloadingAsset) {
			[queue setProgressDelegate:NULL];
		}
	} else {
		[queue setProgressDelegate:NULL];
	}
	
	for (int i=0; i<[detailViews count]; i++) {
		IGDetailsView *detailView = (IGDetailsView *)[detailViews objectAtIndex:i];
		[detailView updateCaptionForButton];
	}
}

-(void)shouldBeginDownloadForAsset:(Asset *)asset
{
	if ([[self delegate] respondsToSelector:@selector(shouldQueueDownloadForAsset:)]) {
		[[self delegate] shouldQueueDownloadForAsset:asset];
	}
	
	CoreDataDownloadQueue *queue = [CoreDataDownloadQueue sharedInstance];
	if ([queue progressDelegate] != self) {
		if ([queue isAssetDownloading:asset]) {
			[queue setProgressDelegate:self];
		}
	}
	
	for (int i=0; i<[detailViews count]; i++) {
		IGDetailsView *detailView = (IGDetailsView *)[detailViews objectAtIndex:i];
		[detailView updateCaptionForButton];
	}
}

-(void)shouldCancelDownloadForAsset:(Asset *)asset
{
    if ([[self delegate] respondsToSelector:@selector(shouldCancelDownloadForAsset:)]) {
        [[self delegate] shouldCancelDownloadForAsset:asset];
        [self downloadDidUpdateProgressWithPercent:1.0f];
    }
}

-(void)checkAssetForDownloadState
{
	CoreDataDownloadQueue *queue = [CoreDataDownloadQueue sharedInstance];
	Asset *currentlyDownloadingAsset = NULL;
	NSArray *assetArray = [NSArray arrayWithArray:[[collection assets] allObjects]];
	for (int i = 0; i<[assetArray count]; i++) {
		Asset *asset = (Asset *)[assetArray objectAtIndex:i];
		if ([queue isAssetDownloading:asset]) currentlyDownloadingAsset = asset;
	}
	
	if (currentlyDownloadingAsset) {
		[queue setProgressDelegate:self];
	}
	
	for (int i=0; i<[detailViews count]; i++) {
		IGDetailsView *detailView = (IGDetailsView *)[detailViews objectAtIndex:i];
		[detailView updateCaptionForButton];
	}
}

-(void)shouldDisplayDownloadForAsset:(Asset *)asset
{
	if ([[self delegate] respondsToSelector:@selector(shouldDisplayMediaForAsset:)]) {
		[[self delegate] shouldDisplayMediaForAsset:asset];
	}
}

-(void)backButtonPressed:(id)sender
{
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(shouldCloseDetailsView)]) [[self delegate] shouldCloseDetailsView];
}

-(void)requestEmailforAsset:(Asset *)asset
{
    [self.delegate requestEmailforAsset:asset];
}

@end
