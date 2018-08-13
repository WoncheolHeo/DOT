//
//  RevenueJson.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 26..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
@interface RevenueJson : NSObject
@property (nonatomic) long long vtTz;
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
@property (nonatomic) NSMutableArray <NSMutableDictionary *> *productList;
@property (nonatomic) NSString* ordNo;

@property (nonatomic) NSMutableDictionary *finalRevenueJson;

@end
