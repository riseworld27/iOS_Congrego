//
//  IGDetailsView.m
//  IgViewer
//
//  Created by matata on 12/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGDetailsView.h"
#import "IGDetailsObject.h"
#import "Asset.h"
#import "IGButton.h"
#import "Download.h"
#import "AssetDownload.h"
#import "CoreDataHandler.h"

@implementation IGDetailsView

@synthesize useSeparator;

- (id)initWithAsset:(Asset *)assetForView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
		asset = assetForView;
		
		UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 770, 20)];
		[header setText:[asset title]];
		[header setTextColor:[UIColor whiteColor]];
        [header setFont:[UIFont boldSystemFontOfSize:16.0]];
		[header setUserInteractionEnabled:NO];
		[header setTextAlignment:NSTextAlignmentLeft];
		[header setBackgroundColor:[UIColor clearColor]];
		[self addSubview:header];
        
        UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, AFTER_Y(header), 385, 20)];
        [subtitle setText:asset.subTitle];
        [subtitle setTextColor:[UIColor whiteColor]];
        [subtitle setFont:[UIFont systemFontOfSize:14.0]];
        [subtitle setTextAlignment:NSTextAlignmentLeft];
        [subtitle setBackgroundColor:[UIColor clearColor]];
        [self addSubview:subtitle];
		
		NSString *detailsForAsset = [asset assetDetails];
        CGRect bodySize = [detailsForAsset boundingRectWithSize:CGSizeMake(385, FLT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12.0f]}
                                                     context:nil];
		body = [[UILabel alloc] initWithFrame:CGRectMake(0, AFTER_Y(subtitle)+5, 385, bodySize.size.height)];
		[body setText:detailsForAsset];
		[body setLineBreakMode:NSLineBreakByWordWrapping];
		[body setNumberOfLines:0];
		[body setTextColor:[UIColor whiteColor]];
		[body setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
		[body setUserInteractionEnabled:NO];
		[body setTextAlignment:NSTextAlignmentLeft];
		[body setBackgroundColor:[UIColor clearColor]];
		[self addSubview:body];
		
		NSString *captionForAsset = [asset captionForButton];
		
		button = [[IGButton alloc] initWithTitle:captionForAsset andFilePrefix:@"detailsViewGreenButton"];
		[button setFrame:CGRectMake(0, AFTER_Y(body)+15, WIDTH(button), HEIGHT(button))];
		[[button label] setTextColor:[UIColor whiteColor]];
		[[button label] setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
		[[button label] setShadowOffset:CGSizeMake(0, -1)];
		if (![[asset assetUrl] isEqualToString:@""]) [button addTarget:self action:@selector(downloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
        
        cancelButton = [[IGButton alloc] initWithTitle:@"Cancel download"];
        [cancelButton setFrame:CGRectMake(WIDTH(button) + 20, AFTER_Y(button) - HEIGHT(button), WIDTH(cancelButton), HEIGHT(cancelButton))];
        [cancelButton.label setTextColor:[UIColor darkGrayColor]];
        [cancelButton.label setShadowColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
        [cancelButton.label setShadowOffset:CGSizeMake(0, 1)];
        [cancelButton setHidden:![asset isDownloadCancelable]];
        [self addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		
		deleteButton = [[IGButton alloc] initWithTitle:@"Remove Download"];
		[deleteButton setFrame:CGRectMake(AFTER_X(body)-WIDTH(deleteButton)-10, Y(button), WIDTH(deleteButton), HEIGHT(deleteButton))];
		[[deleteButton label] setTextColor:[UIColor darkGrayColor]];
		[[deleteButton label] setShadowColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
		[[deleteButton label] setShadowOffset:CGSizeMake(0, 1)];
		[self addSubview:deleteButton];
		[deleteButton setHidden:YES];
		if ([[button caption] isEqualToString:@"Launch"]) [deleteButton setHidden:NO];
		[deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        
        // For emailing the asset
        
        sendEmailButton = [[IGButton alloc] initWithTitle:@"Send Via Email"];
        [sendEmailButton setFrame:CGRectMake(AFTER_X(button)+10, Y(button), WIDTH(sendEmailButton), HEIGHT(sendEmailButton))];
        [[sendEmailButton label] setTextColor:[UIColor darkGrayColor]];
        [[sendEmailButton label] setShadowColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
        [[sendEmailButton label] setShadowOffset:CGSizeMake(0, 1)];
        [self addSubview:sendEmailButton];
        [sendEmailButton setHidden:YES];
        [sendEmailButton addTarget:self action:@selector(sendEmailButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        if ([[button caption] isEqualToString:@"Launch"] && [asset.emailable boolValue] == YES)
            [sendEmailButton setHidden:NO];
        
        
		UIImageView *verticalSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailsViewVerticalSeparator.png"]];
		[verticalSeparator setFrame:CGRectMake(AFTER_X(body)+10, 30, WIDTH(verticalSeparator), HEIGHT(verticalSeparator))];
		[self addSubview:verticalSeparator];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:[asset updated]];
		
        NSString *detailsString;
        if ([asset.assetType isEqualToNumber:[NSNumber numberWithInteger:7]]) {
            detailsString = [NSString stringWithFormat:@"Last updated:\n%@", dateString];
        } else {
            int fileSize = [[asset assetSize] intValue];
            fileSize = fileSize/1024;
            NSString *sizeSuffix = @" KB";
            if (fileSize > 1024) {
                fileSize = fileSize/1024;
                sizeSuffix = @" MB";
            }
            if (fileSize > 1024) {
                fileSize = fileSize/1024;
                sizeSuffix = @" GB";
            }
            
            detailsString = [NSString stringWithFormat:@"Format:\n%@\n\nSize:\n%i%@\n\nLast updated:\n%@", [asset assetFormat], fileSize, sizeSuffix, dateString];
        }
        
		UILabel *details = [[UILabel alloc] initWithFrame:CGRectMake(AFTER_X(verticalSeparator)+20, 30, 160, 110)];
		[details setText:detailsString];
		[details setLineBreakMode:NSLineBreakByWordWrapping];
		[details setNumberOfLines:0];
		[details setTextColor:[UIColor whiteColor]];
		[details setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0]];
		[details setUserInteractionEnabled:NO];
		[details setTextAlignment:NSTextAlignmentLeft];
		[details setBackgroundColor:[UIColor clearColor]];
		[self addSubview:details];
		
		float sepY = (AFTER_Y(button)+20 < AFTER_Y(verticalSeparator)+20) ? AFTER_Y(verticalSeparator)+20 : AFTER_Y(button)+20;
		horizonatlSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailsViewSeparator.png"]];
		[horizonatlSeparator setFrame:CGRectMake(0, sepY, WIDTH(horizonatlSeparator), HEIGHT(horizonatlSeparator))];
		[self addSubview:horizonatlSeparator];
		
		[self setFrame:CGRectMake(X(self), Y(self), 770, sepY+HEIGHT(horizonatlSeparator))];
    }
    return self;
}

-(void)deleteButtonPressed
{
	if (asset) {
		[CoreDataHandler removeDownloadForAsset:asset];
		[CoreDataHandler commit];
		[self updateCaptionForButton];
	}
}

-(void)sendEmailButtonPressed
{
    [self.delegate requestEmailforAsset:asset];
}

-(void)cancelButtonPressed
{
    // Remove this download from the download queue, and cancel any in progress downloads
    if ([self.delegate respondsToSelector:@selector(shouldCancelDownloadForAsset:)]) {
        [self.delegate shouldCancelDownloadForAsset:asset];
    }
    
    [self updateCaptionForButton];
}

-(void)setUseSeparator:(BOOL)use
{
	useSeparator = use;
	[horizonatlSeparator setHidden:!use];
}

-(void)downloadButtonPressed
{
	if ([[button caption] isEqualToString:@"Download"] && ![[asset assetUrl] isEqualToString:@""] && [asset assetUrl]) {
		if ([[self delegate] respondsToSelector:@selector(shouldBeginDownloadForAsset:)]) {
			[[self delegate] shouldBeginDownloadForAsset:asset];
		}
	}
	if ([[button caption] isEqualToString:@"Launch"]) {
		if ([[self delegate] respondsToSelector:@selector(shouldDisplayDownloadForAsset:)]) {
			[[self delegate] shouldDisplayDownloadForAsset:asset];
		}
	}
    
    if ([asset.assetType isEqualToNumber:[NSNumber numberWithInt:7]]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:asset.installedApp]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:asset.installedApp]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:asset.downloadApp]];
        }
    }
    
	[self updateCaptionForButton];
}

-(void)updateCaptionForButton
{
    // Update main button
	NSString *captionForAsset = [asset captionForButton];
	[button updateTitle:captionForAsset];
	
    // Update delete button
	[deleteButton setHidden:YES];
	if ([[button caption] isEqualToString:@"Launch"]) [deleteButton setHidden:NO];
	[deleteButton setFrame:CGRectMake(AFTER_X(body)-WIDTH(deleteButton)-10, Y(button), WIDTH(deleteButton), HEIGHT(deleteButton))];
    
    // Update cancel button
    // We need to move it to account for the changing text content
    [cancelButton setFrame:CGRectMake(WIDTH(button) + 20, AFTER_Y(button) - HEIGHT(button), WIDTH(cancelButton), HEIGHT(cancelButton))];
    [cancelButton setHidden:![asset isDownloadCancelable]];
    
    [sendEmailButton setHidden:!([[button caption] isEqualToString:@"Launch"] && [asset.emailable boolValue] == YES)];
}



@end
