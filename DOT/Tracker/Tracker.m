//
//  Tracker.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 5..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "Tracker.h"
#import "SessionJson.h"
#import "ClickJson.h"
#import "RevenueJson.h"
#import "GoalJson.h"
#import "PagesJson.h"
#import "SessionController.h"
#import "DOTUtil.h"
#import "NSString+AESCrypt.h"
#import "LocalDB.h"
#import "DOTAPIConstant.h"
#import "DOTUtil.h"
#import "NHNetworkTime.h"
#import "NetworkManager.h"
#import "DOTReachability.h"
//#import <FBSDKCoreKit/FBSDKAppLinkUtility.h>

@interface Tracker ()
@property (nonatomic) GoalJson *goalJson;
@property (nonatomic) RevenueJson *revenueJson;
@property (nonatomic) ClickJson *clickJson;
@property (nonatomic) PagesJson *pagesJson;

@property (nonatomic) NSMutableDictionary *entireJson;
@property (nonatomic) NSMutableDictionary *exceptionJson;
@property (nonatomic) NSMutableArray *exceptionJsonList;
@property (nonatomic) NSMutableDictionary *sesssionJsonDict;

@property (nonatomic) SessionController *sessionController;
@property (nonatomic) NetworkManager *networkManager;
@property (nonatomic) BOOL newSessionYN;
@property (nonatomic) NSTimer *oneSecondTimer;
@property (nonatomic) NSMutableArray *dotAuthorizationKey;
@property (nonatomic) BOOL firstExcute;

@property (nonatomic) BOOL accessTokenRequestDone;
@property (nonatomic) BOOL fingerPrintRequestDone;
@property (nonatomic) BOOL NTPtimeGetDone;
@property (nonatomic) BOOL DOTinitYN;

@property (nonatomic) NSString *irIts;
@property (nonatomic) NSString *irItm;
@property (nonatomic) NSString *irItc;
@property (nonatomic) NSString *irItw;
@property (nonatomic) NSString *irItaffid;
@property (nonatomic) NSString *irItbffid;
@property (nonatomic) long long irItclkTime;
@property (nonatomic) NSInteger irItp;
@property (nonatomic) NSString *irInstallReferrer;

@property (nonatomic) NSString *fpIts;
@property (nonatomic) NSString *fpItm;
@property (nonatomic) NSString *fpItc;
@property (nonatomic) NSString *fpItw;
@property (nonatomic) NSString *fpItaffid;
@property (nonatomic) NSString *fpItbffid;
@property (nonatomic) long long fpItclkTime;
@property (nonatomic) NSInteger fpItp;
@property (nonatomic) NSString *fpInstallReferrer;
@end


@implementation Tracker
static NSString* appKey;

+ (Tracker *)sharedInstance{
    static dispatch_once_t pred;
    static Tracker *tracker = nil;
    dispatch_once(&pred, ^{
        tracker = [[super alloc] initUniqueInstance];
    });
    return tracker;
}

- (instancetype) initUniqueInstance {
    NSError *error;
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    if(behaviorDoc == nil) {
        behaviorDoc = [[CBLMutableDocument alloc] initWithID:@"Behavior"];
    }
    [behaviorDoc setString:@"" forKey:@"piTrace"];
    [behaviorDoc setNumber:nil forKey:@"pageStartTime"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    self.sessionController = [[SessionController alloc] init];
    self.networkManager = [[NetworkManager alloc] init];
    self.newSessionYN = YES;
    self.dotAuthorizationKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"dotAuthorizationKey"];
    self.accessTokenRequestDone = NO;
    self.NTPtimeGetDone = NO;
    self.fingerPrintRequestDone = NO;
    self.DOTinitYN = NO;
    self.exceptionJsonList = [[NSMutableArray alloc] init];
    return self;
}

+ (void)applicationKey:(NSString *)_applicationKey{
    
    NSMutableArray *dotAuthorizationKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"dotAuthorizationKey"];
    
    [SessionJson sharedInstance]._wthst = [dotAuthorizationKey objectAtIndex:0];
    [SessionJson sharedInstance]._wtno = [[dotAuthorizationKey objectAtIndex:1] integerValue];
    [SessionJson sharedInstance]._wtUdays = [[dotAuthorizationKey objectAtIndex:2] integerValue];
    [SessionJson sharedInstance]._wtDebug = [[dotAuthorizationKey objectAtIndex:3] boolValue];
    [SessionJson sharedInstance]._wtUseRetention = [[dotAuthorizationKey objectAtIndex:4] boolValue];
    [SessionJson sharedInstance]._wtUseFingerPrint = [[dotAuthorizationKey objectAtIndex:5] boolValue];
    [SessionJson sharedInstance]._accessToken = [dotAuthorizationKey objectAtIndex:6];
    
    Tracker.appKey = _applicationKey;
}

+ (void)setAppKey:(NSString *)key{
    @synchronized(self) {
        appKey = key;
    }
}

+ (NSString *)appKey{
    static NSString *key = nil;
    @synchronized(self) {
        key = appKey;
    }
    return key;
}

- (BOOL)authorizationCheckWithAuthToken:(NSString*)authToken {
    __block BOOL authSuccess;
    
    //NSString *accessToken = [authToken AES256DecryptWithKey:@"dotAmWisetracker"];
    //NSArray *arrString= [accessToken componentsSeparatedByString: @"#"];
    //NSString *package = [arrString objectAtIndex:2];
    NSString *package = [[NSBundle mainBundle] bundleIdentifier];
    
    //    NSInteger now = [DOTUtil currentTimeSec] * 1000;
    //    NSInteger validTerm = [[arrString objectAtIndex:1] integerValue];
    //|| validTerm < now
    if(([authToken isEqualToString:@""] || authToken == nil ) ) {
        NSInteger serviceNumber = [[self.dotAuthorizationKey objectAtIndex:1] integerValue];
        [self.networkManager requestAccessTokenWithServiceNumber:serviceNumber package:package completion:^(BOOL isSuccess, NSData *data, id respons) {
            if(isSuccess) {
                NSError* error;
                NSInteger httpCode = [(NSHTTPURLResponse*) respons statusCode];
                NSString *responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSLog(@"httpCode : %ld", (long) httpCode);
                NSLog(@"responseData: %@", responseData);
                NSLog(@"accessToken response: %@", response);
                NSString *receivedToken = [response objectForKey:@"token"];
                CBLMutableDocument *appInfoDoc = [[CBLMutableDocument alloc] initWithID:@"AppInfo"];
                [appInfoDoc setString:receivedToken forKey:@"accessToken"];
                [[LocalDB sharedInstance].database saveDocument:appInfoDoc error:&error];
                //app정보 로컬DB에 저장
                [self.sessionController saveAppInfo:self.dotAuthorizationKey];
                authSuccess = YES;
                self.accessTokenRequestDone = YES;
            }
            else {
                [self.networkManager sendErrorLogWithError:@"DOT LOG: AccessToken Request Error" completion:^(BOOL isSuccess, NSData *data, id respons) {
                    if(isSuccess) {
                        NSLog(@"DOT LOG: AccessToken Request Error");
                    }
                }];
                authSuccess = NO;
                self.accessTokenRequestDone = NO;
                
            }
        }];
    }
    else {
        NSError* error;
        CBLMutableDocument *appInfoDoc = [[CBLMutableDocument alloc] initWithID:@"AppInfo"];
        [appInfoDoc setString:authToken forKey:@"accessToken"];
        [[LocalDB sharedInstance].database saveDocument:appInfoDoc error:&error];
        //app정보 로컬DB에 저장
        [self.sessionController saveAppInfo:self.dotAuthorizationKey];
        authSuccess = YES;
        self.accessTokenRequestDone = YES;
    }
    return authSuccess;
}

