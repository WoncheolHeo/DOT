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

@interface Tracker ()
@property (nonatomic) SessionJson *sessionJson;

@property (nonatomic) NSMutableDictionary *entireJson;
@property (nonatomic) NSMutableDictionary *sesssionJsonDict;

@property (nonatomic) SessionController *sessionController;
@property (nonatomic) NetworkManager *networkManager;
@property (nonatomic) BOOL newSessionYN;
@property (nonatomic) NSTimer *oneSecondTimer;
@property (nonatomic) NSMutableArray *dotAuthorizationKey;
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
    //accessToken encoding
//    NSString *seedKey = @"dotAmWisetracker";
//    NSString *accessToken = @"le9lSjsG3QSzN5zDNvf1YG9aKS6n/4NTH12M6qvdqMbrlaShwMUYCLZhQ34uHkzRS136F8J3g5i/aP1Cxl55FU87lQYHAoF3QzKCUISZsltZbnif23th30izMZkcStZr";
//    NSString *encryptAccessToken = [accessToken AES256DecryptWithKey:seedKey];
//
//    NSLog(@"encryptAccessToken: %@", encryptAccessToken);
    
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
                NSLog(@"httpCode : %ld", (long)httpCode);
                NSLog(@"responseData: %@", responseData);
                NSLog(@"response: %@", response);
                NSString *receivedToken = [response objectForKey:@"token"];
                CBLMutableDocument *authDoc = [[CBLMutableDocument alloc] initWithID:@"authDoc"];
                [authDoc setString:receivedToken forKey:@"authToken"];
                //[SessionJson sharedInstance]._accessToken = receivedToken;
                [[LocalDB sharedInstance].database saveDocument:authDoc error:&error];
                authSuccess = YES;
            }
            else {
                authSuccess = NO;
            }
        }];
    }
    else {
        authSuccess = YES;
    }
    return authSuccess;
}

- (void)initEnd {
    [[NHNetworkClock sharedNetworkClock] synchronize];
    NSString *authToken = [self.dotAuthorizationKey objectAtIndex:6];
    
    if([authToken isEqualToString:@""] || authToken == nil) {
        CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"authDoc"];
        authToken = [document stringForKey:@"authToken"];
    }
    
    if([DOTReachability isConnectedToNetwork]) {
        if(![self authorizationCheckWithAuthToken:authToken]) {
            return;
        }
    }
    //최초실행시 installTime setting
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Install"];
    NSNumber *installTime = [document numberForKey:@"installTime"];
   
    if(installTime == nil) {
        //디바이스 타입 조정해가며 테스트하기 위해 
        NSNumber *installTime = @([DOTUtil currentTimeSec]* 1000);
        NSError *error;
        CBLMutableDocument *installDoc = [[[LocalDB sharedInstance].database documentWithID:@"Install"] toMutable];
        if(installDoc == nil) {
            installDoc = [[CBLMutableDocument alloc] initWithID:@"Install"];
        }
        [installDoc setNumber:installTime forKey:@"installTime"];
        [[LocalDB sharedInstance].database saveDocument:installDoc error:&error];
//        [SessionJson sharedInstance].installTime = [installTime longLongValue];
//        if([DOTReachability isConnectedToNetwork]) {
//            //finger print호출
//            [self createUpdateTimer];
//
//        }
//        else {
//            NSNumber *installTime = @([DOTUtil currentTimeSec]* 1000);
//            NSError *error;
//            CBLMutableDocument *installDoc = [[[LocalDB sharedInstance].database documentWithID:@"Install"] toMutable];
//            if(installDoc == nil) {
//                installDoc = [[CBLMutableDocument alloc] initWithID:@"Install"];
//            }
//            [installDoc setNumber:installTime forKey:@"installTime"];
//            [[LocalDB sharedInstance].database saveDocument:installDoc error:&error];
//            [SessionJson sharedInstance].installTime = [installTime longLongValue];
//        }
    }
    [self.sessionController saveAppInfo:self.dotAuthorizationKey];
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
        
        NSNumber *installTime = @([networkTime timeIntervalSince1970] * 1000);
        NSError *error;
        CBLMutableDocument *installDoc = [[[LocalDB sharedInstance].database documentWithID:@"Install"] toMutable];
        if(installDoc == nil) {
            installDoc = [[CBLMutableDocument alloc] initWithID:@"Install"];
        }
        [installDoc setNumber:installTime forKey:@"installTime"];
        [[LocalDB sharedInstance].database saveDocument:installDoc error:&error];
        
        [SessionJson sharedInstance].installTime = [installTime longLongValue];
        [SessionJson sharedInstance].timeOffset = @(nt - dt);
    }
    else {
        NSLog(@"not yet time sync");
    }
}

