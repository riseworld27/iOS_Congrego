//
//  IGLoginEntryField.h
//  IgViewer
//
//  Created by matata on 06/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGLoginEntryField : UIView

@property (nonatomic, retain) UITextField *textEntry;

- (id)initWithDefaultText:(NSString *)defaultText;

@end
