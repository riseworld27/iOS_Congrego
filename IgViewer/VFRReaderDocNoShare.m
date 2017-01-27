//
//  VFRReaderDocNoShare.m
//  RepPresent
//
//  Created by matata on 13/04/2016.
//  Copyright © 2016 matata. All rights reserved.
//

#import "VFRReaderDocNoShare.h"


@implementation VFRReaderDocNoShare

- (BOOL)canEmail
{
    return NO;
}

- (BOOL)canExport
{
    return NO;
}

- (BOOL)canPrint
{
    return YES;
}

@end
