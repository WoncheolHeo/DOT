//
//  RevenueData.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 26..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Purchase.h"
@interface RevenueData : NSObject

@property (nonatomic) NSInteger vtTz;
@property (nonatomic) NSString* scart;
@property (nonatomic) NSString* skwd;
@property (nonatomic) NSString* mvt1;
@property (nonatomic) NSString* mvt2;
@property (nonatomic) NSString* mvt3;
@property (nonatomic) NSString* mvt4;
@property (nonatomic) NSString* mvt5;
@property (nonatomic) NSString* mvt6;
@property (nonatomic) NSString* mvt7;
@property (nonatomic) NSString* mvt8;
@property (nonatomic) NSString* mvt9;
@property (nonatomic) NSString* mvt10;
@property (nonatomic) NSString* pg1;
@property (nonatomic) NSString* pg2;
@property (nonatomic) NSString* pg3;
@property (nonatomic) NSString* pg4;
@property (nonatomic) NSString* pnc;
@property (nonatomic) NSString* pnAtr1;
@property (nonatomic) NSString* pnAtr2;
@property (nonatomic) NSString* pnAtr3;
@property (nonatomic) NSString* pnAtr4;
@property (nonatomic) NSString* pnAtr5;
@property (nonatomic) NSString* pnAtr6;
@property (nonatomic) NSString* pnAtr7;
@property (nonatomic) NSString* pnAtr8;
@property (nonatomic) NSString* pnAtr9;
@property (nonatomic) NSString* pnAtr10;
@property (nonatomic) double amt;
@property (nonatomic) NSInteger ea;
@property (nonatomic) double rfnd;
@property (nonatomic) NSInteger rfea;
@property (nonatomic) NSString* ordPno;
@property (nonatomic) NSString* ordNo;
@property (nonatomic) NSMutableArray <NSMutableDictionary *> *productList;



@end