- (void)initEnd {
    //NTP타임 동기화
    [[NHNetworkClock sharedNetworkClock] synchronize];
    
    //최초실행 여부 판단
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Install"];
    NSNumber *installTime = [document numberForKey:@"installTime"];
    
    if(installTime == nil) {
        self.firstExcute = YES;
    }
    else {
        self.firstExcute = NO;
    }
    //accessToken 요청
    NSString *authToken = [self.dotAuthorizationKey objectAtIndex:6];
    if([authToken isEqualToString:@""] || authToken == nil) {
        CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"AppInfo"];
        authToken = [document stringForKey:@"acessToken"];
    }
    if([DOTReachability isConnectedToNetwork]) {
        if(![self authorizationCheckWithAuthToken:authToken]) {
            return;
        }
    }
    //intall time세팅 & NTP타입 세팅
    [self setInstallTimeAndNTP];
    //DeepLink Referrer 초기화체크 및 수행
    [self checkToResetDRInfo];
    //finger print 요청
    [self requestFingerPrint];
    //첫실행인 경우만 facebook referrer 체크
    //    if(self.firstExcute) {
    //        [self requestFacebookReferrer];
    //    }
    //5초 지연
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if(self.accessTokenRequestDone && self.NTPtimeGetDone && self.fingerPrintRequestDone) {
            self.DOTinitYN = YES;
        }
        
        if(self.DOTinitYN) {
            [self checkInstallReferrerOrder];
            if([self checkNewSession]) {
                [SessionJson clearInstance];
                [self occurNewSessionWithType:1];
                [self.sessionController resetAboutNewVistInfo];
                
            }
            if(self.exceptionJsonList.count > 0) {
                for(NSInteger i = 0; i < self.exceptionJsonList.count; i++) {
                    [self exceptionSendToServeWithIndex:i];
                }
            }
        }
        else {
            [self initEnd];
        }
    });
}

- (void)checkInstallReferrerOrder {
    NSError *error;
    CBLMutableDocument *installReferrerDoc = [[CBLMutableDocument alloc] initWithID:@"InstallReferrerInfo"];
    
    if(!self.irItclkTime && !self.fpItclkTime) {
        return;
    }
    if(self.irItclkTime > self.fpItclkTime) {
        [installReferrerDoc setString:self.irIts forKey:@"its"];
        [installReferrerDoc setString:self.irItm forKey:@"itm"];
        [installReferrerDoc setString:self.irItc forKey:@"itc"];
        [installReferrerDoc setString:self.irItw forKey:@"itw"];
        [installReferrerDoc setInteger:self.irItp forKey:@"itp"];
        [installReferrerDoc setString:self.irItaffid forKey:@"itaffid"];
        [installReferrerDoc setString:self.irItbffid forKey:@"itbffid"];
        [installReferrerDoc setNumber:[[NSNumber alloc] initWithLongLong:self.irItclkTime] forKey:@"itclkTime"];
        [installReferrerDoc setString:self.irInstallReferrer forKey:@"installReferrer"];
    }
    else {
        [installReferrerDoc setString:self.fpIts forKey:@"its"];
        [installReferrerDoc setString:self.fpItm forKey:@"itm"];
        [installReferrerDoc setString:self.fpItc forKey:@"itc"];
        [installReferrerDoc setString:self.fpItw forKey:@"itw"];
        [installReferrerDoc setInteger:self.fpItp forKey:@"itp"];
        [installReferrerDoc setString:self.fpItaffid forKey:@"itaffid"];
        [installReferrerDoc setString:self.fpItbffid forKey:@"itbffid"];
        [installReferrerDoc setNumber:[[NSNumber alloc] initWithLongLong:self.fpItclkTime] forKey:@"itclkTime"];
        [installReferrerDoc setString:self.fpInstallReferrer forKey:@"installReferrer"];
    }
    
    [[LocalDB sharedInstance].database saveDocument:installReferrerDoc error:&error];
    
}
- (void)requestFacebookReferrer {
    //    NSMutableDictionary *fbDict = [[NSMutableDictionary alloc] init];
    //    [fbDict setValue:@"www.facebookreferrertest.co.kr?wts=P1528963175025&wtc=C1452144464663&wtm=&wtw=&wtaffid=facebook&wtbffid=facebook2&wtclkTime=1433607852278&_wtcid=DOP102_3443436477568846_bd3660eb78fd43bbaa3883354a4883c9&_sub1=&_sub2=&_sub3=&_sub4=&_sub5=&_sub6=&_sub7=&_wtckp=1440" forKey:@"target_url"];
    //    if([fbDict objectForKey:@"target_url"] != nil){
    //        NSString *result = (NSString*)[fbDict objectForKey:@"target_url"];
    //        [self parseReferrer:result];
    //    }
    //    [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
    //        if(error) {
    //            NSLog(@"Received error while fetching deferred app link %@", error);
    //        }
    //        if(url) {
    //            NSArray* params = [[url query] componentsSeparatedByString:@"&"];
    //            if( [params count] > 0 ){
    //                for (NSString * value in params) {
    //                    NSArray * bits = [value componentsSeparatedByString:@"="];
    //                    NSString * key = [[bits objectAtIndex:0] stringByRemovingPercentEncoding];
    //                    NSString * value = [[bits objectAtIndex:1] stringByRemovingPercentEncoding];
    //                    if([key isEqualToString:@"al_applink_data"]){
    //                        NSError *jsonError;
    //                        NSData *objectData = [value dataUsingEncoding:NSUTF8StringEncoding];
    //                        NSDictionary *fbDict = [NSJSONSerialization JSONObjectWithData:objectData
    //                                                                                 options:NSJSONReadingMutableContainers
    //                                                                                   error:&jsonError];
    //                        if([fbDict objectForKey:@"target_url"] != nil){
    //                            NSString *result = (NSString*)[fbDict objectForKey:@"target_url"];
    //                            [self parseReferrer:result];
    //                        }
    //                    }else{
    //
    //                    }
    //                }
    //            }
    //        }
    //    }];
}

- (void)checkToResetDRInfo {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"DeeplinkReferrerInfo"];
    NSNumber *tmpNum = [document numberForKey:@"DRExpireTime"];
    if(tmpNum != nil) {
        double DRExpireTime = [tmpNum doubleValue];
        double now = [DOTUtil currentTimeSec];
        if(now > DRExpireTime) {
            [self resetDRInfo];
        }
    }
}

- (void)resetDRInfo {
    NSError *error;
    // CBLMutableDocument *deeplinkReferrerDoc = [[CBLMutableDocument alloc] initWithID:@"DeeplinkReferrerInfo"];
    CBLMutableDocument *deeplinkReferrerDoc = [[[LocalDB sharedInstance].database documentWithID:@"DeeplinkReferrerInfo"] toMutable];
    
    [deeplinkReferrerDoc setString:@"" forKey:@"wts"];
    [deeplinkReferrerDoc setString:@"" forKey:@"wtm"];
    [deeplinkReferrerDoc setString:@"" forKey:@"wtc"];
    [deeplinkReferrerDoc setString:@"" forKey:@"wtw"];
    [deeplinkReferrerDoc setValue:@"" forKey:@"wtp"];
    [deeplinkReferrerDoc setString:@"" forKey:@"wtaffid"];
    [deeplinkReferrerDoc setString:@"" forKey:@"wtbffid"];
    [deeplinkReferrerDoc setValue:@"" forKey:@"wtclkTime"];
    [deeplinkReferrerDoc setString:@"" forKey:@"wtref"];
    
    
    [[LocalDB sharedInstance].database saveDocument:deeplinkReferrerDoc error:&error];
}

- (void)exceptionSendToServeWithIndex:(NSInteger)index {
    [self createSessionJson];
    
    NSMutableDictionary *willSendExceptionJson = (NSMutableDictionary *)[self.exceptionJsonList objectAtIndex:index];
    if([willSendExceptionJson objectForKey:@"PAGES"] != nil) {
        self.pagesJson.finalPagesJson = (NSMutableDictionary *)[willSendExceptionJson objectForKey:@"PAGES"];
        [self createEntireJson2];
    }
    else {
        if([willSendExceptionJson objectForKey:@"CLICK"] != nil) {
            self.clickJson.finalClickJson = (NSMutableDictionary *)[willSendExceptionJson objectForKey:@"CLICK"];
        }
        else if([willSendExceptionJson objectForKey:@"GOAL"] != nil) {
            self.goalJson.finalGoalJson = (NSMutableDictionary *)[willSendExceptionJson objectForKey:@"GOAL"];
        }
        else if([willSendExceptionJson objectForKey:@"REVENUE"] != nil) {
            self.revenueJson.finalRevenueJson = (NSMutableDictionary *)[willSendExceptionJson objectForKey:@"REVENUE"];
        }
        [self createEntireJson];
        
    }
    
}

