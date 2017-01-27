//
//  IGWebViewController.m
//  IgViewer
//
//  Created by matata on 05/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGWebViewController.h"
#import "WebViewJavascriptBridge.h"
#import "CoreDataHandler.h"
#import "AssessmentSubmissionHandler.h"
#import "Analytics.h"
#import "Asset.h"
#import "GenericDataSubmissionHandler.h"

@interface IGWebViewController ()
{
    NSString *slideId;
}

@end

@implementation IGWebViewController

@synthesize webView;

-(id)initWithPathToFile:(NSString *)path
{
	self = [super init];
	if (self) {
		NSString *pathToFile = path;
        if (![path containsString:@".doc"] && ![path containsString:@".docx"])
        {
            pathToFile = [path stringByAppendingPathComponent:@"index.html"];
        }
		
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		if ([fileManager fileExistsAtPath:pathToFile]) {
			file = [NSURL fileURLWithPath:pathToFile];
		} else {
			NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:path];
			
			NSString *filePath;
			while ((filePath = [dirEnum nextObject])) {
				if ([[filePath lastPathComponent] isEqualToString: @"index.html"]) {
					pathToFile = [path stringByAppendingPathComponent:filePath];
					file = [NSURL fileURLWithPath:pathToFile];
				}
			}
		}
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
	[self.view addSubview:webView];
	
	__block IGWebViewController *selfForBlock = self;
	
	[WebViewJavascriptBridge enableLogging];
	
	bridge = [WebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
		CLS_LOG(@"Javascript response status: %@", data);
		responseCallback([NSString stringWithFormat:@"Status : %li", (long)WebViewJavascriptBridgeStatusOk]);
	}];
	
	[bridge registerHandler:@"closeWebViewAndSubmitResults" handler:^(id data, WVJBResponseCallback responseCallback) {
		if (data) {
			NSDictionary *json = (NSDictionary *)data;
			[selfForBlock closeWebViewAndSubmitResultsWithJson:json];
		}
	}];
	
	[bridge registerHandler:@"submitAnswerForQuestion" handler:^(id data, WVJBResponseCallback responseCallback) {
		if (data) {
			[self submitAnswerForQuestionWithData:data];
		}
	}];
	
	[bridge registerHandler:@"submitAnalyticsData" handler:^(id data, WVJBResponseCallback responseCallback) {
		if (data) {
            NSDictionary *input = (NSDictionary *)data;
            if (input[@"type"] != nil)
            {
                NSString *type = [input valueForKey:@"type"];
                if ([type isEqualToString:@"event"])
                    responseCallback([self analyticsTrackEvent:input]);
                else if ([type isEqualToString:@"timing"])
                    responseCallback([self analyticsTrackTiming:input]);
                else
                    responseCallback(@{@"errorCode" : @1, @"errorString" : @"Unknown type supplied"});
            }
            else
            {
                responseCallback(@{@"errorCode" : @1, @"errorString" : @"No type supplied"});
            }
		}
        else
        {
            responseCallback(@{@"errorCode" : @1, @"errorString" : @"No data supplied"});
        }
	}];
	
	[bridge registerHandler:@"getContext" handler:^(id data, WVJBResponseCallback responseCallback) {
		
        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
        if (userId == nil) userId =  @"0";
        
        NSString *contentId = self.currentAsset.cmsId;
        if (contentId == nil) contentId = @"0";
        
        responseCallback(@{@"errorCode" : @0, @"errorString" : @"",
                         @"userId" : userId,
                         @"contentItemId" : contentId});
	}];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:file];
    [webView setDelegate:self];
	[webView loadRequest:request];
}

- (NSDictionary *)analyticsTrackTiming:(NSDictionary *)data
{
    [Analytics trackTiming:data[@"category"] name:data[@"name"] label:data[@"label"] interval:data[@"interval"]];
    return @{@"errorCode" : @0, @"errorString" : @""};
}

