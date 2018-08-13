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
#import "GoalJson.h"
#import "Conversion.h"
#import "RevenueJson.h"
#import "Purchase.h"
#import "ClickJson.h"
#import "Click.h"
#import "PagesJson.h"
#import "Page.h"

@interface Tracker : NSObject<UIWebViewDelegate,WKNavigationDelegate>

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

- (void)setGoalJosnWithConversion:(Conversion *)conversion;
- (void)setRevenueJsonWithPurchase:(Purchase *)purchase;
- (void)setClickJsonWithClick:(Click *)click;
- (void)setPagesJsonWithPage:(Page *)page;

- (void)enterForeground;
- (void)enterBackground;

- (void)parseDeepLink:(NSString *)deepLink;
- (void)parseReferrer:(NSString *)referrer;

- (BOOL)getDOTInitFlag;
@end
