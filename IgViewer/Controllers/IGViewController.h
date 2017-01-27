//
//  IGViewController.h
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGListView.h"
#import "IGDetailsWindowView.h"
#import "IGCarouselView.h"
#import "IGListsContainerView.h"
#import "IGMediaViewerWindow.h"
#import "IGSectionTitleBar.h"
#import "CoreDataDownloadQueue.h"
#import "IGLoginView.h"
#import "ApplicationSetup.h"
#import "IGSearchBarView.h"
#import "UpdateHandler.h"
#import "IGSettingViewController.h"
#import "LoginSessionCredentials.h"
#import "IGEmailAssetViewController.h"

@class IGHeaderBar, IGCarouselView, IGSectionTitleBar, IGListsContainerView, IGDetailsWindowView, IGSearchBarView, CoreDataDownloadQueue, IGMediaViewerWindow, IGLoginView, CustomBadge, IGHeaderButton, IGSettingViewController, LoginSessionCredentials, MBProgressHUD, AssessmentSubmissionHandler, GenericDataSubmissionHandler;

@interface IGViewController : UIViewController <IGListViewDelegate, IGDetailsWindowViewDelegate, IGCarouselViewDelegate, IGListsContainerViewDelegate, IGMediaViewerWindowDelegate, IGSectionTitleBarDelegate,  CoreDataDownloadQueueDelegate, IGLoginViewDelegate, ApplicationSetupDelegate, CoreDataDownloadQueueProgressDelegate, IGSearchBarViewDelegate, UpdateHandlerDelegate, UIPopoverControllerDelegate, IGSettingViewControllerDelegate, LoginSessionCredentialsDelegate, UIAlertViewDelegate, IGEmailAssetViewControllerDelegate>
{
    IGHeaderBar *headerBar;
    IGCarouselView *carouselView;
    IGSectionTitleBar *sectionTitleBar;
    IGListsContainerView *listsContainer;
	IGDetailsWindowView *details;
	IGSearchBarView *search;
	Product *currentProduct;
	CoreDataDownloadQueue *downloadQueue;
	IGMediaViewerWindow *mediaViewer;
	IGLoginView *login;
	UIActivityIndicatorView *activityIndicator;
	CustomBadge *syncBadge;
	UpdateHandler *updateHandler;
	IGHeaderButton *syncButton;
	IGHeaderButton *settingsButton;
	IGHeaderButton *backButton;
	NSTimer *updateTimer;
	UIPopoverController *settingPopover;
	IGSettingViewController *settingViewController;
	LoginSessionCredentials *currentUserCredentials;
	UIAlertView *alertView;
	BOOL willSync;
	UIImageView *largeSearchIcon;
	BOOL isSearching;
	NSMutableArray *currentSearchResults;
	NSMutableArray *searchTitles;
	MBProgressHUD *syncAlert;
	AssessmentSubmissionHandler *assessmentSubmissionHandler;
    GenericDataSubmissionHandler *genericDataSubmissionHandler;
    IGEmailAssetViewController *emailVC;
}

@property (nonatomic) BOOL isLoggedIn;

-(void)createMainView;
-(void)updateDataViewsWithProduct:(Product *)product;
-(void)displayLoginPage;
-(void)cancelActiveDownloads;
-(void)checkForUpdates;
-(void)cancelNonEssentialProcesses:(BOOL)resetView;
-(void)processDownloadQueue;
-(void)initiateValidationWithNetworkWarning:(BOOL)warning;

@end
