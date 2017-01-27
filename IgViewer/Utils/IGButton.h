//
//  IGButton.h
//  IgViewer
//
//  Created by matata on 04/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "FCControl.h"

@interface IGButton : FCControl

@property (nonatomic, retain) NSString *caption;
@property (nonatomic, retain) UILabel *label;

-(id)initWithTitle:(NSString *)title;
-(id)initWithTitle:(NSString *)title andFilePrefix:(NSString *)prefix;
-(void)updateTitle:(NSString *)title;

@end
