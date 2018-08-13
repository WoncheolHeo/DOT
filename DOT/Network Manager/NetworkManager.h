//
//  NetworkManager.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 30..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(BOOL isSuccess, NSData *data, id respons);

@interface NetworkManager : NSObject

- (void)requestFingerPrintWithWtno:(NSInteger)wtno completion:(CompletionBlock)completion;
- (void)requestAccessTokenWithServiceNumber:(NSInteger)serviceNumber package:(NSString *)pagckage completion:(CompletionBlock)completion;
- (void)sendDocument:(NSString *)fianlJsonListString completion:(CompletionBlock)completion;
- (void)sendErrorLogWithError:(NSString *)errlog completion:(CompletionBlock)completion;
@end
