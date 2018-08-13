//
//  SessionJson.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 22..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "LocalDB.h"
@interface SessionJson : NSObject
//사용자
@property (nonatomic) NSString *mbr;
@property (nonatomic) NSString *sx;
@property (nonatomic) NSString *ag;
@property (nonatomic) NSString *ut1;
@property (nonatomic) NSString *ut2;
@property (nonatomic) NSString *ut3;
@property (nonatomic) NSString *ut4;
@property (nonatomic) NSString *ut5;
@property (nonatomic) NSString *mbl;
@property (nonatomic) NSString *mbid;
@property (nonatomic) NSString *isLogin;

//접속환경
@property (nonatomic) NSString *lng;
@property (nonatomic) NSString *cntr;
@property (nonatomic) NSString *ip;
@property (nonatomic) NSString *tz;
@property (nonatomic) NSString *os;
@property (nonatomic) NSString *sr;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *apVr;
@property (nonatomic) NSString *gps;
@property (nonatomic) NSString *cari;
@property (nonatomic) NSInteger isWifi;
@property (nonatomic) double lnch;
@property (nonatomic) NSString *plat;

//사용자 식별
@property (nonatomic) NSString *advtId;
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSInteger advtFlag;

//방문행동
//new session후 변경값
@property (nonatomic) NSString *sid;
@property (nonatomic) NSInteger udVt;
@property (nonatomic) NSInteger ltvt;
@property (nonatomic) NSInteger ltVi;

@property (nonatomic) NSString *isVisitNew;
@property (nonatomic) NSString *isDf;
@property (nonatomic) NSString *isWf;
@property (nonatomic) NSString *isMf;
@property (nonatomic) NSString *isWfUs;

//구매 이벤트 후 변경값
@property (nonatomic) NSInteger udRvnc;
@property (nonatomic) NSInteger ltRvnc;
@property (nonatomic) NSInteger csRvnVs;
@property (nonatomic) NSInteger ltrvni;
@property (nonatomic) NSString *lastOrderNo;
@property (nonatomic) NSString *firstOrd;
@property (nonatomic) NSInteger ltRvnVt;
@property (nonatomic) NSInteger ltrvn;

//페이지 이벤트 후 변경값
@property (nonatomic) NSString *piTrace;
@property (nonatomic) NSString *isSFail;

//유입경로(광고분석)
//DeepLink
@property (nonatomic) NSString *wts;
@property (nonatomic) NSString *wtm;
@property (nonatomic) NSString *wtc;
@property (nonatomic) NSString *wtw;
@property (nonatomic) NSInteger wtp;
@property (nonatomic) NSString *wtaffid;
@property (nonatomic) NSString *wtbffid;
@property (nonatomic) NSString *wtref;
@property (nonatomic) long long wtclkTime;
@property (nonatomic) NSString *dSource;
@property (nonatomic) NSString *pushNo;

//Referrer
@property (nonatomic) NSString *its;
@property (nonatomic) NSString *itm;
@property (nonatomic) NSString *itc;
@property (nonatomic) NSString *itw;
@property (nonatomic) NSInteger itp;
@property (nonatomic) NSString *itaffid;
@property (nonatomic) NSString *itbffid;
@property (nonatomic) long long itclkTime;
@property (nonatomic) long long installTime;
@property (nonatomic) NSString *installReferrer;

//App Info
@property (nonatomic) NSString *_wthst;
@property (nonatomic) NSInteger _wtno;
@property (nonatomic) NSInteger _wtUdays;
@property (nonatomic) BOOL _wtDebug;
@property (nonatomic) BOOL _wtUseRetention;
@property (nonatomic) BOOL _wtUseFingerPrint;
@property (nonatomic) NSString *_accessToken;

//시간
@property (nonatomic) long long vtTz;
@property (nonatomic) NSTimeInterval networkTime;
@property (nonatomic) NSTimeInterval deviceTime;
@property (nonatomic) NSNumber *timeOffset;

+ (instancetype)sharedInstance;
+ (void)clearInstance;
@end
