//
//  NetworkManager.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 30..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "NetworkManager.h"
#import "DOTAPIConstant.h"
#import "LocalDB.h"
#import "WT_GZIP.h"
#import "SessionJson.h"
#import <UIKit/UIKit.h>
#import "Environment.h"
#import <AdSupport/ASIdentifierManager.h>
#import "DOTConstant.h"
#import "NSString+AESCrypt.h"
@implementation NetworkManager



- (void)requestFingerPrintWithWtno:(NSInteger)wtno completion:(CompletionBlock)completion  {
    NSString *urlStr = [kDOTApiUrl stringByAppendingString:@"/frp/fingerPrintRps.do"];
    
    NSString *authType = @"FRP";
    authType = [authType AES256EncryptWithKey:@"dotAmWisetracker"];
    
    Environment *enviroment = [[Environment alloc] init];
    NSString *os = [enviroment getOs];
    NSString *phone = [enviroment getPhone];
    NSString *userAgent = [NSString stringWithFormat:@"DOT/%@/%@/%@", kDOTVersion, phone, os];
    NSString *advtId = [self getAdid];
    
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString *post = [NSString stringWithFormat:@"_wtno=%ld&advtId=%@&phone=%@&os=%@", (long) wtno, advtId, phone, os];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:authType forHTTPHeaderField: @"authType"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setHTTPBody:postData];
    
    //    dispatch_semaphore_t    sem;
    //    sem = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            // [callback onNetworkError];
            completion(NO, data, response);
        } else {
            completion(YES, data, response);
            
        }
        //     dispatch_semaphore_signal(sem);
    }] resume];
    
    //  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
}
- (void)requestAccessTokenWithServiceNumber:(NSInteger)serviceNumber package:(NSString *)package completion:(CompletionBlock)completion {
    NSString *urlStrTmp = @"/token/acsTokenRps.do?_wtno=";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%ld&_wPkg=%@",kDOTApiUrl,urlStrTmp,(long)serviceNumber, package];
    
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    Environment *enviroment = [[Environment alloc] init];
    NSString *os = [enviroment getOs];
    NSString *phone = [enviroment getPhone];
    
    NSString *authType = @"TOKEN";
    authType = [authType AES256EncryptWithKey:@"dotAmWisetracker"];
    NSString *userAgent = [NSString stringWithFormat:@"DOT/%@/%@/%@", kDOTVersion, phone, os];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:authType forHTTPHeaderField: @"authType"];
    [request setValue:userAgent forHTTPHeaderField: @"User-Agent"];
    
    
    //    dispatch_semaphore_t    sem;
    //    sem = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            // [callback onNetworkError];
            completion(NO, data, response);
        } else {
            completion(YES, data, response);
            
        }
        //    dispatch_semaphore_signal(sem);
    }] resume];
    
    //  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)sendDocument:(NSString *)fianlJsonListString completion:(CompletionBlock)completion {
    
    //네트워크
    NSString *urlStr = [kDOTApiUrl stringByAppendingString:@"/dot/dataRcv.do"];
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"AppInfo"];
    NSString *authToken = [document stringForKey:@"accessToken"];
    
    Environment *enviroment = [[Environment alloc] init];
    NSString *os = [enviroment getOs];
    NSString *phone = [enviroment getPhone];
    NSString *userAgent = [NSString stringWithFormat:@"DOT/%@/%@/%@", kDOTVersion, phone, os];
    
    NSString *authType = @"DOT";
    authType = [authType AES256EncryptWithKey:@"dotAmWisetracker"];
    
    NSString* eString = [fianlJsonListString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSData* nString = [eString dataUsingEncoding:NSUTF8StringEncoding  allowLossyConversion: true];
    //GZIP
    NSData* cString = [[[WT_GZIP alloc] init] gzippedData:nString];
    
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:authType forHTTPHeaderField: @"authType"];
    [request setValue:authToken forHTTPHeaderField:@"authToken"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    
    NSInputStream* stream = [[NSInputStream alloc] initWithData: cString];// 암호화 안된것 사용하는 경우에는 nString 을 전달하면 됨.
    request.HTTPBodyStream = stream;
    [request setHTTPShouldHandleCookies:false];
    
    dispatch_semaphore_t    sem;
    sem = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            // [callback onNetworkError];
            completion(NO, data, response);
        } else {
            completion(YES, data, response);
            
        }
        dispatch_semaphore_signal(sem);
    }] resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)sendErrorLogWithError:(NSString *)errlog completion:(CompletionBlock)completion {
    NSString *urlStr = [kDOTApiUrl stringByAppendingString:@"/dot/errorRcv.do"];
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"AppInfo"];
    NSString *authToken = [document stringForKey:@"accessToken"];
    
    Environment *enviroment = [[Environment alloc] init];
    NSString *os = [enviroment getOs];
    NSString *phone = [enviroment getPhone];
    NSString *userAgent = [NSString stringWithFormat:@"DOT/%@/%@/%@", kDOTVersion, phone, os];
    
    NSString *authType = @"DOT";
    authType = [authType AES256EncryptWithKey:@"dotAmWisetracker"];
    
    NSString *post = [NSString stringWithFormat:@"errlog=%@", errlog];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:authType forHTTPHeaderField: @"authType"];
    [request setValue:authToken forHTTPHeaderField:@"authToken"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setHTTPBody:postData];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(NO, data, response);
        } else {
            completion(YES, data, response);
            
        }
    }] resume];
}

- (NSString *)getAdid {
    ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
    NSString *idfa = [[manager advertisingIdentifier] UUIDString];
    if( [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"] ){
        idfa = @"";
    }
    return idfa;
}

@end
