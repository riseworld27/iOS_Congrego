//
//  AppDelegate.h
//  IgViewer
//
//  Created by matata on 04/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"
#import "AppUpdateManager.h"

@class IGViewController, NetworkManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate, NetworkManagerDelegate>
{
	IGViewController *viewController;
	NetworkManager *network;
    AppUpdateManager *appUpdate;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
