//
//  IGWebViewController.h
//  IgViewer
//
//  Created by matata on 05/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WebViewJavascriptBridgeStatus) {
    WebViewJavascriptBridgeStatusOk,
	WebViewJavascriptBridgeStatusError
};

@class WebViewJavascriptBridge, Asset;

@protocol IGWebViewControllerDelegate <NSObject>

@optional
-(void)shouldCloseWebViewController;

@end

@interface IGWebViewController : UIViewController
{
	NSURL *file;
	WebViewJavascriptBridge *bridge;
}

@property (nonatomic, weak) id <IGWebViewControllerDelegate> delegate;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) Asset *currentAsset;

-(id)initWithPathToFile:(NSString *)path;

@end
