//
//  IGMediaViewerWindow.m
//  IgViewer
//
//  Created by matata on 05/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGMediaViewerWindow.h"
#import "Asset.h"
#import "Download.h"
#import "FileUtils.h"
#import "AssetDownload.h"
#import <QuickLook/QuickLook.h>
#import "IGMoviePlaybackController.h"
#import "IGWebViewController.h"
#import "IGAudioPlaybackController.h"
#import "IGImageViewController.h"
#import "IGMediaViewNavigationController.h"

#import "CMSUtils.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPRequestOperation.h"
#import <ReaderDocument.h>
#import "VFRReaderDocNoShare.h"

@implementation IGMediaViewerWindow

-(id)initWithAsset:(Asset *)asset
{
	self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
	if (self) {
		[self setBackgroundColor:[UIColor blackColor]];
		
		currentAsset = asset;
		currentDownload = [asset download];
		pathToFile = [currentDownload absolutePathToFile];
		
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
		
		navigationController = [[IGMediaViewNavigationController alloc] init];
		
		[[navigationController view] setFrame:CGRectMake(0, 0, 1024, 768)];
		[self addSubview:navigationController.view];
	}
	return self;
}

-(void)displayMedia
{
	currentController = NULL;
	
	if (currentDownload) {
        if ([[currentDownload fileType] intValue] == AssetFileTypePdf) {
            if ([[currentAsset assetFormat] isEqualToString:@"application/pdf"]) {
                currentController = [self displayViewerForPdfMedia];
            } else {
                currentController = [self displayViewerForZippedMedia];
            }
        }
        
		if ([[currentDownload fileType] intValue] == AssetFileTypeVideo) currentController = [self displayViewerForVideo];
		if ([[currentDownload fileType] intValue] == AssetFileTypeAudio) currentController = [self displayViewerForAudio];
		if ([[currentDownload fileType] intValue] == AssetFileTypeHtml) currentController = [self displayViewerForHtml];
        if ([[currentDownload fileType] intValue] == AssetFileTypeImage) currentController = [self displayViewerForImage];
        if ([[currentDownload fileType] intValue] == AssetFileTypeWordDoc) currentController = [self displayViewerForWordDoc];
		
		if (currentController) {
			NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(hideNavigationBar)];
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
			[invocation setTarget:self];
			[invocation setSelector:@selector(hideNavigationBar)];
			timer = [NSTimer scheduledTimerWithTimeInterval:3.0 invocation:invocation repeats:NO];
		}
	}
}

-(void)hideNavigationBar
{
	timer = NULL;
	
	if (navigationController) {
		if (currentController && ![currentController isKindOfClass:[QLPreviewController class]]) {
			[navigationController setNavigationBarHidden:YES animated:YES];
			
			UISwipeGestureRecognizer *downGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidSwipeDown:)];
			[downGesture setDelegate:self];
			[downGesture setCancelsTouchesInView:NO];
			[downGesture setNumberOfTouchesRequired:1];
			[downGesture setDirection:UISwipeGestureRecognizerDirectionDown];
			[currentController.view addGestureRecognizer:downGesture];
			
			UISwipeGestureRecognizer *upGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidSwipeUp:)];
			[upGesture setDelegate:self];
			[upGesture setCancelsTouchesInView:NO];
			[upGesture setNumberOfTouchesRequired:1];
			[upGesture setDirection:UISwipeGestureRecognizerDirectionUp];
			[currentController.view addGestureRecognizer:upGesture];
		}
	}
}

-(void)userDidSwipeDown:(UISwipeGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		if (navigationController) [navigationController setNavigationBarHidden:NO animated:YES];
	}
}

-(void)userDidSwipeUp:(UISwipeGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		if (navigationController) [navigationController setNavigationBarHidden:YES animated:YES];
	}
}

-(UIViewController *)displayViewerForImage
{
	imageController = [[IGImageViewController alloc] initWithPathToFile:pathToFile];
	[navigationController pushViewController:imageController animated:YES];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
	imageController.navigationItem.leftBarButtonItem = doneButton;
	UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleDone target:self action:@selector(hideButtonPressed)];
	webController.navigationItem.rightBarButtonItem = hideButton;
	
	return imageController;
}

-(UIViewController *)displayViewerForAudio
{
	audioPlayer = [[IGAudioPlaybackController alloc] initWithPathForFile:pathToFile];
	[navigationController pushViewController:audioPlayer animated:YES];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
	audioPlayer.navigationItem.leftBarButtonItem = doneButton;
	UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleDone target:self action:@selector(hideButtonPressed)];
	webController.navigationItem.rightBarButtonItem = hideButton;
	
	[audioPlayer play];
	
	return audioPlayer;
}

-(UIViewController *)displayViewerForPdfMedia
{
    VFRReaderDocNoShare *reader = [[VFRReaderDocNoShare alloc] initWithFilePath:pathToFile password:nil];
    [reader setPageNumber:@1];
    ReaderViewController *pdfController = [[ReaderViewController alloc] initWithReaderDocument:reader];
    pdfController.delegate = self;
    pdfController.navigationController.navigationBar.opaque = YES;
    pdfController.modalPresentationStyle = UIModalPresentationFullScreen;
    pdfController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pdfController animated:YES completion:NULL];
    
	return pdfController;
}

-(UIViewController *)displayViewerForZippedMedia
{
    QLPreviewController* documentViewer = [[QLPreviewController alloc] init];
    documentViewer.dataSource = self;
    documentViewer.delegate = self;
    [documentViewer setCurrentPreviewItemIndex:0];
    [navigationController pushViewController:documentViewer animated:YES];
    
    return documentViewer;
}

