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

    [[Tracker sharedInstance] parseDeepLink:deepLink];
    
}

+ (void)setReferrer:(Referrer *)refferer {
    
    [[Tracker sharedInstance] parseReferrer:refferer.referrer];
}

+ (void)setPurchase:(Purchase *)purchase {
    [[Tracker sharedInstance] setRevenueJsonWithPurchase:purchase];
    
    //동일주문번호 발생시 패스
    if([[Tracker sharedInstance] checkPurchase]) {
        return;
    }
    
    [self updateValuesBeforeSending];
    [self sendTransaction];
    [self updateValuesAfterSending];
}

+ (void)updateValuesBeforeSending {
    [[Tracker sharedInstance] updateBeforePurchase];
}

+ (void)updateValuesAfterSending {
    [[Tracker sharedInstance] updateAfterPurchase];
    
}

+ (void)setConversion:(Conversion *)conversion {
    if(![[Tracker sharedInstance] getDOTInitFlag]) {
        NSLog(@"DOT is not yet initailized");
        return;
    }
    
    [[Tracker sharedInstance] setGoalJosnWithConversion:conversion];
    [self sendTransaction];
}

+ (void)setPage:(Page *)page {
    [[Tracker sharedInstance] setPagesJsonWithPage:page];
}

+ (void)setClick:(Click *)click{
    [[Tracker sharedInstance] setClickJsonWithClick:click];
    [self sendTransaction];
}

+ (void)startPage {
    if(![[Tracker sharedInstance] getDOTInitFlag]) {
        NSLog(@"DOT is not yet initailized");
        return;
    }
    [[Tracker sharedInstance] startPage];
}

+ (void)endPage {
    [[Tracker sharedInstance] endPage];
}

+ (void)enterForeground {
    [[Tracker sharedInstance] enterForeground];
}

+ (void)enterBackground {
    [[Tracker sharedInstance] enterBackground];
}
@end