- (void)occurNewSession {

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
  
}

- (BOOL)sendTransaction {
    //현재시간이 마지막 서버전송시간보다 크면 newSession 발생
    if( [self checkNewSession]) {
        [SessionJson clearInstance];
        [self occurNewSession];
        [self makeJson];
        [self.sessionController resetAboutNewVistInfo];
        return YES;
    }
    [self makeJson];
    return YES;
}

- (BOOL)sendTransactionByPage {
    //현재시간이 마지막 서버전송시간보다 크면 newSession 발생
//    if( [self checkNewSession]) {
//        [SessionJson clearInstance];
//        [self occurNewSession:2];
//        return YES;
//    }
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
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson.wtclkTime] forKey:@"wtclkTime"];
    [self.sesssionJsonDict setValue:sessionJson.wtref forKey:@"wtref"];

    //install referrer
    [self.sesssionJsonDict setValue:sessionJson.its forKey:@"its"];
    [self.sesssionJsonDict setValue:sessionJson.itm forKey:@"itm"];
    [self.sesssionJsonDict setValue:sessionJson.itc forKey:@"itc"];
    [self.sesssionJsonDict setValue:sessionJson.itw forKey:@"itw"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithLongLong:sessionJson.installTime] forKey:@"installTime"];
    [self.sesssionJsonDict setValue:sessionJson.installReferrer forKey:@"installReferrer"];
    [self.sesssionJsonDict setValue:sessionJson.pushNo forKey:@"pushNo"];
    
    //From info.plist
    [self.sesssionJsonDict setValue:sessionJson._wthst forKey:@"_wthst"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson._wtno] forKey:@"_wtno"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithInteger:sessionJson._wtUdays] forKey:@"_wtUdays"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithBool:sessionJson._wtDebug] forKey:@"_wtDebug"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithBool:sessionJson._wtUseRetention] forKey:@"_wtUseRetention"];
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithBool:sessionJson._wtUseFingerPrint] forKey:@"_wtUseFingerPrint"];
    [self.sesssionJsonDict setValue:sessionJson._accessToken forKey:@"_acessToken"];
    //컨텐츠분석
    [self.sesssionJsonDict setValue:[[NSNumber alloc] initWithLongLong:sessionJson.vtTz] forKey:@"vtTz"];
}

- (void)createGoalJson {
    NSMutableDictionary *goalJsonDict = [[NSMutableDictionary alloc] init];
    
    GoalJson *goalJson = [GoalJson sharedInstance];
    //productDic 값세팅
    [goalJsonDict setValue:goalJson.scart forKey:@"scart"];
    [goalJsonDict setValue:goalJson.skwd forKey:@"skwd"];
    
    //CustomValue setting
    [goalJsonDict setValue:goalJson.mvt1 forKey:@"mvt1"];
    [goalJsonDict setValue:goalJson.mvt2 forKey:@"mvt2"];
    [goalJsonDict setValue:goalJson.mvt3 forKey:@"mvt3"];
    [goalJsonDict setValue:goalJson.mvt4 forKey:@"mvt4"];
    [goalJsonDict setValue:goalJson.mvt5 forKey:@"mvt5"];
    [goalJsonDict setValue:goalJson.mvt6 forKey:@"mvt6"];
    [goalJsonDict setValue:goalJson.mvt7 forKey:@"mvt7"];
    [goalJsonDict setValue:goalJson.mvt8 forKey:@"mvt8"];
    [goalJsonDict setValue:goalJson.mvt9 forKey:@"mvt9"];
    [goalJsonDict setValue:goalJson.mvt10 forKey:@"mvt10"];
    
    //Product setting
    [goalJsonDict setValue:goalJson.pg1 forKey:@"pg1"];
    [goalJsonDict setValue:goalJson.pg2 forKey:@"pg2"];
    [goalJsonDict setValue:goalJson.pg3 forKey:@"pg3"];
    [goalJsonDict setValue:goalJson.pg4 forKey:@"pg4"];
    [goalJsonDict setValue:goalJson.pnc forKey:@"pnc"];
    [goalJsonDict setValue:goalJson.pnAtr1 forKey:@"pnAtr1"];
    [goalJsonDict setValue:goalJson.pnAtr2 forKey:@"pnAtr2"];
    [goalJsonDict setValue:goalJson.pnAtr3 forKey:@"pnAtr3"];
    [goalJsonDict setValue:goalJson.pnAtr4 forKey:@"pnAtr4"];
    [goalJsonDict setValue:goalJson.pnAtr5 forKey:@"pnAtr5"];
    [goalJsonDict setValue:goalJson.pnAtr6 forKey:@"pnAtr6"];
    [goalJsonDict setValue:goalJson.pnAtr7 forKey:@"pnAtr7"];
    [goalJsonDict setValue:goalJson.pnAtr8 forKey:@"pnAtr8"];
    [goalJsonDict setValue:goalJson.pnAtr9 forKey:@"pnAtr9"];
    [goalJsonDict setValue:goalJson.pnAtr10 forKey:@"pnAtr10"];
    
    if(goalJson.g1) {
        [goalJsonDict setValue:[[NSNumber alloc] initWithDouble:goalJson.g1] forKey:@"g1"];
    }
    if(goalJson.g2) {
        [goalJsonDict setValue:[[NSNumber alloc] initWithDouble:goalJson.g2] forKey:@"g2"];
    }
    if(goalJson.g78) {
        [goalJsonDict setValue:[[NSNumber alloc] initWithBool:goalJson.g78] forKey:@"g78"];
    }
    
    goalJson.finalGoalJson = goalJsonDict;
}