- (void)setInstallTimeAndNTP {
    
    if([DOTReachability isConnectedToNetwork] && self.firstExcute) {
        [self createUpdateTimer];
    }
    else if(![DOTReachability isConnectedToNetwork] && self.firstExcute){
        NSNumber *installTime = @([DOTUtil currentTimeSec]* 1000);
        NSError *error;
        CBLMutableDocument *installDoc = [[[LocalDB sharedInstance].database documentWithID:@"Install"] toMutable];
        if(installDoc == nil) {
            installDoc = [[CBLMutableDocument alloc] initWithID:@"Install"];
        }
        [installDoc setNumber:installTime forKey:@"installTime"];
        [[LocalDB sharedInstance].database saveDocument:installDoc error:&error];
        [SessionJson sharedInstance].installTime = [installTime longLongValue];
        self.NTPtimeGetDone = YES;
    }
    else if([DOTReachability isConnectedToNetwork] && !self.firstExcute) {
        [self createUpdateTimer];
    }
    else if(![DOTReachability isConnectedToNetwork] && !self.firstExcute) {
        NSError *error;
        CBLMutableDocument *installDoc = [[[LocalDB sharedInstance].database documentWithID:@"Install"] toMutable];
        if(installDoc == nil) {
            installDoc = [[CBLMutableDocument alloc] initWithID:@"Install"];
        }
        [installDoc setNumber:@(0) forKey:@"timeOffset"];
        [[LocalDB sharedInstance].database saveDocument:installDoc error:&error];
        self.NTPtimeGetDone = YES;
    }
}

- (void)requestFingerPrint {
    NSInteger wtno = [[self.dotAuthorizationKey objectAtIndex:1] integerValue];
    [self.networkManager requestFingerPrintWithWtno:wtno completion:^(BOOL isSuccess, NSData *data, id respons) {
        if(isSuccess) {
            NSError* error;
            NSInteger httpCode = [(NSHTTPURLResponse*) respons statusCode];
            NSString *responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSLog(@"httpCode : %ld", (long) httpCode);
            NSLog(@"responseData: %@", responseData);
            NSLog(@"fingerPrint response: %@", response);
            if(response.count > 0 && self.firstExcute) {
                [self saveInstallReferrerWithFingerPrint:response];
            }
            else if(response.count > 0 && !self.firstExcute) {
                [self saveDeepLinkWithFingerPrint:response];
            }
            self.fingerPrintRequestDone = YES;
        }
        else {
            NSLog(@"first FingerPrint Reqeust fail");
            self.fingerPrintRequestDone = NO;
        }
    }];
}

- (void)createUpdateTimer {
    self.oneSecondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(oneSecondTimerTick) userInfo:nil repeats:YES];
}

- (void)oneSecondTimerTick {
    if([NHNetworkClock sharedNetworkClock].isSynchronized) {
        [self.oneSecondTimer invalidate];
        NSDate *networkTime = [NSDate networkDate];
        NSDate *deviceTime = [[NSDate alloc] init];
        
        NSTimeInterval nt = [networkTime timeIntervalSince1970];
        NSTimeInterval dt = [deviceTime timeIntervalSince1970];
        
        NSNumber *installTime;
        if(self.firstExcute) {
            installTime = @([networkTime timeIntervalSince1970] * 1000);
        }
        NSNumber *timeOffset = @(nt - dt);
        NSError *error;
        CBLMutableDocument *installDoc = [[[LocalDB sharedInstance].database documentWithID:@"Install"] toMutable];
        if(installDoc == nil) {
            installDoc = [[CBLMutableDocument alloc] initWithID:@"Install"];
        }
        if(self.firstExcute) {
            [installDoc setNumber:installTime forKey:@"installTime"];
        }
        [installDoc setNumber:timeOffset forKey:@"timeOffset"];
        [[LocalDB sharedInstance].database saveDocument:installDoc error:&error];
        self.NTPtimeGetDone = YES;
    }
    else {
        NSLog(@"not yet time sync");
    }
}

- (void)occurNewSessionWithType:(NSInteger)type {
    [self.sessionController resetSid];
    [self.sessionController resetVtTz];
    
    [self.sessionController updateIsVisitNew];
    [self.sessionController updateIsDf];
    [self.sessionController updateIsWf];
    [self.sessionController updateIsMf];
    [self.sessionController updateIsWfUs];
    
    [self.sessionController updateUdVt];
    [self.sessionController updateLtvt];
    [self.sessionController updateLtVi];
    [self.sessionController updateLtRvnVt];
    
    [self.sessionController saveRecentSessionTimeSec];
    [self.sessionController saveSessionExpireTime];
    [self.sessionController checkToResetUdRvnc];
    
    if(type == 1) {
        [self createSessionJson];
        self.entireJson = [[NSMutableDictionary alloc] init];
        [self.entireJson setValue:self.sesssionJsonDict forKey:@"SESSION"];
        [self sendToServer];
    }
}

- (BOOL)sendTransaction {
    //현재시간이 마지막 서버전송시간보다 크면 newSession 발생
    if( [self checkNewSession] && self.DOTinitYN) {
        [SessionJson clearInstance];
        [self occurNewSessionWithType:2];
        [self.sessionController resetAboutNewVistInfo];
    }
    [self makeJson];
    return YES;
}

- (BOOL)sendTransactionByPage {
    //현재시간이 마지막 서버전송시간보다 크면 newSession 발생
    if([self checkNewSession] && self.DOTinitYN) {
        [SessionJson clearInstance];
        [self occurNewSessionWithType:2];
        [self.sessionController resetAboutNewVistInfo];
    }
    
    [self makeJson2];
    return YES;
}

- (void)makeJson {
    [self createSessionJson];
    [self createGoalJson];
    [self createRevenueJson];
    [self createClickJson];
    [self createEntireJson];
}

- (void)makeJson2 {
    [self createSessionJson];
    [self createPagesJson];
    [self createEntireJson2];
}

