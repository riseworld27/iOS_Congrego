//
//  IGViewController.m
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGViewController.h"
#import "IGHeaderBar.h"
#import "IGCarouselView.h"
#import "IGSectionTitleBar.h"
#import "IGListsContainerView.h"
#import "IGHeaderButton.h"
#import "IGListView.h"
#import "IGCellDataObject.h"
#import "IGDetailsWindowView.h"
#import "IGSearchBarView.h"
#import "CoreDataHandler.h"
#import "Product.h"
#import "Category.h"
#import "Collection.h"
#import "Asset.h"
#import "CoreDataDownloadQueue.h"
#import "IGMediaViewerWindow.h"
#import "IGLoginView.h"
#import "Download.h"
#import "ApplicationSetup.h"
#import "CustomBadge.h"
#import "IGSettingViewController.h"
#import "FileUtils.h"
#import "LoginSessionCredentials.h"
#import "CMSUtils.h"
#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "UIColor+ColorWithHex.h"
#import "UIImage+AverageColor.h"
#import "AssessmentSubmissionHandler.h"
#import "Analytics.h"
#import "GenericDataSubmissionHandler.h"

@interface IGViewController ()

@property(nonatomic) int baseY;

@end

@implementation IGViewController

@synthesize isLoggedIn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"applicationBackground.png"]];
    [[self view] addSubview:backgroundView];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _baseY = 20;
    } else {
        _baseY = 0;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    if (mediaViewer) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(void)createMainView
{
    
	willSync = NO;
	isSearching = NO;
	currentSearchResults = [[NSMutableArray alloc] init];
	searchTitles = [[NSMutableArray alloc] init];
	NSMutableArray *productsArray = [CoreDataHandler fetchAllProducts];
	
	carouselView = [[IGCarouselView alloc] initWithItems:productsArray];
    [carouselView setFrame:CGRectMake(0, 74 + _baseY, WIDTH(carouselView), HEIGHT(carouselView))];
	[carouselView setDelegate:self];
    [[self view] addSubview:carouselView];
	
	UIColor *startColor = [UIColor colorWithHexString:@"#000000" andAlpha:0.0];
	if (productsArray.count > 0) {
		Product *prod = (Product *)[productsArray objectAtIndex:0];
		NSString *fileName = [[prod imageFile] stringByReplacingOccurrencesOfString:@".jpg" withString:@".png"];
		NSString *file = [NSString stringWithFormat:@"/resources/bundles/products/%@", fileName];
		NSString *pathToFile = [FileUtils newPath:file create:NO];
		UIImage *image = [UIImage imageWithContentsOfFile:pathToFile];
		startColor = [image averageColor];
	}
    
    sectionTitleBar = [[IGSectionTitleBar alloc] initWithImage:[UIImage imageNamed:@"sectionTitleBarBackground_2.png"] andColor:startColor];
    [sectionTitleBar setFrame:CGRectMake(0, AFTER_Y(carouselView), WIDTH(sectionTitleBar), HEIGHT(sectionTitleBar))];
    [self.view addSubview:sectionTitleBar];
    [sectionTitleBar setDelegate:self];
    
	listsContainer = [[IGListsContainerView alloc] initWithFrame:CGRectMake(0, AFTER_Y(sectionTitleBar), 1024, 383)];
    [[self view] addSubview:listsContainer];
	[listsContainer setDelegate:self];
	
	if ([productsArray count] > 0) {
		Product *product = (Product *)[productsArray objectAtIndex:0];
		currentProduct = product;
		[self updateDataViewsWithProduct:product];
	}
	
	search = [[IGSearchBarView alloc] initWithFrame:CGRectMake(0, _baseY, 1024, 48)];
	
	[[self view] addSubview:search];
	
    headerBar = [[IGHeaderBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"Header Bar Background"]];
    [[self view] addSubview:headerBar];
	[search setDelegate:self];
	[search setHidden:YES];
    
	syncButton = [[IGHeaderButton alloc] initWithIcon:[UIImage imageNamed:@"syncIcon.png"] andTitle:NSLocalizedString(@"HeaderButtonSync", NULL)];
    [syncButton setFrame:CGRectMake(WIDTH(headerBar)-50-WIDTH(syncButton), CENTER_Y(syncButton, headerBar)-3, WIDTH(syncButton), HEIGHT(syncButton))];
    [headerBar addSubview:syncButton];
	[syncButton addTarget:self action:@selector(syncButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
	settingsButton = [[IGHeaderButton alloc] initWithIcon:[UIImage imageNamed:@"settingsIcon.png"] andTitle:NSLocalizedString(@"HeaderButtonSettings", NULL)];
    [settingsButton setFrame:CGRectMake(X(syncButton)-10-WIDTH(settingsButton), CENTER_Y(settingsButton, headerBar)-3, WIDTH(settingsButton), HEIGHT(settingsButton))];
    [headerBar addSubview:settingsButton];
	[settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    IGHeaderButton *btn3 = [[IGHeaderButton alloc] initWithIcon:[UIImage imageNamed:@"searchIcon.png"] andTitle:NSLocalizedString(@"HeaderButtonSearch", NULL)];
    [btn3 setFrame:CGRectMake(X(settingsButton)-10-WIDTH(btn3), CENTER_Y(btn3, headerBar)-3, WIDTH(btn3), HEIGHT(btn3))];
    [headerBar addSubview:btn3];
	[btn3 addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	
	backButton = [[IGHeaderButton alloc] initWithIcon:[UIImage imageNamed:@"backIcon.png"] andTitle:NSLocalizedString(@"HeaderButtonBack", NULL)];
	[backButton setFrame:CGRectMake(X(btn3)-10-WIDTH(backButton), CENTER_Y(backButton, headerBar)-3, WIDTH(backButton), HEIGHT(backButton))];
	[headerBar addSubview:backButton];
	[backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[backButton setHidden:YES];
	
	largeSearchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"largeSearchIcon.png"]];
	[largeSearchIcon setFrame:CGRectMake(CENTER_X(largeSearchIcon, headerBar), AFTER_Y(headerBar)+25, WIDTH(largeSearchIcon), HEIGHT(largeSearchIcon))];
	[self.view addSubview:largeSearchIcon];
	[largeSearchIcon setAlpha:0.0];
	[largeSearchIcon setHidden:YES];
	
	downloadQueue = [[CoreDataDownloadQueue alloc] init];
	[downloadQueue setDelegate:self];
	[self processDownloadQueue];
	
	updateHandler = [[UpdateHandler alloc] init];
	[updateHandler setDelegate:self];
	[updateHandler checkForUpdates];
	
	assessmentSubmissionHandler = [[AssessmentSubmissionHandler alloc] init];
	[assessmentSubmissionHandler submitStoredAssessments];
    
    genericDataSubmissionHandler = [[GenericDataSubmissionHandler alloc] init];
    [genericDataSubmissionHandler submitAllGenericData];
	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

-(void)backButtonPressed
{
	// ************ UNCOMMENT FOR TESTING AUTO LOGIN:
	//[[CMSUtils userCredentials] logout];
	
	/*NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dictionary = [userDefaults dictionaryRepresentation];
    for (id key in dictionary) {
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];*/
	
	[backButton setHidden:YES];
	isSearching = NO;
	[currentSearchResults removeAllObjects];
	[searchTitles removeAllObjects];
	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 [search setFrame:CGRectMake(X(search), _baseY, WIDTH(search), HEIGHT(search))];
						 [largeSearchIcon setAlpha:0.0];
					 }
					 completion:^(BOOL finished) {
						 if (finished) {
							 [search setHidden:YES];
							 [search clear];
							 [largeSearchIcon setHidden:YES];
						 }
					 }];
	NSMutableArray *productsArray = [CoreDataHandler fetchAllProducts];
	[carouselView reloadCarouselWithDataSource:productsArray];
}

-(void)processDownloadQueue
{
	if (downloadQueue) [downloadQueue processQueue];
}

-(void)resetAppForLogin
{
    
    CLS_LOG(@"Resetting app for login");
          
	if (settingPopover) {
		[settingPopover dismissPopoverAnimated:NO];
		settingPopover = NULL;
		settingViewController = NULL;
	}
	
	if (carouselView) {
		[carouselView removeFromSuperview];
		carouselView = NULL;
	}
	
	if (sectionTitleBar) {
		[sectionTitleBar removeFromSuperview];
		sectionTitleBar = NULL;
	}
	
	if (headerBar) {
		[headerBar removeFromSuperview];
		headerBar = NULL;
	}
	
	if (listsContainer) {
		[listsContainer removeFromSuperview];
		listsContainer = NULL;
	}
	
	if (search) {
		[search removeFromSuperview];
		search = NULL;
	}
	
	if (details) {
		[details removeFromSuperview];
		details = NULL;
	}
	
	if (mediaViewer) {
		[mediaViewer removeFromSuperview];
		mediaViewer = NULL;
	}
	
	[self cancelNonEssentialProcesses:YES];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dictionary = [userDefaults dictionaryRepresentation];
    for (id key in dictionary) {
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
	
	LoginProcess *loginProcess = [[LoginProcess alloc] init];
	[loginProcess removeKeychainLoginItems];
	
	[CoreDataHandler clearDatabasesIncludeAppPopulated:YES];
	NSString *resourcesPath = [FileUtils newPath:@"/resources" create:NO];
	[FileUtils listFilesAtPath:resourcesPath];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	[fileManager removeItemAtPath:resourcesPath error:NULL];
	[FileUtils listFilesAtPath:resourcesPath];
	
	if ([CMSUtils isTesting]) [CMSUtils setServer:@"igviewertest.devcloud.acquia-sites.com"];
	
	if ([CMSUtils userCredentials]) {
		[[CMSUtils userCredentials] setDelegate:self];
		[[CMSUtils userCredentials] logout];
	} else {
		CLS_LOG(@"App reset");
		[self displayLoginPage];
	}
    
	
	// !! REMOVE FROM KEYCHAIN
}

-(void)sessionLoggedOutWithErrors:(BOOL)errors
{
	CLS_LOG(@"App reset");
	[self displayLoginPage];
}

-(void)settingsButtonPressed
{
	if (!settingPopover) {
		CGRect popupRect = CGRectMake(855, 10 + _baseY, WIDTH(settingsButton), HEIGHT(settingsButton));
		settingViewController = [[IGSettingViewController alloc] init];
		[settingViewController setDelegate:self];
		settingPopover = [[UIPopoverController alloc] initWithContentViewController:settingViewController];
		[settingPopover setPopoverContentSize:CGSizeMake(300, 80)];
		[settingPopover presentPopoverFromRect:popupRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		[settingPopover setDelegate:self];
	}
}

-(void)shouldLogUserOut
{
	CLS_LOG(@"Log out");
	[self resetAppForLogin];
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	settingPopover = NULL;
	settingViewController = NULL;
}

-(void)cancelNonEssentialProcesses:(BOOL)resetView
{
	[self cancelActiveDownloads];
	if (updateTimer) {
		[updateTimer invalidate];
		updateTimer = NULL;
	}
    if (resetView)
    {
        if (details) [details removeFromSuperview];
        if (mediaViewer) [mediaViewer removeFromSuperview];
    }
}

-(void)checkForUpdates
{
	CLS_LOG(@"Checking for updates...");
	if (updateHandler) {
		[updateHandler checkForUpdates];
	}
	if (assessmentSubmissionHandler) {
		[assessmentSubmissionHandler submitStoredAssessments];
	}
	if (!updateTimer) {
		NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(checkForUpdates)];
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
		[invocation setTarget:self];
		[invocation setSelector:@selector(checkForUpdates)];
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:600.0 invocation:invocation repeats:YES];
	}
}

-(void)updatesAvailableWithCount:(int)count
{
	CLS_LOG(@"Updates count: %i", count);
	[self removeSyncBadge];
	
	if (count > 0) {
		syncBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%i", count]];
		[syncBadge setFrame:CGRectMake(WIDTH(syncButton)-(WIDTH(syncBadge)/2), HEIGHT(syncButton)-(HEIGHT(syncBadge)/2), WIDTH(syncBadge), HEIGHT(syncBadge))];
		[syncButton addSubview:syncBadge];
	}
	
	if (syncAlert) {
		[syncAlert removeFromSuperview];
		syncAlert = NULL;
	}
}

-(void)removeSyncBadge
{
	if (syncBadge) {
		[syncBadge removeFromSuperview];
		syncBadge = NULL;
	}
}

-(void)syncButtonPressed
{
	CLS_LOG(@"Sync");
	//[updateHandler prepareToDownloadUpdates];
	willSync = YES;
	[self initiateValidationWithNetworkWarning:YES];
	
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

-(void)initiateValidationWithNetworkWarning:(BOOL)warning
{	
	if ([[NetworkManager sharedInstance] isConnectionAvailable]) {
		[self cancelActiveDownloads];
		[self displayActivityIndicator];
		if (updateHandler) [updateHandler validateDatabases];
		if (assessmentSubmissionHandler) [assessmentSubmissionHandler submitStoredAssessments];
        if (genericDataSubmissionHandler) [genericDataSubmissionHandler submitAllGenericData];
	} else {
		if (warning) {
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle: @"Sync Error"
								  message: @"RepPresent could not sync at this time, please connect to a Wi-Fi network and try again."
								  delegate: nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
		}
	}
}

-(void)updateFailed
{
	if (syncAlert) {
		[syncAlert removeFromSuperview];
		syncAlert = NULL;
	}
}

-(void)bundlesUpdated
{
	
}

-(void)databaseValidationComplete
{
	[self dismissActivityIndicator];
	if (willSync) {
		willSync = NO;
		[updateHandler prepareToDownloadUpdates];
	} else {
		[self checkForUpdates];
		[downloadQueue processQueue];
	}
	NSMutableArray *productsArray = [CoreDataHandler fetchAllProducts];
	[carouselView reloadCarouselWithDataSource:productsArray];
}

-(void)downloadsAvailableForDownloads:(NSMutableArray *)downloadArray andBundles:(BOOL)bundles
{
	CLS_LOG(@"Download available: %lu", (unsigned long)[downloadArray count]);
	[self removeSyncBadge];
	
	for (int i=0; i<[downloadArray count]; i++) {
		Download *download = (Download *)[downloadArray objectAtIndex:i];
		[download setDownloadDate:NULL];
		[download setDownloaded:[NSNumber numberWithBool:NO]];
		[downloadQueue addDownload:download];
	}
	
	[carouselView reloadCarousel];
}

-(void)shouldSearchForString:(NSString *)searchString
{
	CLS_LOG(@"Search for: %@", searchString);
	[backButton setHidden:NO];
	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 [search setFrame:CGRectMake(X(search), _baseY, WIDTH(search), HEIGHT(search))];
					 }
					 completion:^(BOOL finished) {
						 if (finished) {
							 [search setHidden:YES];
							 [search clear];
						 }
					 }];
	isSearching = YES;
	
	NSMutableArray *emptyArray = [NSMutableArray array];
	[carouselView reloadCarouselWithDataSource:emptyArray];
	
	[sectionTitleBar updateTitleForSectionBar:NSLocalizedString(@"SearchHeaderBarTitle", NULL) andColor:NULL];
	
	[listsContainer clearAllListViews];
	NSMutableArray *collectionArray = [CoreDataHandler fetchAllCollectionsWithSearch:searchString];
	[currentSearchResults addObject:collectionArray];
	NSString *resultsString = NSLocalizedString(@"SearchResultsText", NULL);
	[searchTitles addObject:[NSString stringWithFormat:@"%@ \"%@\"", resultsString, searchString]];
	[listsContainer addListViewWithTitles:searchTitles andCollectionArray:currentSearchResults andDelegate:self];
	
	[largeSearchIcon setHidden:NO];
	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 [largeSearchIcon setAlpha:1.0];
					 }
					 completion:^(BOOL finished) {
						 if (finished) {
						 }
					 }];
}