- (NSDictionary *)analyticsTrackEvent:(NSDictionary *)data
{
    if ([data[@"category"] isEqualToString:@"Navigation"])
        slideId = data[@"slideId"];
    
    if (slideId != nil)
        [Analytics setDimensionIndex:DimensionSlideId toValue:slideId];
    
    if (data[@"dimensions"] != nil && [data[@"dimensions"] isKindOfClass:[NSDictionary class]])
    {
        // Process custom dimensions
        [data[@"dimensions"] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [Analytics setDimensionIndex:[key intValue] toValue:obj];
        }];
    }
    
    [Analytics trackEvent:data[@"category"] action:data[@"action"] label:data[@"label"] value:data[@"value"]];
    return @{@"errorCode" : @0, @"errorString" : @""};
}

-(void)submitAnswerForQuestionWithData:(id)data
{
	if ([data isKindOfClass:[NSDictionary class]]) {
		CLS_LOG(@"Dictionary detected");
		
		AssessmentSubmissionHandler *handler = [[AssessmentSubmissionHandler alloc] init];
		[handler submitAnswerWithDictionary:(NSDictionary *)data];
	}
	
	if ([data isKindOfClass:[NSArray class]]) {
		CLS_LOG(@"Array detected");
		
		AssessmentSubmissionHandler *handler = [[AssessmentSubmissionHandler alloc] init];
		[handler submitAnswerWithArray:(NSArray *)data];
	}
}