- (void)createSessionJson {
    SessionJson *sessionJson = [SessionJson sharedInstance];
    
    self.sesssionJsonDict = [[NSMutableDictionary alloc] init];
    
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithLongLong:sessionJson.installTime] forKey:@"installTime"];
    //사용자
    [self.sesssionJsonDict setValue:sessionJson.mbr forKey:@"mbr"];
    [self.sesssionJsonDict setValue:sessionJson.sx forKey:@"sx"];
    [self.sesssionJsonDict setValue:sessionJson.ag forKey:@"ag"];
    [self.sesssionJsonDict setValue:sessionJson.mbl forKey:@"mbl"];
    [self.sesssionJsonDict setValue:sessionJson.mbid forKey:@"mbid"];
    [self.sesssionJsonDict setValue:sessionJson.ut1 forKey:@"ut1"];
    [self.sesssionJsonDict setValue:sessionJson.ut2 forKey:@"ut2"];
    [self.sesssionJsonDict setValue:sessionJson.ut3 forKey:@"ut3"];
    [self.sesssionJsonDict setValue:sessionJson.ut4 forKey:@"ut4"];
    [self.sesssionJsonDict setValue:sessionJson.ut5 forKey:@"ut5"];
    [self.sesssionJsonDict setValue:sessionJson.isLogin forKey:@"isLogin"];
    
    //접속환경
    [self.sesssionJsonDict setValue:sessionJson.cntr forKey:@"cntr"];
    [self.sesssionJsonDict setValue:sessionJson.lng forKey:@"lng"];
    [self.sesssionJsonDict setValue:sessionJson.tz forKey:@"tz"];
    [self.sesssionJsonDict setValue:sessionJson.os forKey:@"os"];
    [self.sesssionJsonDict setValue:sessionJson.sr forKey:@"sr"];
    [self.sesssionJsonDict setValue:sessionJson.phone forKey:@"phone"];
    [self.sesssionJsonDict setValue:sessionJson.apVr forKey:@"apVr"];
    [self.sesssionJsonDict setValue:sessionJson.cari forKey:@"cari"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithDouble:sessionJson.isWifi] forKey:@"isWifi"];
    [self.sesssionJsonDict setValue:sessionJson.plat forKey:@"plat"];
    
    //사용자 식별
    [self.sesssionJsonDict setValue:sessionJson.advtId forKey:@"advtId"];
    [self.sesssionJsonDict setValue:sessionJson.uuid forKey:@"uuid"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.advtFlag] forKey:@"advtFlag"];
    
    //방문행동
    [self.sesssionJsonDict setValue:sessionJson.sid forKey:@"sid"];
    [self.sesssionJsonDict setValue:sessionJson.isVisitNew forKey:@"isVisitNew"];
    [self.sesssionJsonDict setValue:sessionJson.isDf forKey:@"isDf"];
    [self.sesssionJsonDict setValue:sessionJson.isWf forKey:@"isWf"];
    [self.sesssionJsonDict setValue:sessionJson.isMf forKey:@"isMf"];
    [self.sesssionJsonDict setValue:sessionJson.isWfUs forKey:@"isWfUs"];
    
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.udVt] forKey:@"udVt"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.ltvt] forKey:@"ltvt"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.ltVi] forKey:@"ltVi"];
    
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.udRvnc] forKey:@"udRvnc"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.ltRvnc] forKey:@"ltRvnc"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.csRvnVs] forKey:@"csRvnVs"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.ltrvni] forKey:@"ltrvni"];
    [self.sesssionJsonDict setValue:sessionJson.lastOrderNo forKey:@"lastOrderNo"];
    [self.sesssionJsonDict setValue:sessionJson.firstOrd forKey:@"firstOrd"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.ltRvnVt] forKey:@"ltRvnVt"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.ltRvnVt] forKey:@"ltRvnVt"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.ltrvn] forKey:@"ltrvn"];
    
    [self.sesssionJsonDict setValue:sessionJson.piTrace forKey:@"piTrace"];
    [self.sesssionJsonDict setValue:sessionJson.isSFail forKey:@"isSFail"];
    
    
    //유입경로
    //deep link
    [self.sesssionJsonDict setValue:sessionJson.wts forKey:@"wts"];
    [self.sesssionJsonDict setValue:sessionJson.wtm forKey:@"wtm"];
    [self.sesssionJsonDict setValue:sessionJson.wtc forKey:@"wtc"];
    [self.sesssionJsonDict setValue:sessionJson.wtw forKey:@"wtw"];
    if(sessionJson.wtp) {
        [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.wtp] forKey:@"wtp"];
    }
    [self.sesssionJsonDict setValue:sessionJson.wtaffid forKey:@"wtaffid"];
    [self.sesssionJsonDict setValue:sessionJson.wtbffid forKey:@"wtbffid"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithLongLong:sessionJson.wtclkTime] forKey:@"wtclkTime"];
    [self.sesssionJsonDict setValue:sessionJson.wtref forKey:@"wtref"];
    [self.sesssionJsonDict setValue:sessionJson.pushNo forKey:@"pushNo"];
    
    //install referrer
    [self.sesssionJsonDict setValue:sessionJson.its forKey:@"its"];
    [self.sesssionJsonDict setValue:sessionJson.itm forKey:@"itm"];
    [self.sesssionJsonDict setValue:sessionJson.itc forKey:@"itc"];
    [self.sesssionJsonDict setValue:sessionJson.itw forKey:@"itw"];
    if(sessionJson.itp) {
        [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.itp] forKey:@"itp"];
    }
    [self.sesssionJsonDict setValue:sessionJson.itaffid forKey:@"itaffid"];
    [self.sesssionJsonDict setValue:sessionJson.itbffid forKey:@"itbffid"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithLongLong:sessionJson.itclkTime] forKey:@"itclkTime"];
    [self.sesssionJsonDict setValue:sessionJson.installReferrer forKey:@"installReferrer"];
    
    
    //From info.plist
    [self.sesssionJsonDict setValue:sessionJson._wthst forKey:@"_wthst"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson._wtno] forKey:@"_wtno"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson._wtUdays] forKey:@"_wtUdays"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithBool:sessionJson._wtDebug] forKey:@"_wtDebug"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithBool:sessionJson._wtUseRetention] forKey:@"_wtUseRetention"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithBool:sessionJson._wtUseFingerPrint] forKey:@"_wtUseFingerPrint"];
    [self.sesssionJsonDict setValue:sessionJson._accessToken forKey:@"_accessToken"];
    //컨텐츠분석
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithLongLong:sessionJson.vtTz] forKey:@"vtTz"];
}

- (void)createGoalJson {
    NSMutableDictionary *goalJsonDict = [[NSMutableDictionary alloc] init];
    
    //productDic 값세팅
    [goalJsonDict setValue:self.goalJson.scart forKey:@"scart"];
    [goalJsonDict setValue:self.goalJson.skwd forKey:@"skwd"];
    
    //CustomValue setting
    [goalJsonDict setValue:self.goalJson.mvt1 forKey:@"mvt1"];
    [goalJsonDict setValue:self.goalJson.mvt2 forKey:@"mvt2"];
    [goalJsonDict setValue:self.goalJson.mvt3 forKey:@"mvt3"];
    [goalJsonDict setValue:self.goalJson.mvt4 forKey:@"mvt4"];
    [goalJsonDict setValue:self.goalJson.mvt5 forKey:@"mvt5"];
    [goalJsonDict setValue:self.goalJson.mvt6 forKey:@"mvt6"];
    [goalJsonDict setValue:self.goalJson.mvt7 forKey:@"mvt7"];
    [goalJsonDict setValue:self.goalJson.mvt8 forKey:@"mvt8"];
    [goalJsonDict setValue:self.goalJson.mvt9 forKey:@"mvt9"];
    [goalJsonDict setValue:self.goalJson.mvt10 forKey:@"mvt10"];
    
    //Product setting
    [goalJsonDict setValue:self.goalJson.pg1 forKey:@"pg1"];
    [goalJsonDict setValue:self.goalJson.pg2 forKey:@"pg2"];
    [goalJsonDict setValue:self.goalJson.pg3 forKey:@"pg3"];
    [goalJsonDict setValue:self.goalJson.pg4 forKey:@"pg4"];
    [goalJsonDict setValue:self.goalJson.pnc forKey:@"pnc"];
    [goalJsonDict setValue:self.goalJson.pnAtr1 forKey:@"pnAtr1"];
    [goalJsonDict setValue:self.goalJson.pnAtr2 forKey:@"pnAtr2"];
    [goalJsonDict setValue:self.goalJson.pnAtr3 forKey:@"pnAtr3"];
    [goalJsonDict setValue:self.goalJson.pnAtr4 forKey:@"pnAtr4"];
    [goalJsonDict setValue:self.goalJson.pnAtr5 forKey:@"pnAtr5"];
    [goalJsonDict setValue:self.goalJson.pnAtr6 forKey:@"pnAtr6"];
    [goalJsonDict setValue:self.goalJson.pnAtr7 forKey:@"pnAtr7"];
    [goalJsonDict setValue:self.goalJson.pnAtr8 forKey:@"pnAtr8"];
    [goalJsonDict setValue:self.goalJson.pnAtr9 forKey:@"pnAtr9"];
    [goalJsonDict setValue:self.goalJson.pnAtr10 forKey:@"pnAtr10"];
    
    if(self.goalJson.g1) {
        [goalJsonDict setValue:[[NSNumber alloc] initWithDouble:self.goalJson.g1] forKey:@"g1"];
    }
    if(self.goalJson.g2) {
        [goalJsonDict setValue:[[NSNumber alloc] initWithDouble:self.goalJson.g2] forKey:@"g2"];
    }
    if(self.goalJson.g78) {
        [goalJsonDict setValue:[[NSNumber alloc] initWithBool:self.goalJson.g78] forKey:@"g78"];
    }
    
    self.goalJson.finalGoalJson = goalJsonDict;
}

