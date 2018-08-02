//
//  SessionController.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 9..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionJson.h"
#import "RevenueJson.h"
#import "PagesJson.h"
#import "LocalDB.h"
@interface SessionController : NSObject

@property (nonatomic) SessionJson *sessionJson;
@property (nonatomic) RevenueJson *revenueJson;
@property (nonatomic) PagesJson *pagesJson;
@property (nonatomic) CBLDatabase *database;
@property (nonatomic) CBLMutableDocument *behaviorDoc;
@property (nonatomic) CBLMutableDocument *enviromentDoc;
//+ (instancetype)sharedInstance;
- (instancetype)init;
- (void)updateUdVt;
- (void)updateLtvt;
- (void)updateLtVi;

// 일/주/월순수 체크
- (void)updateIsDf;
- (void)updateIsWf;
- (void)updateIsMf;
- (void)updateIsWfUs;

//재방문 체크
- (void)updateUdRvnc;
- (void)checkToResetUdRvnc;
- (void)updateLtRvnc;

- (void)updateCsRvnVs;
- (void)updateLtrvn;

- (void)updateLtrvni;

- (void)updateLastOrderNo;
- (void)updateFirstOrd;
- (void)resetLtRvnVt;
- (void)updateLtRvnVt;

- (void)updatePiTrace;

- (void)saveRecentSessionTimeSec;
- (void)saveEnviromentData;
- (void)saveAppInfo:(NSMutableArray *)appInfo;

- (void)updateIsVisitNew;
- (void)resetAboutNewVistInfo;

- (void)saveSessionExpireTime;

- (void)resetSid;
- (void)resetVtTz;
@end
