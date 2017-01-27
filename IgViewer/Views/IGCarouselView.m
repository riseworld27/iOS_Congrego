//
//  IGCarouselView.m
//  IgViewer
//
//  Created by matata on 07/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGCarouselView.h"
#import "iCarousel.h"
#import "IGCarouselViewCell.h"
#import "FileUtils.h"
#import "Product.h"

@implementation IGCarouselView

@synthesize carousel, carouselItems;

- (id)initWithItems:(NSMutableArray *)items
{
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 250)];
    if (self) {
        carouselItems = items;
		currentIndex = 0;
        
        //create carousel
        carousel = [[iCarousel alloc] initWithFrame:self.bounds];
        carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        carousel.type = iCarouselTypeCoverFlow;
        carousel.delegate = self;
        carousel.dataSource = self;
		[carousel setBounceDistance:0.5];
		[carousel setDecelerationRate:0.5];
        
        //add carousel to view
        [self addSubview:carousel];
    }
    return self;
}

-(void)reloadCarousel
{
	[self reloadCarouselWithDataSource:NULL];
}

-(void)reloadCarouselWithDataSource:(NSMutableArray *)items
{
	if (items) {
		carouselItems = items;
		[carousel reloadData];
	}
	if ([carouselItems count] > 0) {
		currentIndex = 0;
		[carousel setCurrentItemIndex:0];
		if ([[self delegate] respondsToSelector:@selector(didSelectCellForProduct:)]) {
			Product *product = (Product *)[carouselItems objectAtIndex:0];
			[[self delegate] didSelectCellForProduct:product];
		}
	}
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [carouselItems count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
	IGCarouselViewCell *cell = (IGCarouselViewCell *)view;
	Product *product = (Product *)[carouselItems objectAtIndex:index];
	NSString *fileName = [[product imageFile] stringByReplacingOccurrencesOfString:@".jpg" withString:@".png"];
	NSString *file = [NSString stringWithFormat:@"/resources/bundles/products/%@", fileName];
	//NSString *file = [NSString stringWithFormat:@"/resources/bundles/products/%@", @"product.png"];
	NSString *pathToFile = [FileUtils newPath:file create:NO];
	CLS_LOG(@"Path: %@", pathToFile);
    
    //create new view if no view is available for recycling
    if (!cell) {
        cell = [[IGCarouselViewCell alloc] initWithImageAtPath:pathToFile];
		[cell setContentMode:UIViewContentModeCenter];
    } else {
		[cell updateImageWithImageAtPath:pathToFile];
	}
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //label.text = @"Section Title";
    
    return cell;
}

-(void)carousel:(iCarousel *)instance didSelectItemAtIndex:(NSInteger)index
{
	[self carouselWasUpdatedWithIndex:index];
}

-(void)carouselDidEndDragging:(iCarousel *)instance willDecelerate:(BOOL)decelerate
{
	if (!decelerate) {
		NSInteger index = [carousel currentItemIndex];
		[self carouselWasUpdatedWithIndex:index];
	}
}

-(void)carouselDidEndDecelerating:(iCarousel *)instance
{
	NSInteger index = [carousel currentItemIndex];
	[self carouselWasUpdatedWithIndex:index];
}

-(void)carouselWasUpdatedWithIndex:(NSInteger)index
{
	if (index != currentIndex) {
		//CLS_LOG(@"Selected item: %i", index);
		currentIndex = index;
		if ([[self delegate] respondsToSelector:@selector(didSelectCellForProduct:)]) {
			Product *product = (Product *)[carouselItems objectAtIndex:currentIndex];
			[[self delegate] didSelectCellForProduct:product];
		}
	}
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
			BOOL shouldWrap = NO;
			if ([carouselItems count] >= 6) shouldWrap = YES;
            return shouldWrap;
        }
        case iCarouselOptionSpacing:
        {
            return value * 3.0f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                return 0.0f;
            }
            return value;
        }
		case iCarouselOptionTilt:
        {
            return 0.4;
        }
		case iCarouselOptionOffsetMultiplier:
		{
			return 1.0;
		}
        default:
        {
            return value;
        }
    }
}

@end
