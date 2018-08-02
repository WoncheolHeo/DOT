//
//  Environment.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 25..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOTReachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
@interface Environment : NSObject

//@property (nonatomic) NSString *lng;
//@property (nonatomic) NSString *cntr;
//@property (nonatomic) NSString *ip;
//@property (nonatomic) NSString *tz;
//@property (nonatomic) NSString *os;
//@property (nonatomic) NSString *sr;
//@property (nonatomic) NSString *phone;
//@property (nonatomic) NSString *apVr;
//@property (nonatomic) NSString *gps;
//@property (nonatomic) NSString *cari;
//@property (nonatomic) NSInteger isWifi;
//@property (nonatomic) double *lnch;
//@property (nonatomic) NSString *plat;

- (NSString *)getLng;
- (NSString *)getCntr;
- (NSString *)getTz;
- (NSString *)getOs;
- (NSString *)getSr;
- (NSString *)getPhone;
- (NSString *)getApVr;
- (void)setGpsIsOn:(NSString *)gpsIsOn;
- (NSString *)getCari;
- (NSInteger)getIsWifi;
- (NSString *)getPlatfrom;
- (double)getInch;
@end
