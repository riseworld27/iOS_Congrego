//
//  IGSettingViewController.h
//  IgViewer
//
//  Created by matata on 13/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGLogoutButton.h"

@protocol IGSettingViewControllerDelegate <NSObject>

@optional
-(void)shouldLogUserOut;

@end

@interface IGSettingViewController : UIViewController
{
	IGLogoutButton *logoutButton;
}

@property (nonatomic, weak) id <IGSettingViewControllerDelegate> delegate;

@end
