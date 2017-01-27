//
//  AssetDateHashPairing.h
//  IgViewer
//
//  Created by matata on 12/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssetDateHashPairing : NSObject

@property (nonatomic, retain) NSString *hashValue;
@property (nonatomic, retain) NSDate *date;

-(BOOL)isEqualToPairing:(AssetDateHashPairing *)pairing;

@end