-(UIViewController *)displayViewerForVideo
{
	moviePlayer = [[IGMoviePlaybackController alloc] initWithPathForFile:pathToFile];
	[navigationController pushViewController:moviePlayer animated:YES];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
	moviePlayer.navigationItem.leftBarButtonItem = doneButton;
	UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleDone target:self action:@selector(hideButtonPressed)];
	webController.navigationItem.rightBarButtonItem = hideButton;
	
	[moviePlayer play];
	
	return moviePlayer;
}

-(UIViewController *)displayViewerForHtml
{	
	webController = [[IGWebViewController alloc] initWithPathToFile:currentDownload.absolutePath];
    webController.currentAsset = currentAsset;
	[navigationController pushViewController:webController animated:YES];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
	webController.navigationItem.leftBarButtonItem = doneButton;
	/*UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStyleDone target:self action:@selector(testButtonPressed)];
	webController.navigationItem.rightBarButtonItem = testButton;*/
	UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleDone target:self action:@selector(hideButtonPressed)];
	webController.navigationItem.rightBarButtonItem = hideButton;
	
	//[navigationController setNavigationBarHidden:YES animated:NO];
	
	[webController setDelegate:self];
	
	return webController;
}

-(UIViewController *)displayViewerForWordDoc
{
    webController = [[IGWebViewController alloc] initWithPathToFile:[NSString stringWithFormat:@"%@/%@", currentDownload.absolutePath, currentDownload.file]];
    webController.currentAsset = currentAsset;
    [navigationController pushViewController:webController animated:YES];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
    webController.navigationItem.leftBarButtonItem = doneButton;
    /*UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStyleDone target:self action:@selector(testButtonPressed)];
     webController.navigationItem.rightBarButtonItem = testButton;*/
    UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleDone target:self action:@selector(hideButtonPressed)];
    webController.navigationItem.rightBarButtonItem = hideButton;
    
    //[navigationController setNavigationBarHidden:YES animated:NO];
    
    [webController setDelegate:self];
    
    return webController;
}

-(void)hideButtonPressed
{
	if (navigationController) {
		[navigationController setNavigationBarHidden:YES animated:YES];
	}
}

-(void)testButtonPressed
{
	int lowerBound = 0;
	int upperBound = 10;
	int rndId = lowerBound + arc4random() % (upperBound - lowerBound);
	NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
	[jsonDictionary setObject:[NSNumber numberWithInt:rndId] forKey:@"assessmentId"];
	
	lowerBound = 4;
	upperBound = 15;
	int rndQuestions = lowerBound + arc4random() % (upperBound - lowerBound);
	
	lowerBound = 0;
	upperBound = 3;
	NSArray *answers = [NSArray arrayWithObjects:@"YES",@"NO",@"A",@"B", nil];
	
	NSMutableArray *assessmentArray = [[NSMutableArray alloc] init];
	for (int i=0; i<rndQuestions; i++) {
		int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
		[dic setObject:[NSNumber numberWithInt:i] forKey:@"questionId"];
		[dic setObject:[answers objectAtIndex:rndValue] forKey:@"answer"];
		[assessmentArray addObject:dic];
	}
	
	[jsonDictionary setObject:assessmentArray forKey:@"answers"];
	
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	//CLS_LOG(@"JSON: %@", jsonString);
	
	NSMutableDictionary *arguments = [CMSUtils dictionaryForLoginDetails];
	//[arguments setObject:jsonString forKey:@"assessment"];
    
    AFJSONRequestSerializer *serializer = [[AFJSONRequestSerializer alloc] init];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:[[CMSUtils baseUrl] stringByAppendingString:@"/api/v1/assessment"] parameters:arguments error:nil];
    [request setHTTPBody:jsonData];
    [request setAllHTTPHeaderFields:arguments];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    CLS_LOG(@"URL: %@", [CMSUtils urlWithPath:@"/api/v1/assessment" andArguments:arguments]);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLS_LOG(@"JSON Sent:\n%@", jsonString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLS_LOG(@"Error sending JSON:\n%@\n(IGMediaViewerWindow > testButtonPressed)", error);
    }];
    
    [operation start];
}

-(void)backButtonPressed:(id)sender
{
    if (moviePlayer) [moviePlayer stop];
    if (audioPlayer) [audioPlayer stop];
    
    if ([currentController isMemberOfClass:[IGWebViewController class]])
    {
        if ([[webController.webView.request.mainDocumentURL.pathExtension lowercaseString] isEqualToString:@"pdf"])
        {
            [webController.webView goBack];
            return;
        }
    }
    if ([[self delegate] respondsToSelector:@selector(documentWindowShouldClose)]) {
        [[self delegate] documentWindowShouldClose];
    }
}

#pragma mark QLPreviousControllerDataSource

-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
	//UIBarButtonItem *viewButton = [[UIBarButtonItem alloc] initWithTitle:@"Validation Quiz" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
	//controller.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:doneButton, viewButton, nil];
	controller.navigationItem.leftBarButtonItem = doneButton;
	/*UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleDone target:self action:@selector(hideButtonPressed)];
	webController.navigationItem.rightBarButtonItem = hideButton;*/
	
	return [NSURL fileURLWithPath:pathToFile];
}

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return 1;
}

#pragma mark IGWebViewControllerDelegate

-(void)shouldCloseWebViewController
{
    if ([[self delegate] respondsToSelector:@selector(documentWindowShouldClose)]) {
        [[self delegate] documentWindowShouldClose];
    }
}

#pragma mark ReaderViewControllerDelegate
- (void)dismissReaderViewController:(ReaderViewController *) viewController {
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
        if ([[self delegate] respondsToSelector:@selector(documentWindowShouldClose)]) {
            [[self delegate] documentWindowShouldClose];
        }
    }];
}

#pragma mark UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
