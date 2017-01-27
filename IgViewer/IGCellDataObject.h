//
//  IGCellDataObject.h
//  IgViewer
//
//  Created by matata on 11/02/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGCellDataObject : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic) BOOL downloaded;
@property (nonatomic, retain) NSString *iconFile;

@end
