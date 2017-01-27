//
//  Asset.m
//  IgViewer
//
//  Created by matata on 01/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "Asset.h"
#import "Collection.h"
#import "Download.h"

#import "CoreDataHandler.h"


@implementation Asset

@dynamic assetDetails;
@dynamic assetEnabled;
@dynamic assetFormat;
@dynamic assetSize;
@dynamic assetType;
@dynamic assetUrl;
@dynamic cmsId;
@dynamic downloadApp;
@dynamic iconFile;
@dynamic installedApp;
@dynamic subTitle;
@dynamic title;
@dynamic updated;
@dynamic collections;
@dynamic download;
@dynamic assetHash;

-(BOOL)isEqualToAsset:(Asset *)asset
{
	BOOL equal = NO;
	if ([[asset title] isEqualToString:[self title]] && [[asset subTitle] isEqualToString:[self subTitle]] && [[asset assetDetails] isEqualToString:[self assetDetails]] && [[asset assetType] isEqualToNumber:[self assetType]] && [[asset assetHash] isEqualToString:[self assetHash]]) {
		equal = YES;
	}
	
	return equal;
}

-(NSString *)captionForButton
{
    if ([self.assetType isEqualToNumber:[NSNumber numberWithInt:7]]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.installedApp]]) {
            return @"Open";
        } else {
            return @"Download App";
        }
    }
    
    Download *downloadForAsset = (Download *)self.download;
    if (!downloadForAsset) {
        downloadForAsset = [CoreDataHandler fetchDownloadForAsset:self];
        [self setDownload:downloadForAsset];
        [downloadForAsset addAssetsObject:self];
        [CoreDataHandler commit];
    }
    
    NSString *captionForAsset = @"Download";
    if (downloadForAsset) {
        captionForAsset = @"Queued for download";
        if ([[downloadForAsset isDownloading] boolValue]) captionForAsset = @"Downloading...";
        if ([[downloadForAsset downloaded] boolValue]) captionForAsset = @"Launch";
    }
    
    return captionForAsset;
}

-(BOOL) isDownloadCancelable
{
    return self.download && ![self.download.downloaded boolValue];
}

@end