-(void)closeWebViewAndSubmitResultsWithJson:(NSDictionary *)dictionary
{
	if ([[self delegate] respondsToSelector:@selector(shouldCloseWebViewController)]) {
		[[self delegate] shouldCloseWebViewController];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//all below added by ME
/*  The purpose of the below is to build a light weight javascript to native code implementation
 The shouldStartLoadWithRequest intercepts calls to the webview to change location. If it begins with bwo-js-call then we capture the request and stop it processing down the even hierachy.
 This request is then passed on to evaluateJavascriptCall, in here we have a number of options that determine what we do with the data that was sent to us and what should be returned.
 */

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    CLS_LOG(@"In should start load");
    BOOL ret = YES;
    NSString *req = [[request URL] absoluteString];
    if ([req hasPrefix:@"bwo-js-call"]) {
        ret = NO;
        [self evaluateJavascriptCall:req];
    }
    return ret;
}

-(void)evaluateJavascriptCall:(NSString *)requestString {
    // Split up the URL that we have recieved
    bool success = false; // if there is an error we need to return it
    NSString *message = @"No command was supplied or the argument list was corrupt"; // placeholder for the error message
    NSArray *components=[requestString componentsSeparatedByString:@":"]; // we don't care about the first component [0] as that is just bwo-js-call
    NSString *command = (NSString*)[components objectAtIndex:1]; // command is used to determine what should be run
    NSString *args = [(NSString*)[components objectAtIndex:2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // this is a list of the arguments, basically a JSON dictionary
    NSError *error = nil;
    NSData *argsData = [args dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:argsData options: kNilOptions error:&error]; // create the dictionary object from the list of arguments we were sent
    //CLS_LOG(@"error is: %@ command is: %@", error, command);
    if (error==nil && command) { // check the command isn't empty and there was no error
        if ([command isEqualToString:@"storeData"]) {
            /*
             Here we are being passed data from the HTML5 app that should be stored or possibly synced with a server
             */
            //first check we have a key
            if (dict[@"bwo-key"]) {
                [[NSUserDefaults standardUserDefaults] setObject:dict forKey:(NSString *)dict[@"bwo-key"]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // check to see if a return function has been supplied if so send back a success message
                if(dict[@"function"]) {
                    //CLS_LOG(@"We are in here return function is: %@", [NSString stringWithFormat:@"%@(true, '');", dict[@"function"]]);
                    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(true, '');", dict[@"function"]]];
                }
                // Check to see if this is syncable data, and whether the sync state is set to yes. If it is try to do a submission.
                if (dict[@"sync"] && [(NSString *)dict[@"sync"] isEqualToString:@"yes"]) {
                    GenericDataSubmissionHandler *dsh = [[GenericDataSubmissionHandler alloc] init];
                    [dsh submitGenericDataWithKey:(NSString *)dict[@"bwo-key"]];
                }
                success=true;
            } else {
                if(dict[@"function"]) {
                    //CLS_LOG(@"We are in here as there was an error and we have a return function is: %@", [NSString stringWithFormat:@"%@(true, '');", dict[@"function"]]);
                    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(false, 'No key was supplied');", dict[@"function"]]];
                    success=true; // the reason this is true is that we have returned a message to the return function supplied so we are not using the generic error return.
                }
            }
        } else if ([command isEqualToString:@"retrieveData"]) {
            // returning data to the webView
            if (dict[@"bwo-key"]) {
                NSDictionary *uDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)dict[@"bwo-key"]];
                NSString *funcName = dict[@"function"];
                NSMutableString *jsCommand = [NSMutableString stringWithString:funcName];
                [jsCommand appendString:@"({"];
                for (id key in uDict) {
                    [jsCommand appendFormat:@"'%@':'%@',", key, uDict[key]];
                }
                [jsCommand deleteCharactersInRange:NSMakeRange([jsCommand length]-1, 1)]; // get rid of the last , that we appended
                [jsCommand appendString:@"})"];
                //CLS_LOG(@"%@", jsCommand);
                [self.webView stringByEvaluatingJavaScriptFromString:jsCommand];
                success = true;
            } else { message=@"No key was supplied";}
            
        } else if ([command isEqualToString:@"retrieveKeys"]) {
            // we should return all the keys in the dictionary that match the search string
            NSString *funcName = dict[@"function"];
            NSArray *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
            NSMutableString *jsCommand = [NSMutableString stringWithString:funcName];
            [jsCommand appendString:@"(["];
            for (NSString *key in keys)
            {
                if ([key hasPrefix:dict[@"searchString"]]) {
                    [jsCommand appendFormat:@"'%@',", key];
                }
            }
            [jsCommand deleteCharactersInRange:NSMakeRange([jsCommand length]-1, 1)]; // get rid of the last , that we appended
            [jsCommand appendString:@"]);"];
            //CLS_LOG(@"%@", jsCommand);
            [self.webView stringByEvaluatingJavaScriptFromString:jsCommand]; // run the javascript command which is expecting the list of keys
            success=true;
        }else if ([command isEqualToString:@"removeData"]) {
            if (dict[@"bwo-key"]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:(NSString *)dict[@"bwo-key"]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                success=true;
            } else { message = @"No key was supplied";}
        } else if ([command isEqualToString:@"retrieveContext"]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *userId = [userDefaults valueForKey:@"userId"];
            NSString *server = [userDefaults valueForKey:@"Server"];
            NSString *sessionId = [userDefaults valueForKey:@"sessionId"];
            NSString *sessionName = [userDefaults valueForKey:@"sessionName"];
            NSString *cmsId = self.currentAsset.cmsId;
            NSString *assetTitle = [self.currentAsset.title stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            NSString *assetSubTitle = [self.currentAsset.subTitle stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];;
            NSString *funcName = dict[@"function"];
            NSMutableString *jsCommand = [NSMutableString stringWithString:funcName];
            [jsCommand appendFormat:@"({'userId':'%@', 'server':'%@', 'sessionId':'%@', 'sessionName':'%@', 'assetId':'%@', 'assetTitle':'%@', 'assetSubTitle':'%@'})", userId, server, sessionId, sessionName, cmsId, assetTitle, assetSubTitle];
            [self.webView stringByEvaluatingJavaScriptFromString:jsCommand];
            success=true;
        }
    }
    if (!success) {
        // there was an error, send the message back to the page. Assume there is a method receiveNativeError
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"receiveNativeError('%@');", message]];
    }
    
}

/// end of added by ME

@end
