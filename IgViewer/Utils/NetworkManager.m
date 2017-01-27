//
//  NetworkManager.m
//  IgViewer
//
//  Created by matata on 20/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "NetworkManager.h"
#import "Reachability.h"

static NetworkManager *instance;

@implementation NetworkManager

@synthesize status;

-(id)init
{
	self = [super init];
	if (self) {
		instance = self;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
		reachability = [Reachability reachabilityForInternetConnection];
		[reachability startNotifier];
		
		[self setNetworkManagerStatus];
	}
	return self;
}

-(void)handleNetworkChange:(NSNotification *)notice
{
	[self setNetworkManagerStatus];
	if (status == NetworkManagerStatusNone) [self displayNetworkAlert];
	
	if ([[self delegate] respondsToSelector:@selector(networkStatusDidChange:)]) {
		[[self delegate] networkStatusDidChange:status];
	}
}

-(void)setNetworkManagerStatus
{
	NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
	status = NetworkManagerStatusNone;
	
	if (remoteHostStatus == NotReachable) status = NetworkManagerStatusNone;
	if (remoteHostStatus == ReachableViaWiFi) status = NetworkManagerStatusConnected;
	//if (remoteHostStatus == ReachableViaWWAN) status = NetworkManagerStatusNone;
	if (remoteHostStatus == ReachableViaWWAN) status = NetworkManagerStatusConnected;
}

-(void)displayNetworkAlert
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Connection Error"
						  message: @"Could not establish an internet connection, please connect to a Wi-Fi network."
						  delegate: nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
}

-(BOOL)isConnectionAvailable
{
	BOOL connection = NO;
	
	if (status == NetworkManagerStatusConnected) connection = YES;
	
	return connection;
}

+(NetworkManager *)sharedInstance
{
	return instance;
}

@end