- (void)createPagesJson {
    NSMutableDictionary *pagesJsonDict = [[NSMutableDictionary alloc] init];
    //pageDict 값세팅
    [pagesJsonDict setValue:self.pagesJson.scart forKey:@"scart"];
    [pagesJsonDict setValue:self.pagesJson.skwd forKey:@"skwd"];
    [pagesJsonDict setValue:self.pagesJson.cp forKey:@"cp"];
    [pagesJsonDict setValue:self.pagesJson.pi forKey:@"pi"];
    if(self.pagesJson.vs) {
        [pagesJsonDict setValue:[[NSNumber alloc] initWithDouble:self.pagesJson.vs] forKey:@"vs"];
    }
    
    if(self.pagesJson.sresult != nil) {
        [pagesJsonDict setValue:self.pagesJson.sresult forKey:@"sresult"];
    }
    
    if(self.pagesJson.pv) {
        [pagesJsonDict setValue:[[NSNumber alloc] initWithInteger:self.pagesJson.pv] forKey:@"pv"];
    }
    
    //CustomValue setting
    [pagesJsonDict setValue:self.pagesJson.mvt1 forKey:@"mvt1"];
    [pagesJsonDict setValue:self.pagesJson.mvt2 forKey:@"mvt2"];
    [pagesJsonDict setValue:self.pagesJson.mvt3 forKey:@"mvt3"];
    [pagesJsonDict setValue:self.pagesJson.mvt4 forKey:@"mvt4"];
    [pagesJsonDict setValue:self.pagesJson.mvt5 forKey:@"mvt5"];
    [pagesJsonDict setValue:self.pagesJson.mvt6 forKey:@"mvt6"];
    [pagesJsonDict setValue:self.pagesJson.mvt7 forKey:@"mvt7"];
    [pagesJsonDict setValue:self.pagesJson.mvt8 forKey:@"mvt8"];
    [pagesJsonDict setValue:self.pagesJson.mvt9 forKey:@"mvt9"];
    [pagesJsonDict setValue:self.pagesJson.mvt10 forKey:@"mvt10"];
    
    //Product setting
    [pagesJsonDict setValue:self.pagesJson.pg1 forKey:@"pg1"];
    [pagesJsonDict setValue:self.pagesJson.pg2 forKey:@"pg2"];
    [pagesJsonDict setValue:self.pagesJson.pg3 forKey:@"pg3"];
    [pagesJsonDict setValue:self.pagesJson.pg4 forKey:@"pg4"];
    [pagesJsonDict setValue:self.pagesJson.pnc forKey:@"pnc"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr1 forKey:@"pnAtr1"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr2 forKey:@"pnAtr2"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr3 forKey:@"pnAtr3"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr4 forKey:@"pnAtr4"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr5 forKey:@"pnAtr5"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr6 forKey:@"pnAtr6"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr7 forKey:@"pnAtr7"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr8 forKey:@"pnAtr8"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr9 forKey:@"pnAtr9"];
    [pagesJsonDict setValue:self.pagesJson.pnAtr10 forKey:@"pnAtr10"];
    
    if(self.pagesJson.vtTz) {
        [pagesJsonDict setValue:[[NSNumber alloc] initWithLongLong:self.pagesJson.vtTz] forKey:@"vtTz"];
    }
    self.pagesJson.finalPagesJson = pagesJsonDict;
}

- (void)createClickJson {
    //clickEventDict 값세팅
    NSMutableDictionary *clickJsontDict = [[NSMutableDictionary alloc] init];
    
    [clickJsontDict setValue:self.clickJson.ckTp forKey:@"ckTp"];
    [clickJsontDict setValue:self.clickJson.ckData forKey:@"ckData"];
    
    if(self.clickJson.vtTz) {
        [clickJsontDict setValue:[[NSNumber alloc] initWithLongLong:self.clickJson.vtTz] forKey:@"vtTz"];
    }
    
    //CustomValue setting
    [clickJsontDict setValue:self.clickJson.mvt1 forKey:@"mvt1"];
    [clickJsontDict setValue:self.clickJson.mvt2 forKey:@"mvt2"];
    [clickJsontDict setValue:self.clickJson.mvt3 forKey:@"mvt3"];
    [clickJsontDict setValue:self.clickJson.mvt4 forKey:@"mvt4"];
    [clickJsontDict setValue:self.clickJson.mvt5 forKey:@"mvt5"];
    [clickJsontDict setValue:self.clickJson.mvt6 forKey:@"mvt6"];
    [clickJsontDict setValue:self.clickJson.mvt7 forKey:@"mvt7"];
    [clickJsontDict setValue:self.clickJson.mvt8 forKey:@"mvt8"];
    [clickJsontDict setValue:self.clickJson.mvt9 forKey:@"mvt9"];
    [clickJsontDict setValue:self.clickJson.mvt10 forKey:@"mvt10"];
    
    self.clickJson.finalClickJson = clickJsontDict;
}

- (void)createRevenueJson {
    NSMutableDictionary *revenueJsonDict = [[NSMutableDictionary alloc] init];
    
    //revenueJsonDict 값세팅
    if(self.revenueJson.vtTz) {
        [revenueJsonDict setValue:[[NSNumber alloc] initWithLongLong:self.revenueJson.vtTz] forKey:@"vtTz"];
    }
    
    [revenueJsonDict setValue:self.revenueJson.scart forKey:@"scart"];
    [revenueJsonDict setValue:self.revenueJson.skwd forKey:@"skwd"];
    
    //CustomValue setting
    [revenueJsonDict setValue:self.revenueJson.mvt1 forKey:@"mvt1"];
    [revenueJsonDict setValue:self.revenueJson.mvt2 forKey:@"mvt2"];
    [revenueJsonDict setValue:self.revenueJson.mvt3 forKey:@"mvt3"];
    [revenueJsonDict setValue:self.revenueJson.mvt4 forKey:@"mvt4"];
    [revenueJsonDict setValue:self.revenueJson.mvt5 forKey:@"mvt5"];
    [revenueJsonDict setValue:self.revenueJson.mvt6 forKey:@"mvt6"];
    [revenueJsonDict setValue:self.revenueJson.mvt7 forKey:@"mvt7"];
    [revenueJsonDict setValue:self.revenueJson.mvt8 forKey:@"mvt8"];
    [revenueJsonDict setValue:self.revenueJson.mvt9 forKey:@"mvt9"];
    [revenueJsonDict setValue:self.revenueJson.mvt10 forKey:@"mvt10"];
    
    //Product setting
    if(self.revenueJson.productList.count > 0) {
        [revenueJsonDict setValue:self.revenueJson.productList forKey:@"product"];
    }
    
    [revenueJsonDict setValue:self.revenueJson.ordNo forKey:@"ordNo"];
    
    self.revenueJson.finalRevenueJson = revenueJsonDict;
}