-(void)downloadFailedWithDownload:(Download *)download
{
	if (details) {
		[details checkAssetForDownloadState];
	}
}

-(void)downloadInQueueDidComplete
{
	if (details) {
		[details checkAssetForDownloadState];
	}
}

-(void)didSelectCellForProduct:(Product *)product
{
	[self updateDataViewsWithProduct:product];
}

-(void)updateDataViewsWithProduct:(Product *)product
{
	if (product) {
		currentProduct = product;
		
		NSString *fileName = [[product imageFile] stringByReplacingOccurrencesOfString:@".jpg" withString:@".png"];
		NSString *file = [NSString stringWithFormat:@"/resources/bundles/products/%@", fileName];
		NSString *pathToFile = [FileUtils newPath:file create:NO];
		UIImage *image = [UIImage imageWithContentsOfFile:pathToFile];
		
		[sectionTitleBar updateTitleForSectionBar:[product title] andColor:[image averageColor]];
		
		[listsContainer clearAllListViews];
		NSArray *categoryArray = [NSArray arrayWithArray:[[product categories] allObjects]];
		NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
		NSMutableArray *displayNameDescriptors = [NSMutableArray arrayWithObject:sorting];
		categoryArray = [categoryArray sortedArrayUsingDescriptors:displayNameDescriptors];
		for (int i=0; i<[[product categories] count]; i++) {
			Category *category = (Category *)[categoryArray objectAtIndex:i];
			IGListView *list = [listsContainer addListViewWithCategory:category];
			[list setDelegate:self];
		}
	}
}

