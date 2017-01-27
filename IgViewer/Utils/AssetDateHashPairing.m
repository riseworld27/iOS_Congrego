//
//  AssetDateHashPairing.m
//  IgViewer
//
//  Created by matata on 12/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "AssetDateHashPairing.h"

@implementation AssetDateHashPairing

@synthesize hashValue, date;

-(BOOL)isEqualToPairing:(AssetDateHashPairing *)pairing
{
	BOOL equal =NO;
	
	if ([hashValue isEqualToString:[pairing hashValue]] && [date isEqualToDate:[pairing date]]) {
		equal = YES;
	}
	
	return equal;
}

@end
