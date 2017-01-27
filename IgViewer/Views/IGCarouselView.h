//
//  IGCarouselView.h
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@class iCarousel, Product;

@protocol IGCarouselViewDelegate <NSObject>

@optional
-(void)didSelectCellForProduct:(Product *)product;

@end

@interface IGCarouselView : UIView <iCarouselDataSource, iCarouselDelegate>
{
	NSInteger currentIndex;
}

@property (nonatomic, retain) iCarousel *carousel;
@property (nonatomic, retain) NSMutableArray *carouselItems;
@property (nonatomic, retain) id <IGCarouselViewDelegate> delegate;

- (id)initWithItems:(NSArray *)items;
-(void)reloadCarousel;
-(void)reloadCarouselWithDataSource:(NSMutableArray *)items;

@end
