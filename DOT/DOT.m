//
//  DOT.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 27..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "DOT.h"
#import "Tracker.h"
#import "SessionController.h"
@interface DOT ()

@property (nonatomic) SessionController *sessionController;
@property (nonatomic) Page *page;

@end

@implementation DOT


UIApplication* _application = nil;

+ (void)applicationKey:(NSString *)appKey {
    
    [Tracker applicationKey:appKey];
}

+ (void)setApplication:(UIApplication *)newValue {
    _application = newValue;
}

+ (void)initEnd {
    [[Tracker sharedInstance] initEnd];
}

- (instancetype)init {
    return self;
}

+ (void)sendTransaction {
    [[Tracker sharedInstance] sendTransaction];
}

+ (void)setUser:(User *)user {
    [user setUser];
    
    [[Tracker sharedInstance] saveUserLoginInfo];
}

+ (void)setDeepLink:(NSString *)deepLink {
    Referrer *referrer = [[Referrer alloc] init];
    [referrer setDeepLink:deepLink];
    [referrer parseDeepLink:deepLink];
    
}

+ (void)setReferrer:(Referrer *)refferer {
    
    [refferer setReferrer];
    [refferer parseReferrer:refferer.referrer];
}

+ (void)setPurchase:(Purchase *)purchase {
    [purchase setPurchase];
    
    
    //동일주문번호 발생시 패스
    //     NSString *lastOrderNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOrderNumber"];
    //    if([[RevenueJson sharedInstance].ordNo isEqualToString:lastOrderNo]) {
    //        return;
    //    }
    
    [self updateValuesBeforeSending];
    [self sendTransaction];
    
    [self updateValuesAfterSending];
}

+ (void)updateValuesBeforeSending {
    [[Tracker sharedInstance] updateBeforePurchase];
    //    SessionController *sessionController = [SessionController sharedInstance];
    //
    //    [sessionController updateUdRvnc];
    //    [sessionController updateLtRvnc];
    //    [sessionController updateLtrvn];
    //    [sessionController updateCsRvnVs];
    //    [sessionController updateLtrvni];
    //    [sessionController updateFirstOrd];
    
}

+ (void)updateValuesAfterSending {
    [[Tracker sharedInstance] updateAfterPurchase];
    
}

+ (void)setConversion:(Conversion *)conversion {
    [conversion setConversion];
    [self sendTransaction];
}

+ (void)setPage:(Page *)page {
    
    [page setPage];
}

+ (void)setClickEvent:(ClickEvent *)clickEvent {
    [clickEvent setClickEvent];
    [self sendTransaction];
}

+ (void)startPage {
    
    [[Tracker sharedInstance] startPage];
}

+ (void)endPage {
    [[Tracker sharedInstance] endPage];
}
@end


