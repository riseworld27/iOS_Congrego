//
//  FCControl.h
//  Falcon
//
//  Created by matata on 08/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FCControlState) {
    FCControlStateDefault,
    FCControlStateSelected
};

@class FCTileableElementController, FCControl;

@protocol FCControlDelegate <NSObject>

@optional
-(void)controlDidChangeState:(FCControlState)state forControl:(FCControl *)control;

@end

@interface FCControl : UIControl
{
	UIView *contentContainer;
	UIView *buttonBackgroundView;
	
	FCTileableElementController *defaultController;
	FCTileableElementController *selectedController;
}

@property (nonatomic) BOOL autoExpandToWidth;
@property (nonatomic) BOOL persistStates;
@property (nonatomic) FCControlState controlState;
@property (nonatomic, retain) id <FCControlDelegate> delegate;

- (id)initWithDefaultControl:(FCTileableElementController *)defaultControl selectedControl:(FCTileableElementController *)selectedControl;
- (id)initWithDefaultControl:(FCTileableElementController *)defaultControl selectedControl:(FCTileableElementController *)selectedControl andWidth:(NSNumber *)buttonWidth;
-(void)updateTileableElementControllersTileWith:(float)width;
-(void)setControlStateDefaultAndCallDelegate:(BOOL)call;
-(void)setControlStateSelectedAndCallDelegate:(BOOL)call;
-(void)buttonReleased;
-(void)buttonPressed;

@end