-(void)shouldQueueDownloadForAsset:(Asset *)asset
{
	CLS_LOG(@"Queueing download: %@", [asset title]);
	Download *download = [CoreDataHandler downloadForAsset:asset];
	CLS_LOG(@"Local path: %@", [download localPath]);
	[downloadQueue addDownload:download];
}

- (void)shouldCancelDownloadForAsset:(Asset *) asset
{
    CLS_LOG(@"Cancelling download of %@", asset.title);
    Download *download = [CoreDataHandler downloadForAsset:asset];
    [downloadQueue cancelDownload:download];
    [CoreDataHandler removeDownloadForAsset:asset];
    [CoreDataHandler commit];
    
    // Update the download window
    if (details) {
        [details checkAssetForDownloadState];
    }
}

-(void)shouldDisplayMediaForAsset:(Asset *)asset
{
	CLS_LOG(@"Will display media for: %@", [asset title]);
	
	if ([[asset download] isRecognisedType]) {
		mediaViewer = [[IGMediaViewerWindow alloc] initWithAsset:asset];
		[mediaViewer setDelegate:self];
		[[self view] addSubview:mediaViewer];
		[mediaViewer displayMedia];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
        
        [Analytics openContentWithId:asset.cmsId title:asset.title];
        
	} else {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"Warning: Invalid Media Type"
							  message: @"The selected media type was not recognised and cannot be displayed. Please try re-downloading the asset, if the problem persists contact a CMS administrator."
							  delegate: nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
	}
}

