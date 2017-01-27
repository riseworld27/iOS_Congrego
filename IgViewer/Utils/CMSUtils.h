//
//  CMSUtils.h
//  IgViewer
//
//  Created by matata on 19/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginSessionCredentials;

@interface CMSUtils : NSObject

+(NSString *)server;
+(NSString *)baseUrl;
+(NSString *)urlWithPath:(NSString *)path;
+(NSString *)urlWithPath:(NSString *)path andArguments:(NSDictionary *)arguments;
+(void)setUserCredentials:(LoginSessionCredentials *)credentials;
+(LoginSessionCredentials *)userCredentials;
+(NSMutableDictionary *)dictionaryForLoginDetailsWithUserCredentials:(LoginSessionCredentials *)credentials;
+(NSMutableDictionary *)dictionaryForLoginDetails;
+(NSString *)parseUrlParameters:(NSDictionary *)dictionary;
+(NSString *)url:(NSString *)url withArguments:(NSDictionary *)dictionary;
+(void)setServer:(NSString *)baseServer;
+(BOOL)isTesting;

@end
