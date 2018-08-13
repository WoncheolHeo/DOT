//
//  DOT.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 18..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "Purchase.h"
#import "Conversion.h"
#import "Page.h"
#import "Click.h"
#import "User.h"
#import "Referrer.h"

#import <Foundation/Foundation.h>


//! Project version number for DOT.
FOUNDATION_EXPORT double DOTVersionNumber;

//! Project version string for DOT.
FOUNDATION_EXPORT const unsigned char DOTVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DOT/PublicHeader.h>

@interface DOT : NSObject

//SDK 세팅함수
+ (void)applicationKey:(NSString *)appKey;
+ (void)setApplication:(UIApplication *)newValue;
+ (void)initEnd;

//고객사 사용함수
+ (void)setUser:(User *)user;
+ (void)setDeepLink:(NSString *)deepLink;
+ (void)setReferrer:(Referrer *)refferer;
+ (void)setPurchase:(Purchase *)purchase;
+ (void)setConversion:(Conversion *)conversion;
+ (void)setPage:(Page *)page;
+ (void)setClick:(Click *)click;
+ (void)startPage;
+ (void)endPage;
+ (void)enterForeground;
+ (void)enterBackground;
//서버전송 함수
+ (void)sendTransaction;
@end