-(void)documentWindowShouldClose
{
	if (mediaViewer) {
		[mediaViewer removeFromSuperview];
		mediaViewer = NULL;
        [Analytics closeContent];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
	}
}

-(void)searchButtonPressed
{
	if ([search isHidden]) {
		[search setHidden:NO];
		[UIView animateWithDuration:0.3
							  delay:0.0
							options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 [search setFrame:CGRectMake(X(search), AFTER_Y(headerBar)-8, WIDTH(search), HEIGHT(search))];
						 }
						 completion:^(BOOL finished) {
							 if (finished) {
								 
							 }
						 }];
	} else {
		[UIView animateWithDuration:0.3
							  delay:0.0
							options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 [search setFrame:CGRectMake(X(search), _baseY, WIDTH(search), HEIGHT(search))];
						 }
						 completion:^(BOOL finished) {
							 if (finished) {
								 [search setHidden:YES];
								 [search clear];
							 }
						 }];
	}
}

-(float)widthForListViews
{
	float listWidth = 240;
	int count = (int) [[currentProduct categories] count];
	if (isSearching) count = (int) [currentSearchResults count];
	if (count < 5) {
		listWidth = roundf(1024/count);
	}
	
	return listWidth;
}

#pragma mark Details Window

-(void)cellSelectedWithCollection:(Collection *)collection
{
	if (details) {
		[details removeFromSuperview];
		details = NULL;
	}
	
	[downloadQueue setProgressDelegate:NULL];
	
	details = [[IGDetailsWindowView alloc] initWithCollection:collection];
	[details setDelegate:self];
	[details setAlpha:0.0];
	[[self view] addSubview:details];
	
	[UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 [details setAlpha:1.0];
					 }
					 completion:^(BOOL finished) {
						 if (finished) {
							 
						 }
					 }];
}

