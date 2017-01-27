//
//  IGEmailAssetViewController.m
//  RepPresent
//
//  Created by matata on 08/02/2016.
//  Copyright © 2016 matata. All rights reserved.
//

#import "IGEmailAssetViewController.h"
#import "GenericDataSubmissionHandler.h"

@interface IGEmailAssetViewController ()

@end

@implementation IGEmailAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cancelBtnPressed:(id)sender {
    
    // Close
    [self.delegate controller:self didFinishWithResult:NO];
}

- (IBAction)agreeBtnPressed:(id)sender {
    
    // Move to next view
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
         [self.view setAlpha:0.0];
     }
     completion:^(BOOL finished) {
         
         self.secondView.frame = self.view.frame;
         [self.view.superview addSubview:self.secondView];
         [self.view removeFromSuperview];
         self.view = self.secondView;
         self.view.alpha = 0;
         
         [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
             self.view.alpha = 1;
         } completion:^(BOOL finished) {
             
         }];
     }];
}

- (IBAction)sendBtnPressed:(id)sender {
    
    if ([self.nameField.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name Required" message:@"Please enter a customer name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([self.emailField.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Required" message:@"Please enter a customer email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![self NSStringIsValidEmail:self.emailField.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"The email address you entered is invalid." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSTimeInterval ticks = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSDictionary *dict = @{@"bwo-key": [NSString stringWithFormat:@"bwo-data-attach-%@-%f",self.asset.cmsId,ticks],
                           @"postURL":@"/approvedemail/sendmail",
                           @"sync": @"yes",
                           @"postData":[NSString stringWithFormat:@"[{\"name\":\"ae-userid\",\"value\":\"%@\"},{\"name\":\"ae-attachmentid\",\"value\":\"%@\"},{\"name\":\"ae-approvaltime\",\"value\":\"%@\"},{\"name\":\"ae-emailaddress\",\"value\":\"%@\"},{\"name\":\"ae-customername\",\"value\":\"%@\"}]",[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"],self.asset.cmsId,[[NSNumber numberWithDouble:ticks] stringValue],self.emailField.text,self.nameField.text ]
                           };
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:(NSString *)dict[@"bwo-key"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    GenericDataSubmissionHandler *dsh = [[GenericDataSubmissionHandler alloc] init];
    [dsh submitGenericDataWithKey:(NSString *)dict[@"bwo-key"]];
    
    UIAlertController *conf = [UIAlertController alertControllerWithTitle:@"This asset has been sent successfully" message:@"If you do not currently have an online connection, the asset will be sent when your connection is re-established." preferredStyle:UIAlertControllerStyleAlert];
    [conf addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.delegate controller:self didFinishWithResult:YES];
    }]];
    [self presentViewController:conf animated:true completion:nil];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)shouldAutorotate
{
    return NO;
}
@end
