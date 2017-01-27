//
//  NetworkManager.h
//  IgViewer
//
//  Created by matata on 20/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NetworkManagerStatus) {
    NetworkManagerStatusNone,
    NetworkManagerStatusConnected
};

@class Reachability;

@protocol NetworkManagerDelegate <NSObject>

@optional
-(void)networkStatusDidChange:(NetworkManagerStatus)status;

@end

@interface NetworkManager : NSObject
{
	Reachability *reachability;
}

@property (nonatomic) NetworkManagerStatus status;
@property (nonatomic, weak) id <NetworkManagerDelegate> delegate;

-(void)displayNetworkAlert;
-(void)setNetworkManagerStatus;
-(BOOL)isConnectionAvailable;

+(NetworkManager *)sharedInstance;

@end