-(void)shouldCloseDetailsView
{
	if (details) {
		[UIView animateWithDuration:0.2
							  delay:0.0
							options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 [details setAlpha:0.0];
						 }
						 completion:^(BOOL finished) {
							 if (finished) {
								 [details removeFromSuperview];
								 details = NULL;
							 }
						 }];
	}
	[downloadQueue setProgressDelegate:self];
	if (listsContainer) {
		[listsContainer updateAllListViews];
	}
}

- (void)requestEmailforAsset:(Asset *)asset
{
    emailVC = [[IGEmailAssetViewController alloc] init];
    emailVC.asset = asset;
    emailVC.delegate = self;
    emailVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:emailVC animated:YES completion:nil];
}

- (void)controller:(IGEmailAssetViewController *)controller didFinishWithResult:(BOOL)sent
{
    [self dismissViewControllerAnimated:controller completion:nil];
}


-(void)downloadDidCompleteDownloadWithNextInQueue:(Download *)download
{
	if (listsContainer) {
		[listsContainer updateAllListViews];
	}
}

-(void)displayLoginPage
{
	isLoggedIn = NO;
	login = [[IGLoginView alloc] initWithUserName:NULL andPassword:NULL];
	[login setDelegate:self];
	[self.view addSubview:login];
	[login login];
}

