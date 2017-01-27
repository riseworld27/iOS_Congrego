//
//  IGMediaViewerWindow.h
//  IgViewer
//
//  Created by matata on 05/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <ReaderViewController.h>
#import "IGWebViewController.h"

@class Asset, IGDocumentViewController, Download, IGMoviePlaybackController, IGAudioPlaybackController, IGImageViewController, IGWebViewController, IGMediaViewNavigationController;

@protocol IGMediaViewerWindowDelegate <NSObject>

@optional
-(void)documentWindowShouldClose;

@end

@interface IGMediaViewerWindow : UIView <IGWebViewControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, ReaderViewControllerDelegate, UIGestureRecognizerDelegate>
{
	Asset *currentAsset;
	Download *currentDownload;
	UIDocumentInteractionController *documentController;
	IGMediaViewNavigationController *navigationController;
	NSString *pathToFile;
	IGMoviePlaybackController *moviePlayer;
	IGAudioPlaybackController *audioPlayer;
	IGImageViewController *imageController;
	IGWebViewController *webController;
	UIViewController *currentController;
	NSTimer *timer;
}

@property (nonatomic, retain) id <IGMediaViewerWindowDelegate> delegate;

-(id)initWithAsset:(Asset *)asset;
-(void)displayMedia;

@end
