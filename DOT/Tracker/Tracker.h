//
//  Tracker.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 5..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "LocalDB.h"
#import "User.h"

@interface Tracker : NSObject<UIWebViewDelegate,WKNavigationDelegate>

@property (nonatomic) CBLDatabase *database;
@property (nonatomic) CBLMutableDocument *behaviorDoc;
@property (nonatomic) CBLMutableDocument *enviromentDoc;

+ (Tracker *)sharedInstance;
+ (void)applicationKey:(NSString *)_applicationKey;
+ (NSString *)appKey;
+ (void)setAppKey:(NSString *)newValue;
- (void)initEnd;
- (void)startPage;
- (double)endPage;
- (BOOL)sendTransaction;
- (BOOL)checkPurchase;
- (void)updateBeforePurchase;
- (void)updateAfterPurchase;

- (void)saveUserLoginInfo;
@end