- (void)createEntireJson {
    self.entireJson = [[NSMutableDictionary alloc] init];
    
    if(self.DOTinitYN) {
        [self.entireJson setValue:self.sesssionJsonDict forKey:@"SESSION"];
        if(self.goalJson.finalGoalJson != nil && self.goalJson.finalGoalJson.count > 0) {
            [self.entireJson setValue:self.goalJson.finalGoalJson forKey:@"GOAL"];
        }
        if(self.revenueJson.finalRevenueJson != nil && self.revenueJson.finalRevenueJson.count > 0) {
            [self.entireJson setValue:self.revenueJson.finalRevenueJson forKey:@"REVENUE"];
        }
        if(self.clickJson.finalClickJson != nil && self.clickJson.finalClickJson.count > 0) {
            [self.entireJson setValue:self.clickJson.finalClickJson forKey:@"CLICK"];
        }
        [self sendToServer];
    }
    else {
        self.exceptionJson = [[NSMutableDictionary alloc] init];
        if(self.goalJson.finalGoalJson != nil) {
            [self.exceptionJson  setValue:self.goalJson.finalGoalJson forKey:@"GOAL"];
        }
        if(self.revenueJson.finalRevenueJson != nil) {
            [self.exceptionJson  setValue:self.revenueJson.finalRevenueJson forKey:@"REVENUE"];
        }
        if(self.clickJson.finalClickJson != nil) {
            [self.exceptionJson  setValue:self.clickJson.finalClickJson forKey:@"CLICK"];
        }
        [self.exceptionJsonList addObject:self.exceptionJson];
        
    }
}

- (void)createEntireJson2 {
    self.entireJson = [[NSMutableDictionary alloc] init];
    
    if(self.DOTinitYN) {
        [self.entireJson setValue:self.sesssionJsonDict forKey:@"SESSION"];
        [self.entireJson setValue:self.pagesJson.finalPagesJson forKey:@"PAGES"];
        
        [self sendToServer];
    }
    else {
        self.exceptionJson = [[NSMutableDictionary alloc] init];
        if(self.pagesJson.finalPagesJson  != nil) {
            [self.exceptionJson  setValue:self.pagesJson.finalPagesJson forKey:@"PAGES"];
        }
        [self.exceptionJsonList addObject:self.exceptionJson];
    }
}

