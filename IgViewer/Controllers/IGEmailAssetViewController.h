//
//  IGEmailAssetViewController.h
//  RepPresent
//
//  Created by matata on 08/02/2016.
//  Copyright © 2016 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Download.h"
#import "Asset.h"

@class IGEmailAssetViewController;


@protocol IGEmailAssetViewControllerDelegate <NSObject>

- (void)controller:(IGEmailAssetViewController *)controller didFinishWithResult:(BOOL)sent;

@end


@interface IGEmailAssetViewController : UIViewController

@property (nonatomic, strong) Asset *asset;
@property (strong, nonatomic) IBOutlet UIView *firstView;

- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)agreeBtnPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *secondView;
- (IBAction)sendBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) id <IGEmailAssetViewControllerDelegate> delegate;

@end