- (void)createPagesJson {
    NSMutableDictionary *pagesJsonDict = [[NSMutableDictionary alloc] init];
    //pageDict 값세팅
    PagesJson *pagesJson = [PagesJson sharedInstance];
    [pagesJsonDict setValue:pagesJson.scart forKey:@"scart"];
    [pagesJsonDict setValue:pagesJson.skwd forKey:@"skwd"];
    [pagesJsonDict setValue:pagesJson.cp forKey:@"cp"];
    [pagesJsonDict setValue:pagesJson.pi forKey:@"pi"];
    if(pagesJson.vs) {
        [pagesJsonDict setValue:[[NSNumber alloc] initWithDouble:pagesJson.vs] forKey:@"vs"];
    }
    
    if(pagesJson.sresult != nil) {
        [pagesJsonDict setValue:pagesJson.sresult forKey:@"sresult"];
    }
    
    if(pagesJson.pv) {
        [pagesJsonDict setValue:[[NSNumber alloc] initWithInteger:pagesJson.pv] forKey:@"pv"];
    }
    
    //CustomValue setting
    [pagesJsonDict setValue:pagesJson.mvt1 forKey:@"mvt1"];
    [pagesJsonDict setValue:pagesJson.mvt2 forKey:@"mvt2"];
    [pagesJsonDict setValue:pagesJson.mvt3 forKey:@"mvt3"];
    [pagesJsonDict setValue:pagesJson.mvt4 forKey:@"mvt4"];
    [pagesJsonDict setValue:pagesJson.mvt5 forKey:@"mvt5"];
    [pagesJsonDict setValue:pagesJson.mvt6 forKey:@"mvt6"];
    [pagesJsonDict setValue:pagesJson.mvt7 forKey:@"mvt7"];
    [pagesJsonDict setValue:pagesJson.mvt8 forKey:@"mvt8"];
    [pagesJsonDict setValue:pagesJson.mvt9 forKey:@"mvt9"];
    [pagesJsonDict setValue:pagesJson.mvt10 forKey:@"mvt10"];
    
    //Product setting
    [pagesJsonDict setValue:pagesJson.pg1 forKey:@"pg1"];
    [pagesJsonDict setValue:pagesJson.pg2 forKey:@"pg2"];
    [pagesJsonDict setValue:pagesJson.pg3 forKey:@"pg3"];
    [pagesJsonDict setValue:pagesJson.pg4 forKey:@"pg4"];
    [pagesJsonDict setValue:pagesJson.pnc forKey:@"pnc"];
    [pagesJsonDict setValue:pagesJson.pnAtr1 forKey:@"pnAtr1"];
    [pagesJsonDict setValue:pagesJson.pnAtr2 forKey:@"pnAtr2"];
    [pagesJsonDict setValue:pagesJson.pnAtr3 forKey:@"pnAtr3"];
    [pagesJsonDict setValue:pagesJson.pnAtr4 forKey:@"pnAtr4"];
    [pagesJsonDict setValue:pagesJson.pnAtr5 forKey:@"pnAtr5"];
    [pagesJsonDict setValue:pagesJson.pnAtr6 forKey:@"pnAtr6"];
    [pagesJsonDict setValue:pagesJson.pnAtr7 forKey:@"pnAtr7"];
    [pagesJsonDict setValue:pagesJson.pnAtr8 forKey:@"pnAtr8"];
    [pagesJsonDict setValue:pagesJson.pnAtr9 forKey:@"pnAtr9"];
    [pagesJsonDict setValue:pagesJson.pnAtr10 forKey:@"pnAtr10"];
    
    if(pagesJson.vtTz) {
         [pagesJsonDict setValue:[[NSNumber alloc] initWithLongLong:pagesJson.vtTz] forKey:@"vtTz"];
    }
    
   

    pagesJson.finalPagesJson = pagesJsonDict;
    
}

