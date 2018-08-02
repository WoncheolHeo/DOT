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
@implementation NetworkManager

- (void)requestAccessTokenWithServiceNumber:(NSInteger)serviceNumber package:(NSString *)package completion:(CompletionBlock)completion {
    NSString *urlStrTmp = @"/token/acsTokenRps.do?_wtno=";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%ld&_wPkg=%@",kDOTApiUrl,urlStrTmp,(long)serviceNumber, package];
    
  
    
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"C4myJsiP6QBekuEgmy0/fg====" forHTTPHeaderField: @"authType"];
    [request setValue:@"" forHTTPHeaderField: @"User-Agent"];

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

- (void)sendDocumentWithType:(NSInteger)type fianlJsonListString:(NSString *)fianlJsonListString completion:(CompletionBlock)completion {
    
    //네트워크
    NSString *urlStr = [kDOTApiUrl stringByAppendingString:@"/dot/dataRcv.do"];
    CBLDocument *document2 = [[LocalDB sharedInstance].database documentWithID:@"authDoc"];
    NSString *authToken = [document2 stringForKey:@"authToken"];
    
    NSString *SDKVersion = @"1.0.0";

    NSString *userAgent = [NSString stringWithFormat:@"DOT%@%@%@%@", SDKVersion, [SessionJson sharedInstance].timeOffset, [SessionJson sharedInstance].phone, [[UIDevice currentDevice] systemVersion] ];
                           
    NSString* eString = [fianlJsonListString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSData* nString = [eString dataUsingEncoding:NSUTF8StringEncoding  allowLossyConversion: true];
    
    //GZIP
    NSData* cString = [[[WT_GZIP alloc] init] gzippedData:nString];
    
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"lpvf15wWBbPqo20NyEHj9A==" forHTTPHeaderField: @"authType"];
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
@end
