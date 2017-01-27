//
//  DictionarySubmissionHandler.m
//  RepPresent
//
//  Created by Mark Elliott on 19/05/2015.
//  Copyright (c) 2015 BWO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericDataSubmissionHandler.h"
#import "NetworkManager.h"
#import "CMSUtils.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPRequestOperation.h"

@implementation GenericDataSubmissionHandler

-(id)init {
    self = [super init];
    return self;
    
}

-(void)submitGenericDataWithKey:(NSString *)key {
    // check that we have a network connection
    if ([[NetworkManager sharedInstance] isConnectionAvailable]) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSDictionary *dict = [userDefault dictionaryForKey:key];
        NSString *sync = [dict objectForKey:@"sync"];
        NSString *postURL = [dict objectForKey:@"postURL"];
        if (sync && [sync isEqualToString:@"yes"] && postURL) { // check that we have a sync status and that it is equal to yes. Also check we have a URL.
            
            // Need to check if the url has a preceding slash if not then add one
            if (![postURL hasPrefix:@"/"]) {
                postURL = [NSString stringWithFormat:@"/%@", postURL];
            }
            postURL = [[CMSUtils baseUrl] stringByAppendingString:postURL];
            //postURL = @"http://192.168.1.94/index.php";
            NSString *postString = [dict objectForKey:@"postData"];
            CLS_LOG(@"postString is: %@", postString);
            CLS_LOG(@"url sting is: %@", postURL);
            NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *arguments = [CMSUtils dictionaryForLoginDetails];
            
            AFJSONRequestSerializer *serializer = [[AFJSONRequestSerializer alloc] init];
            NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString: postURL parameters:arguments error:nil];
            request.HTTPBody = postData;
            request.allHTTPHeaderFields = arguments;
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                CLS_LOG(@"Data Sent: %@ response: %@", [NSString stringWithUTF8String:[postData bytes]], [NSString stringWithUTF8String:[responseObject bytes]]);
                [userDefault removeObjectForKey:key];
                [userDefault synchronize];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                CLS_LOG(@"Error response: %@",ErrorResponse);
                CLS_LOG(@"Failed: %@", [error description]);
            }];
            
            [operation start];
        }
    }
    
}

-(void)submitAllGenericData {
    // this will be the method that the main sync function starts. Basically we will look for all data with the bwo-data key and send it for syncing.
    NSArray *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    for (NSString *key in keys) {
        if ([key hasPrefix:@"bwo-data"]) {
            [self submitGenericDataWithKey:key];
        }
    }
}

@end