- (void)createClickJson {
    //clickEventDict 값세팅
    NSMutableDictionary *clickJsontDict = [[NSMutableDictionary alloc] init];
    ClickJson *clickJson = [ClickJson sharedInstance];
    [clickJsontDict setValue:clickJson.ckTp forKey:@"ckTp"];
    [clickJsontDict setValue:clickJson.ckData forKey:@"ckData"];
    
    if(clickJson.vtTz) {
        [clickJsontDict setValue:[[NSNumber alloc] initWithLongLong:clickJson.vtTz] forKey:@"vtTz"];
    }
    
    //CustomValue setting
    [clickJsontDict setValue:clickJson.mvt1 forKey:@"mvt1"];
    [clickJsontDict setValue:clickJson.mvt2 forKey:@"mvt2"];
    [clickJsontDict setValue:clickJson.mvt3 forKey:@"mvt3"];
    [clickJsontDict setValue:clickJson.mvt4 forKey:@"mvt4"];
    [clickJsontDict setValue:clickJson.mvt5 forKey:@"mvt5"];
    [clickJsontDict setValue:clickJson.mvt6 forKey:@"mvt6"];
    [clickJsontDict setValue:clickJson.mvt7 forKey:@"mvt7"];
    [clickJsontDict setValue:clickJson.mvt8 forKey:@"mvt8"];
    [clickJsontDict setValue:clickJson.mvt9 forKey:@"mvt9"];
    [clickJsontDict setValue:clickJson.mvt10 forKey:@"mvt10"];
    
    clickJson.finalClickJson = clickJsontDict;
}

- (void)createRevenueJson {
    NSMutableDictionary *revenueJsonDict = [[NSMutableDictionary alloc] init];
    
    RevenueJson *revenueJson = [RevenueJson sharedInstance];
    //revenueJsonDict 값세팅
    if(revenueJson.vtTz) {
        [revenueJsonDict setValue:[[NSNumber alloc] initWithLongLong:revenueJson.vtTz] forKey:@"vtTz"];
    }
    
    [revenueJsonDict setValue:revenueJson.scart forKey:@"scart"];
    [revenueJsonDict setValue:revenueJson.skwd forKey:@"skwd"];
    
    //CustomValue setting
    [revenueJsonDict setValue:revenueJson.mvt1 forKey:@"mvt1"];
    [revenueJsonDict setValue:revenueJson.mvt2 forKey:@"mvt2"];
    [revenueJsonDict setValue:revenueJson.mvt3 forKey:@"mvt3"];
    [revenueJsonDict setValue:revenueJson.mvt4 forKey:@"mvt4"];
    [revenueJsonDict setValue:revenueJson.mvt5 forKey:@"mvt5"];
    [revenueJsonDict setValue:revenueJson.mvt6 forKey:@"mvt6"];
    [revenueJsonDict setValue:revenueJson.mvt7 forKey:@"mvt7"];
    [revenueJsonDict setValue:revenueJson.mvt8 forKey:@"mvt8"];
    [revenueJsonDict setValue:revenueJson.mvt9 forKey:@"mvt9"];
    [revenueJsonDict setValue:revenueJson.mvt10 forKey:@"mvt10"];
    
    //Product setting
    if(revenueJson.productList.count > 0) {
        [revenueJsonDict setValue:revenueJson.productList forKey:@"product"];
    }
    
    [revenueJsonDict setValue:revenueJson.ordNo forKey:@"ordNo"];
    
    revenueJson.finalRevenueJson = revenueJsonDict;
}