-(void)userLoggedInWithCredentials:(LoginSessionCredentials *)credentials
{
	if ([CMSUtils isTesting]) [CMSUtils setServer:@"ropecloud.com/igviewer"];
	isLoggedIn = YES;
	[CMSUtils setUserCredentials:credentials];
	
	[login hideContainer];
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityIndicator setFrame:CGRectMake(512-(WIDTH(activityIndicator)/2), 340, WIDTH(activityIndicator), HEIGHT(activityIndicator))];
	[self.view addSubview:activityIndicator];
	[activityIndicator startAnimating];
	
	ApplicationSetup *applicationSetup = [[ApplicationSetup alloc] init];
	[applicationSetup setDelegate:self];
	[applicationSetup setup];
}

-(void)setupComplete
{
	[login removeFromSuperview];
	login = NULL;
	[activityIndicator removeFromSuperview];
	[self createMainView];
}

-(void)setupError
{
	[activityIndicator removeFromSuperview];
    [self dismissActivityIndicator];
    [self resetAppForLogin];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Content" message:@"You logged in successfully but you don't have access to any content. Please ask an admin to grant you access to some content, then log in again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)cancelActiveDownloads
{
	[downloadQueue cancelDownloads];
	NSMutableArray *downloadArray = [CoreDataHandler fetchAllDownloads];
	for (int i=0; i<[downloadArray count]; i++) {
		Download *download = (Download *)[downloadArray objectAtIndex:i];
		if (![[download downloaded] boolValue]) {
			[download setIsDownloading:[NSNumber numberWithBool:NO]];
		}
	}
}

-(void)displayActivityIndicator
{
	/*alertView = [[UIAlertView alloc] initWithTitle:@"Syncing, please wait..." message:@"\n\n"
											delegate:self
								   cancelButtonTitle:nil
								   otherButtonTitles:nil];
	
	UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc]
										initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[loading setFrame:CGRectMake(125, 65, WIDTH(loading), HEIGHT(loading))];
	[alertView addSubview:loading];
	[loading startAnimating];
	[alertView show];*/
	
	syncAlert = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	syncAlert.mode = MBProgressHUDModeIndeterminate;
	syncAlert.labelText = @"Syncing";
}

-(void)dismissActivityIndicator
{
	/*if (alertView) {
		[alertView dismissWithClickedButtonIndex:-1 animated:YES];
	}*/
	if (syncAlert) {
		[syncAlert removeFromSuperview];
		syncAlert = NULL;
	}
}

/*-(BOOL)shouldAutorotate
{
	return NO;
}*/

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	BOOL rotate = NO;
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		rotate = YES;
	}
	
	return rotate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showAllLists
{
    [UIView animateWithDuration:.5
                          delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (sectionTitleBar.frame.origin.y == AFTER_Y(carouselView)) {
                             [sectionTitleBar setFrame:CGRectMake(0, carouselView.frame.origin.y, sectionTitleBar.frame.size.width, sectionTitleBar.frame.size.height)];
                             [listsContainer setFrame:CGRectMake(0, carouselView.frame.origin.y + sectionTitleBar.frame.size.height, sectionTitleBar.frame.size.width, [[UIScreen mainScreen] bounds].size.height - carouselView.frame.origin.y - sectionTitleBar.frame.size.height )];
                             [carouselView setAlpha:0.0];
                             [sectionTitleBar spinTheButton];
                         } else {
                             [sectionTitleBar setFrame:CGRectMake(0, AFTER_Y(carouselView), sectionTitleBar.frame.size.width, sectionTitleBar.frame.size.height)];
                             [listsContainer setFrame:CGRectMake(0, AFTER_Y(carouselView) + sectionTitleBar.frame.size.height, listsContainer.frame.size.width, 383)];
                             [carouselView setAlpha:1.0];
                             [sectionTitleBar spinTheButton];
                         }
                     } completion:^(BOOL finished) {
                         [listsContainer updateAllListViews];
                     }];
}

@end
