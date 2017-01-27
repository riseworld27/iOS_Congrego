//
//  AppDelegate.m
//  IgViewer
//
//  Created by matata on 04/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "AppDelegate.h"
#import "IGViewController.h"
#import "CoreDataHandler.h"
#import "NetworkManager.h"
#import "CMSUtils.h"
#import "AFHTTPRequestOperation.h"
#import <AFNetworking/AFNetworking.h>
#import "Analytics.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Set user defaults
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    [Analytics startSession];
    
    [Fabric with:@[CrashlyticsKit]];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
	
	viewController = [[IGViewController alloc] init];
	[[self window] addSubview:viewController.view];
	[[self window] setRootViewController:viewController];
	
	[CoreDataHandler setContext:self.managedObjectContext];
	//CLS_LOG(@"Number of assessments: %i", [CoreDataHandler numberOfObjectsInEntityWithName:@"Assessment"]);
    
	network = [[NetworkManager alloc] init];
    appUpdate = [[AppUpdateManager alloc] init];
	
	[viewController displayLoginPage];
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	//CLS_LOG(@"My token is: %@", deviceToken);
	
	const unsigned *tokenBytes = [deviceToken bytes];
	NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
						  ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
						  ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
						  ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
	
	//CLS_LOG(@"Stripped token is: %@", hexToken);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *currentToken = [defaults stringForKey:@"deviceToken"];
	BOOL shouldSendToken = NO;
	
	if (currentToken) {
		if (![currentToken isEqualToString:hexToken]) {
			shouldSendToken = YES;
		}
	} else {
		[defaults setObject:hexToken forKey:@"deviceToken"];
		shouldSendToken = YES;
	}
	
	if (shouldSendToken) {
		NSMutableDictionary *arguments = [[CMSUtils dictionaryForLoginDetails] mutableCopy];
		[arguments setObject:@"ios" forKey:@"type"];
		[arguments setObject:hexToken forKey:@"token"];
        
        AFJSONRequestSerializer *serializer = [[AFJSONRequestSerializer alloc] init];
        NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:[[CMSUtils baseUrl] stringByAppendingString:@"/api/v1/json/apns"] parameters:arguments error:nil];
        [request setAllHTTPHeaderFields:arguments];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
 
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            CLS_LOG(@"Response: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            CLS_LOG(@"Failed to send token");
        }];
		
		[operation start];
	}
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	CLS_LOG(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    CLS_LOG(@"Received notification.");
	[UIApplication sharedApplication].applicationIconBadgeNumber = 1;
}

-(void)networkStatusDidChange:(NetworkManagerStatus)status
{
	if (status == NetworkManagerStatusConnected) {
		[viewController processDownloadQueue];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	[viewController cancelNonEssentialProcesses:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[viewController cancelNonEssentialProcesses:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	CLS_LOG(@"Application Active");
	[network setNetworkManagerStatus];
    
    if (network.status == NetworkManagerStatusConnected)
    {
        [appUpdate checkForUpdateWithVC:viewController];
    }
    
	if ([viewController isLoggedIn]) {
//		[viewController checkForUpdates];
		//[viewController processDownloadQueue];
		//[viewController initiateValidationWithNetworkWarning:NO];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[viewController cancelNonEssentialProcesses:YES];
	[self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            CLS_LOG(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"IgViewer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IgViewer.sqlite"];
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        CLS_LOG(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