- (void)sendToServer {
    NSMutableArray *finalJsonList = [[NSMutableArray alloc] init];
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Json"];
    NSString *tempJsonListString = @"";
    
    if([document stringForKey:@"QueueJsonList"] != nil && ![[document stringForKey:@"QueueJsonList"] isEqualToString:@""]) {
        tempJsonListString = [document stringForKey:@"QueueJsonList"];
        NSData *data = [tempJsonListString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableArray *bufJsonList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        finalJsonList = bufJsonList;
    }
    [finalJsonList addObject:self.entireJson];
    
    NSError *err;
    NSData *jsonListData = [NSJSONSerialization dataWithJSONObject:finalJsonList options:0 error:&err];
    NSString *fianlJsonListString = [[NSString alloc] initWithData:jsonListData encoding:NSUTF8StringEncoding];
    
    if(![DOTReachability isConnectedToNetwork]) {
        return;
    }
    [self.networkManager sendDocument:fianlJsonListString completion:^(BOOL isSuccess, NSData *data, id respons) {
        if(isSuccess) {
            NSError *error;
            NSInteger httpCode = [(NSHTTPURLResponse*) respons statusCode];
            NSString *responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSLog(@"httpCode : %ld", (long) httpCode);
            NSLog(@"responseData: %@", responseData);
            NSLog(@"response: %@", response);
            
            if([[response objectForKey:@"code"] isEqualToString:@"RES001"]) {
                NSLog(@"DOT LOG: SDK->SERVER JSON: %@", fianlJsonListString);
                CBLMutableDocument *jsonDoc = [[[LocalDB sharedInstance].database documentWithID:@"Json"] toMutable];
                if(jsonDoc == nil) {
                    jsonDoc = [[CBLMutableDocument alloc] initWithID:@"Json"];
                }
                [jsonDoc setString:@"" forKey:@"QueueJsonList"];
                [[LocalDB sharedInstance].database saveDocument:jsonDoc error:&error];
                
                CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
                double lastEventTimeSec = [DOTUtil currentTimeSec];
                [behaviorDoc setDouble:lastEventTimeSec + 1800 forKey:@"sessionExpireSec"];
                [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
                
                //clickJson, goalJosn 데이터 초기화
                self.clickJson = [[ClickJson alloc] init];
                self.goalJson = [[GoalJson alloc] init];
                
                //임시 - Json뿌려주는 화면용
                NSString *sendedJsonList = [[NSUserDefaults standardUserDefaults] stringForKey:@"sendedJsonList"];
                if(!sendedJsonList) {
                    sendedJsonList = @"";
                }
                sendedJsonList = [sendedJsonList stringByAppendingString:fianlJsonListString];
                [[NSUserDefaults standardUserDefaults] setValue:sendedJsonList forKey:@"sendedJsonList"];
            }
            else {
                [self.networkManager sendErrorLogWithError:[response objectForKey:@"msg"] completion:^(BOOL isSuccess, NSData *data, id respons) {
                    if(isSuccess) {
                        NSLog(@"DOT LOG: %@", [response objectForKey:@"msg"] );
                    }
                }];
            }
        }
        else {
            [self.networkManager sendErrorLogWithError:@"sendDocument network error" completion:^(BOOL isSuccess, NSData *data, id respons) {
                if(isSuccess) {
                    NSLog(@"DOT LOG: sendDocument network error");
                }
            }];
            NSError *error;
            CBLMutableDocument *jsonDoc = [[[LocalDB sharedInstance].database documentWithID:@"Json"] toMutable];
            if(jsonDoc == nil) {
                jsonDoc = [[CBLMutableDocument alloc] initWithID:@"Json"];
            }
            NSData *entireJsonList = [NSJSONSerialization dataWithJSONObject:finalJsonList options:0 error:&error];
            NSString *jsonListString = [[NSString alloc] initWithData:entireJsonList encoding:NSUTF8StringEncoding];
            [jsonDoc setString:jsonListString forKey:@"QueueJsonList"];
            [[LocalDB sharedInstance].database saveDocument:jsonDoc error:&error];
        }
    }];
}

- (void)startPage {
    BOOL sendTransactionYN = YES;
    
    
    if([self endPage] == 0 ) {
        sendTransactionYN = NO;
    }
    
    self.pagesJson.pv = 1;
    double now = [DOTUtil currentTimeSec];
    self.pagesJson.vtTz = now * 1000;
    
    NSError *error;
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setDouble:now forKey:@"pageStartTime"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    if(sendTransactionYN) {
        [self sendTransactionByPage];
    }
    
}

- (double)endPage {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    
    NSTimeInterval edTime = [DOTUtil currentTimeSec];
    NSNumber *tmpStTime = [document numberForKey:@"pageStartTime"];
    NSTimeInterval vs = 0;
    
    if(self.pagesJson == nil) {
        self.pagesJson = [[PagesJson alloc] init];
    }
    
    if(tmpStTime != nil) {
        vs = edTime - [tmpStTime doubleValue];
        self.pagesJson.vs = vs;
    }
    
    return vs;
}

- (BOOL)checkNewSession {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    
    NSTimeInterval currentTimeSec = [DOTUtil currentTimeSec];
    NSNumber *tmpNum = [document numberForKey:@"sessionExpireSec"];
    NSTimeInterval sessionExpireSec = 0;
    if(tmpNum != nil) {
        sessionExpireSec = [tmpNum doubleValue];
    }
    
    if(sessionExpireSec == 0 || currentTimeSec > sessionExpireSec) {
        return YES;
    }
    else {
        return NO;
    }
}
- (void)updateBeforePurchase {
    [self.sessionController updateUdRvnc];
    [self.sessionController updateLtRvnc];
    [self.sessionController updateCsRvnVsWithRevenueJson:self.revenueJson];
    [self.sessionController updateLtrvni];
    [self.sessionController updateLtrvnWithRevenuJson:self.revenueJson];
    [self.sessionController updateFirstOrd];
    
    //    if(self.pagesJson == nil) {
    //        self.pagesJson = [[PagesJson alloc] init];
    //    }
    //    self.pagesJson.pi = @"ORD";
    
    [self.sessionController updatePiTraceWithPi:@"ORD"];
}

- (void)updateAfterPurchase {
    [self.sessionController updateLastOrderNoWithOrderNo:self.revenueJson.ordNo];
    [self.sessionController resetLtRvnVt];
    
    //마지막 구매시간 저장
    NSError *error;
    double currentSec = [DOTUtil currentTimeSec];
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    if(!behaviorDoc) {
        behaviorDoc = [[CBLMutableDocument alloc] initWithID:@"Behavior"];
    }
    
    [behaviorDoc setDouble:currentSec forKey:@"lastPurchaseTimeSec"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    self.revenueJson = [[RevenueJson alloc] init];
}

- (BOOL)checkPurchase {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSString *lastOrderNo = [document stringForKey:@"lastPurchaseNo"];
    if([self.revenueJson.ordNo isEqualToString:lastOrderNo]) {
        return YES;
    }
    return NO;
}

- (void)saveUserLoginInfo {
    NSError *error;
    CBLMutableDocument *userInfoDoc = [[CBLMutableDocument alloc] initWithID:@"UserInfo"];
    
    [userInfoDoc setString:[SessionJson sharedInstance].mbr forKey:@"member"];
    [userInfoDoc setString:[SessionJson sharedInstance].sx forKey:@"gender"];
    [userInfoDoc setString:[SessionJson sharedInstance].ag forKey:@"age"];
    [userInfoDoc setString:[SessionJson sharedInstance].ut1 forKey:@"attribute1"];
    [userInfoDoc setString:[SessionJson sharedInstance].ut2 forKey:@"attribute2"];
    [userInfoDoc setString:[SessionJson sharedInstance].ut3 forKey:@"attribute3"];
    [userInfoDoc setString:[SessionJson sharedInstance].ut4 forKey:@"attribute4"];
    [userInfoDoc setString:[SessionJson sharedInstance].ut5 forKey:@"attribute5"];
    [userInfoDoc setString:[SessionJson sharedInstance].mbl forKey:@"memberGrade"];
    [userInfoDoc setString:[SessionJson sharedInstance].mbid forKey:@"memberId"];
    [userInfoDoc setString:[SessionJson sharedInstance].isLogin forKey:@"isLogin"];
    
    [[LocalDB sharedInstance].database saveDocument:userInfoDoc error:&error];
}

- (void)setGoalJosnWithConversion:(Conversion *)conversion {
    self.goalJson = [[GoalJson alloc] init];
    
    self.goalJson.scart = conversion.keywordCategory;
    self.goalJson.skwd = conversion.keyword;
    
    self.goalJson.mvt1 = conversion.customValueSet.customerValue1;
    self.goalJson.mvt2 = conversion.customValueSet.customerValue2;
    self.goalJson.mvt3 = conversion.customValueSet.customerValue3;
    self.goalJson.mvt4 = conversion.customValueSet.customerValue4;
    self.goalJson.mvt5 = conversion.customValueSet.customerValue5;
    self.goalJson.mvt6 = conversion.customValueSet.customerValue6;
    self.goalJson.mvt7 = conversion.customValueSet.customerValue7;
    self.goalJson.mvt8 = conversion.customValueSet.customerValue8;
    self.goalJson.mvt9 = conversion.customValueSet.customerValue9;
    self.goalJson.mvt10 = conversion.customValueSet.customerValue10;
    
    self.goalJson.pg1 = conversion.product.firstCategory;
    self.goalJson.pg2 = conversion.product.secondCategory;
    self.goalJson.pg3 = conversion.product.thirdCategory;
    self.goalJson.pg4 = conversion.product.detailCategory;
    self.goalJson.pnc = conversion.product.productCode;
    self.goalJson.pnAtr1 = conversion.product.attribute1;
    self.goalJson.pnAtr2 = conversion.product.attribute2;
    self.goalJson.pnAtr3 = conversion.product.attribute3;
    self.goalJson.pnAtr4 = conversion.product.attribute4;
    self.goalJson.pnAtr5 = conversion.product.attribute5;
    self.goalJson.pnAtr6 = conversion.product.attribute6;
    self.goalJson.pnAtr7 = conversion.product.attribute7;
    self.goalJson.pnAtr8 = conversion.product.attribute8;
    self.goalJson.pnAtr9 = conversion.product.attribute9;
    self.goalJson.pnAtr10 = conversion.product.attribute10;
    
    self.goalJson.g1 = conversion.g1;
    self.goalJson.g2 = conversion.g2;
    self.goalJson.g3 = conversion.g3;
    self.goalJson.g78 = conversion.pushAgreement;
}

- (void)setRevenueJsonWithPurchase:(Purchase *)purchase {
    self.revenueJson = [[RevenueJson alloc] init];
    
    self.revenueJson.vtTz = [[NSNumber numberWithLongLong:[DOTUtil currentTimeSecMulti1000]] longLongValue];
    self.revenueJson.scart = purchase.keywordCategory;
    self.revenueJson.skwd = purchase.keyword;
    
    self.revenueJson.mvt1 = purchase.customValueSet.customerValue1;
    self.revenueJson.mvt2 = purchase.customValueSet.customerValue2;
    self.revenueJson.mvt3 = purchase.customValueSet.customerValue3;
    self.revenueJson.mvt4 = purchase.customValueSet.customerValue4;
    self.revenueJson.mvt5 = purchase.customValueSet.customerValue5;
    self.revenueJson.mvt6 = purchase.customValueSet.customerValue6;
    self.revenueJson.mvt7 = purchase.customValueSet.customerValue7;
    self.revenueJson.mvt8 = purchase.customValueSet.customerValue8;
    self.revenueJson.mvt9 = purchase.customValueSet.customerValue9;
    self.revenueJson.mvt10 = purchase.customValueSet.customerValue10;
    
    self.revenueJson.productList = purchase.productDicList;
    self.revenueJson.ordNo = purchase.orderNo;
}

- (void)setClickJsonWithClick:(Click *)click {
    self.clickJson = [[ClickJson alloc] init];
    
    self.clickJson.vtTz = [[NSNumber numberWithLongLong:[DOTUtil currentTimeSecMulti1000]] longLongValue];
    self.clickJson.ckTp = click.ckTp;
    self.clickJson.ckData = click.ckData;
    
    self.clickJson.mvt1 = click.customValue.customerValue1;
    self.clickJson.mvt2 = click.customValue.customerValue2;
    self.clickJson.mvt3 = click.customValue.customerValue3;
    self.clickJson.mvt4 = click.customValue.customerValue4;
    self.clickJson.mvt5 = click.customValue.customerValue5;
    self.clickJson.mvt6 = click.customValue.customerValue6;
    self.clickJson.mvt7 = click.customValue.customerValue7;
    self.clickJson.mvt8 = click.customValue.customerValue8;
    self.clickJson.mvt9 = click.customValue.customerValue9;
    self.clickJson.mvt10 = click.customValue.customerValue10;
}

- (void)setPagesJsonWithPage:(Page *)page {
    self.pagesJson = [[PagesJson alloc] init];
    
    self.pagesJson.scart = page.keywordCategory;
    self.pagesJson.skwd = page.keyword;
    
    self.pagesJson.mvt1 = page.customValueSet.customerValue1;
    self.pagesJson.mvt2 = page.customValueSet.customerValue2;
    self.pagesJson.mvt3 = page.customValueSet.customerValue3;
    self.pagesJson.mvt4 = page.customValueSet.customerValue4;
    self.pagesJson.mvt5 = page.customValueSet.customerValue5;
    self.pagesJson.mvt6 = page.customValueSet.customerValue6;
    self.pagesJson.mvt7 = page.customValueSet.customerValue7;
    self.pagesJson.mvt8 = page.customValueSet.customerValue8;
    self.pagesJson.mvt9 = page.customValueSet.customerValue9;
    self.pagesJson.mvt10 = page.customValueSet.customerValue10;
    
    self.pagesJson.cp = page.contentPath;
    
    self.pagesJson.pi = page.pi;
    
    if(page.searchResult != nil) {
        self.pagesJson.sresult = page.searchResult;
    }
    
    self.pagesJson.pg1 = page.product.firstCategory;
    self.pagesJson.pg2 = page.product.secondCategory;
    self.pagesJson.pg3 = page.product.thirdCategory;
    self.pagesJson.pg4 = page.product.detailCategory;
    self.pagesJson.pnc = page.product.productCode;
    self.pagesJson.pnAtr1 = page.product.attribute1;
    self.pagesJson.pnAtr2 = page.product.attribute2;
    self.pagesJson.pnAtr3 = page.product.attribute3;
    self.pagesJson.pnAtr4 = page.product.attribute4;
    self.pagesJson.pnAtr5 = page.product.attribute5;
    self.pagesJson.pnAtr6 = page.product.attribute6;
    self.pagesJson.pnAtr7 = page.product.attribute7;
    self.pagesJson.pnAtr8 = page.product.attribute8;
    self.pagesJson.pnAtr9 = page.product.attribute9;
    self.pagesJson.pnAtr10 = page.product.attribute10;
}

- (void)saveInstallReferrerWithFingerPrint:(NSDictionary *)fingerPrint {
    self.fpIts = [fingerPrint objectForKey:@"wts"];
    self.fpItm = [fingerPrint objectForKey:@"wtm"];
    self.fpItc = [fingerPrint objectForKey:@"wtc"];
    self.fpItw = [fingerPrint objectForKey:@"wtw"];
    self.fpItp = [[fingerPrint objectForKey:@"wtp"] integerValue];
    self.fpItaffid = [fingerPrint objectForKey:@"wtaffid"];
    self.fpItbffid = [fingerPrint objectForKey:@"wtbffid"];
    self.fpItclkTime = [[fingerPrint objectForKey:@"wtclkTime"] longLongValue];
    self.fpInstallReferrer = [fingerPrint objectForKey:@"wtref"];
}

- (void)saveDeepLinkWithFingerPrint:(NSDictionary *)fingerPrint {
    NSError *error;
    CBLMutableDocument *deeplinkReferrerDoc = [[CBLMutableDocument alloc] initWithID:@"DeeplinkReferrerInfo"];
    
    NSString *wts = [fingerPrint objectForKey:@"wts"];
    NSString *wtm = [fingerPrint objectForKey:@"wtm"];
    NSString *wtc = [fingerPrint objectForKey:@"wtc"];
    NSString *wtw = [fingerPrint objectForKey:@"wtw"];
    NSInteger wtp = [[fingerPrint objectForKey:@"wtp"] integerValue];
    double now = [DOTUtil currentTimeSec];
    double DRExpireTime = now + wtp * 86400;
    NSString *wtaffid = [fingerPrint objectForKey:@"wtaffid"];
    NSString *wtbffid = [fingerPrint objectForKey:@"wtbffid"];
    NSNumber *wtclkTime = [fingerPrint objectForKey:@"wtclkTime"];
    NSString *wtref = [fingerPrint objectForKey:@"wtref"];
    
    [deeplinkReferrerDoc setString:wts forKey:@"wts"];
    [deeplinkReferrerDoc setString:wtm forKey:@"wtm"];
    [deeplinkReferrerDoc setString:wtc forKey:@"wtc"];
    [deeplinkReferrerDoc setString:wtw forKey:@"wtw"];
    [deeplinkReferrerDoc setInteger:wtp forKey:@"wtp"];
    [deeplinkReferrerDoc setString:wtaffid forKey:@"wtaffid"];
    [deeplinkReferrerDoc setString:wtbffid forKey:@"wtbffid"];
    [deeplinkReferrerDoc setNumber:wtclkTime forKey:@"wtclkTime"];
    [deeplinkReferrerDoc setString:wtref forKey:@"wtref"];
    [deeplinkReferrerDoc setNumber:@(DRExpireTime) forKey:@"DRExpireTime"];
    
    [[LocalDB sharedInstance].database saveDocument:deeplinkReferrerDoc error:&error];
}

- (void)parseDeepLink:(NSString *)deepLink {
    
    NSMutableDictionary *deepLinkDictionary = [[NSMutableDictionary alloc] init];
    deepLinkDictionary = [DOTUtil parseUrlString:deepLink];
    
    NSError *error;
    CBLMutableDocument *deeplinkReferrerDoc = [[[LocalDB sharedInstance].database documentWithID:@"DeeplinkReferrerInfo"] toMutable];
    if(deeplinkReferrerDoc == nil) {
        deeplinkReferrerDoc = [[CBLMutableDocument alloc] initWithID:@"DeeplinkReferrerInfo"];
    }
    
    NSString *wts = [deepLinkDictionary objectForKey:@"_wts"];
    NSString *wtm = [deepLinkDictionary objectForKey:@"_wtm"];
    NSString *wtc = [deepLinkDictionary objectForKey:@"_wtc"];
    NSString *wtw = [deepLinkDictionary objectForKey:@"_wtw"];
    NSInteger wtp = [[deepLinkDictionary objectForKey:@"_wtp"] integerValue];
    NSString *wtaffid = [deepLinkDictionary objectForKey:@"_wtaffid"];
    NSString *wtbffid = [deepLinkDictionary objectForKey:@"_wtbffid"];
    NSString *wtclkTime = [deepLinkDictionary objectForKey:@"_wtclkTime"];
    NSString *wtref = deepLink;
    
    [deeplinkReferrerDoc setString:wts forKey:@"wts"];
    [deeplinkReferrerDoc setString:wtm forKey:@"wtm"];
    [deeplinkReferrerDoc setString:wtc forKey:@"wtc"];
    [deeplinkReferrerDoc setString:wtw forKey:@"wtw"];
    [deeplinkReferrerDoc setInteger:wtp forKey:@"wtp"];
    [deeplinkReferrerDoc setString:wtaffid forKey:@"wtaffid"];
    [deeplinkReferrerDoc setString:wtbffid forKey:@"wtbffid"];
    [deeplinkReferrerDoc setString:wtclkTime forKey:@"wtclkTime"];
    [deeplinkReferrerDoc setString:wtref forKey:@"wtref"];
    
    [[LocalDB sharedInstance].database saveDocument:deeplinkReferrerDoc error:&error];
    
    if([wts isEqualToString:@""] || [wtc isEqualToString:@""]) {
        NSInteger wtno = [[self.dotAuthorizationKey objectAtIndex:1] integerValue];
        [self.networkManager requestFingerPrintWithWtno:wtno completion:^(BOOL isSuccess, NSData *data, id respons) {
            if(isSuccess){
                NSError* error;
                NSInteger httpCode = [(NSHTTPURLResponse*) respons statusCode];
                NSString *responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSLog(@"httpCode : %ld", (long) httpCode);
                NSLog(@"responseData: %@", responseData);
                NSLog(@"DOT LOG: request finger print response: %@", response);
                if(response.count > 0) {
                    [self saveDeepLinkWithFingerPrint:response];
                }
            }
            else {
                NSLog(@"first FingerPrint Reqeust fail");
            }
        }];
    }
}

- (void)parseReferrer:(NSString *)referrer {
    
    NSMutableDictionary *referrerDictionary = [[NSMutableDictionary alloc] init];
    referrerDictionary = [DOTUtil parseUrlString:referrer];
    
    self.irIts = [referrerDictionary objectForKey:@"wts"];
    self.irItm = [referrerDictionary objectForKey:@"wtm"];
    self.irItc = [referrerDictionary objectForKey:@"wtc"];
    self.irItw = [referrerDictionary objectForKey:@"wtw"];
    self.irItp = [[referrerDictionary objectForKey:@"wtp"] integerValue];
    self.irItaffid = [referrerDictionary objectForKey:@"wtaffid"];
    self.irItbffid = [referrerDictionary objectForKey:@"wtbffid"];
    self.irItclkTime = [[referrerDictionary objectForKey:@"wtclkTime"] longLongValue];
    self.irInstallReferrer = referrer;
    
}

- (void)enterForeground {
    NSError *error;
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setDouble:[DOTUtil currentTimeSec] forKey:@"pageStartTime"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)enterBackground {
    [self startPage];
}

- (BOOL)getDOTInitFlag {
    return self.DOTinitYN;
}
@end