- (void)createEntireJson {
    self.entireJson = [[NSMutableDictionary alloc] init];
    
    [self.entireJson setValue:self.sesssionJsonDict forKey:@"SESSION"];
    [self.entireJson setValue:[GoalJson sharedInstance].finalGoalJson forKey:@"GOAL"];
    [self.entireJson setValue:[RevenueJson sharedInstance].finalRevenueJson forKey:@"REVENUE"];
    [self.entireJson setValue:[ClickJson sharedInstance].finalClickJson forKey:@"CLICK"];
    
    [self sendToServer:1];
}

- (void)createEntireJson2 {
    self.entireJson = [[NSMutableDictionary alloc] init];
    
    [self.entireJson setValue:self.sesssionJsonDict forKey:@"SESSION"];
    [self.entireJson setValue:[PagesJson sharedInstance].finalPagesJson forKey:@"PAGES"];
    
    [self sendToServer:2];
}

- (void)sendToServer:(NSInteger)type {
    NSMutableArray *finalJsonList = [[NSMutableArray alloc] init];
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Json"];
    NSString *tempJsoListString = @"";
    
    if([document stringForKey:@"QueueJsonList"] != nil && ![[document stringForKey:@"QueueJsonList"] isEqualToString:@""]) {
        tempJsoListString = [document stringForKey:@"QueueJsonList"];
        NSData *data = [tempJsoListString dataUsingEncoding:NSUTF8StringEncoding];
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
    [self.networkManager sendDocumentWithType:type fianlJsonListString:fianlJsonListString completion:^(BOOL isSuccess, NSData *data, id respons) {
        if(isSuccess) {
            NSLog(@"DOT LOG: SDK->SERVER JSON: %@", fianlJsonListString);
//            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//            NSLog(@"response: %@", response);
            NSError *error;
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
            
            //임시 - Json뿌려주는 화면용
            NSString *sendedJsonList = [[NSUserDefaults standardUserDefaults] stringForKey:@"sendedJsonList"];
            if(!sendedJsonList) {
                sendedJsonList = @"";
            }
            sendedJsonList = [sendedJsonList stringByAppendingString:fianlJsonListString];
            [[NSUserDefaults standardUserDefaults] setValue:sendedJsonList forKey:@"sendedJsonList"];
        }
        else {
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
    
    //goal, click jsonData 초기화
    if(type == 1) {
        [GoalJson clearInstance];
        [ClickJson clearInstance];
    }
    else if(type == 2) {
        [PagesJson clearInstance];
    }
}

- (void)startPage {
    BOOL sendTransactionYN = YES;
    BOOL isNewSession = NO;
    if([self checkNewSession]) {
        [SessionJson clearInstance];
        [self occurNewSession];
        [self sendTransactionByPage];
        [self.sessionController resetAboutNewVistInfo];
        isNewSession = YES;
    }
    
    
    if([self endPage] == 0 ) {
        sendTransactionYN = NO;
    }
    NSError *error;
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setDouble:[DOTUtil currentTimeSec] forKey:@"pageStartTime"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    [PagesJson sharedInstance].pv = 1;
    [PagesJson sharedInstance].vtTz = [DOTUtil currentTimeSec] * 1000;
    

    if(sendTransactionYN && !isNewSession) {
        [self sendTransactionByPage];
    }
}

- (double)endPage {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    
    NSTimeInterval edTime = [DOTUtil currentTimeSec];
    NSNumber *tmpStTime = [document numberForKey:@"pageStartTime"];
    NSTimeInterval vs = 0;
    
    if(tmpStTime != nil) {
        vs = edTime - [tmpStTime doubleValue];
        [PagesJson sharedInstance].vs = vs;
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
    [self.sessionController updateCsRvnVs];
    [self.sessionController updateLtrvni];
    [self.sessionController updateLtrvn];
    [self.sessionController updateFirstOrd];
    [PagesJson sharedInstance].pID = @"ORD";
    [self.sessionController updatePiTrace];

}

- (void)updateAfterPurchase {
    [self.sessionController updateLastOrderNo];
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
    
    [RevenueJson clearInstance];
}

- (BOOL)checkPurchase {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSString *lastOrderNo = [document stringForKey:@"lastPurchaseNo"];
        if([[RevenueJson sharedInstance].ordNo isEqualToString:lastOrderNo]) {
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
@end
