//
//  AppUpdateManager.m
//  RepPresent
//
//  Created by matata Abbott on 29/03/2016.
//  Copyright © 2016 matata. All rights reserved.
//

#import "AppUpdateManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPRequestOperation.h"
#import <Crashlytics/Crashlytics.h>

@interface AppUpdateManager ()
{
    NSDate *lastPrompted;
}

@end
@implementation AppUpdateManager

- (void)checkForUpdateWithVC:(UIViewController *)vc
{
    CLS_LOG(@"Checking for app updates");
    
    // Get current version
    
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    // Download latest version info
    
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"UpdateUrl"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *data = [[operation responseString] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        
        CLS_LOG(@"Current version is %@, minimum is %@, latest is %@", currentVersion, [info objectForKey:@"versionMinimum"], [info objectForKey:@"versionLatest"]);
        
        // Check for forced update
        
        if ([currentVersion compare:[info objectForKey:@"versionMinimum"] options:NSNumericSearch] == NSOrderedAscending)
        {
            CLS_LOG(@"Forcing update...");
            
            // Force update
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Compulsory Update" message:@"A compulsory update is available. Please download it now." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Download" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                // Download update
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[info objectForKey:@"downloadUrl"]]];
                exit(0);
                
            }]];
            [vc presentViewController:alert animated:YES completion:nil];
        }
        else if ([currentVersion compare:[info objectForKey:@"versionLatest"] options:NSNumericSearch] == NSOrderedAscending)
        {
            // Don't prompt them too often
            if (lastPrompted == nil || [lastPrompted compare:[NSDate dateWithTimeIntervalSinceNow:-3600]] == NSOrderedAscending)
            {
                CLS_LOG(@"Suggesting update...");
                
                // Suggest update
                
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Update Available" message:@"An updated version of the app is available. Would you like to download it now?" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    // Do nothing
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Download" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    // Download update
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[info objectForKey:@"downloadUrl"]]];
                    exit(0);
                    
                }]];
                [vc presentViewController:alert animated:YES completion:nil];
                lastPrompted = [NSDate date];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        CLS_LOG(@"Error fetching app update info:\n%@", error);
        
    }];
    [op start];
}

@end
