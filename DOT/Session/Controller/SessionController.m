//
//  SessionController.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 9..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "SessionController.h"
#import "DOTUtil.h"

@implementation SessionController

- (instancetype)init {
    return [super init];
}

- (void)updateUdVt {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSNumber *tmpNum = [document numberForKey:@"userCriteriaVisit"];
    NSInteger udVt = 0;
    if(tmpNum != nil) {
        udVt = [tmpNum integerValue];
    }
    
    //udRvnc Update 로직
    CBLDocument *document2 = [[LocalDB sharedInstance].database documentWithID:@"AppInfo"];
    NSInteger expireDate  = [document2 integerForKey:@"expireDate"];
    
    NSTimeInterval currentTimeSec = [DOTUtil currentTimeSec];
    NSInteger interval = 0;
    NSTimeInterval lastSessionTimeSec = 0;
    NSNumber *tmpNum2 = [document numberForKey:@"recentSessionTimeSec"];
    if(tmpNum2 != nil) {
        lastSessionTimeSec = [tmpNum2 doubleValue];
        interval = [[[NSNumber alloc] initWithInteger:round((currentTimeSec - lastSessionTimeSec)/60/60/24)] integerValue];
    }
    if(interval >= expireDate) {
        udVt = 1;
    }
    else {
        udVt = udVt + 1;
    }

    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:udVt forKey:@"userCriteriaVisit"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    [SessionJson sharedInstance].udVt = udVt;
    
}

- (void)updateLtvt {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSNumber *tmpNum = [document numberForKey:@"lifeCriteriaVisit"];
    NSInteger ltvt = 0;
    if(tmpNum != nil) {
        ltvt = [tmpNum integerValue];
    }
    //뉴세션 발생시점마다 1씩 증가
    ltvt = ltvt + 1;
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:ltvt forKey:@"lifeCriteriaVisit"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    [SessionJson sharedInstance].ltvt = ltvt;
}

- (void)updateLtVi {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger ltVi = [document integerForKey:@"lifeVisitInterval"];
    
    if(!ltVi) {
        ltVi =  0;
    }
    
    NSTimeInterval currentTimeSec = [DOTUtil currentTimeSec];
    NSTimeInterval lastSessionTimeSec = [document doubleForKey:@"recentSessionTimeSec"];
    
    if(!lastSessionTimeSec) {
        ltVi = 0;
    }
    else {
        ltVi += round((currentTimeSec-lastSessionTimeSec)/60/60/24);
    }
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:ltVi forKey:@"lifeVisitInterval"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    [SessionJson sharedInstance].ltVi = ltVi;
}

- (void)updateIsDf {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    BOOL newVisitToday = NO;
   
    
    NSNumber *tmpSec = [document numberForKey:@"recentSessionTimeSec"];
    NSTimeInterval recentSessionTimeSec = 0;
    if(tmpSec != nil) {
        recentSessionTimeSec = [tmpSec integerValue];
    }
    NSDate *today = [[NSDate alloc] init];
    if(recentSessionTimeSec <= 0) {
        newVisitToday = YES;
    }
    else {
        if([today timeIntervalSince1970] > [document doubleForKey:@"expireTimeForDaily"]) {
            newVisitToday = YES;
        }
    }
    
    NSTimeInterval expireTimeForDaily = [DOTUtil getExpireLongTime:recentSessionTimeSec type:@"DU"];
    NSString *isDf = newVisitToday?  @"Y" : @"N";
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setDouble:expireTimeForDaily forKey:@"expireTimeForDaily"];
    [behaviorDoc setString:isDf forKey:@"dailyUnique"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)updateIsWf {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    BOOL newVisitThisWeek = NO;
    
    NSNumber *tmpSec = [document numberForKey:@"recentSessionTimeSec"];
    NSTimeInterval recentSessionTimeSec = 0;
    if( tmpSec != nil) {
        recentSessionTimeSec = [tmpSec doubleValue];
    }
    NSDate *today = [[NSDate alloc] init];
    
    if(recentSessionTimeSec <= 0) {
        newVisitThisWeek = YES;
    }
    else {
        if([today timeIntervalSince1970] > [document doubleForKey:@"expireTimeForWeekly"]) {
            newVisitThisWeek = YES;
        }
    }
    
    
    NSTimeInterval expireTimeForWeekly = [DOTUtil getExpireLongTime:recentSessionTimeSec type:@"WU"];
    NSString *isWf = newVisitThisWeek?  @"Y" : @"N";
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setDouble:expireTimeForWeekly forKey:@"expireTimeForWeekly"];
    [behaviorDoc setString:isWf forKey:@"weelkyUnique"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)updateIsMf{
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    BOOL newVisitThisMonth = NO;
    
    NSNumber *tmpSec = [document numberForKey:@"recentSessionTimeSec"];
    NSTimeInterval recentSessionTimeSec = 0;
    if( tmpSec != nil) {
        recentSessionTimeSec = [tmpSec doubleValue];
    }
    NSDate *today = [[NSDate alloc] init];
    
    if(recentSessionTimeSec <= 0) {
        newVisitThisMonth = YES;
    }
    else {
        if([today timeIntervalSince1970] > [document doubleForKey:@"expireTimeForMonthly"]) {
            newVisitThisMonth = YES;
        }
    }
    
    NSTimeInterval expireTimeForMonthly = [DOTUtil getExpireLongTime:recentSessionTimeSec type:@"MU"];
    NSString *isMf = newVisitThisMonth?  @"Y" : @"N";
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setDouble:expireTimeForMonthly forKey:@"expireTimeForMonthly"];
    [behaviorDoc setString:isMf forKey:@"monthlyUnique"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)updateIsWfUs {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    BOOL isWeeklyNewUS = NO;
    
    NSNumber *tmpSec = [document numberForKey:@"recentSessionTimeSec"];
    NSTimeInterval recentSessionTimeSec = 0;
    if( tmpSec != nil) {
        recentSessionTimeSec = [tmpSec doubleValue];
    }
    NSDate *today = [[NSDate alloc] init];
    
    if(recentSessionTimeSec <= 0) {
        isWeeklyNewUS = YES;
    }else {
        if([today timeIntervalSince1970] > [document doubleForKey:@"expireTimeForWeeklyUS"]) {
            isWeeklyNewUS = YES;
        }
    }

    NSTimeInterval expireTimeForWeeklyUS = [DOTUtil getExpireLongTimeForWeeklyUSType:recentSessionTimeSec];
    NSString *isWfUs = isWeeklyNewUS?  @"Y" : @"N";
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setDouble:expireTimeForWeeklyUS forKey:@"expireTimeForWeeklyUS"];
    [behaviorDoc setString:isWfUs forKey:@"weeklyUnique2"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
}

- (void)updateUdRvnc {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSNumber *tmpNum = [document numberForKey:@"userCriteriaPurchase"];
    NSInteger udRvnc = 0;
    if(tmpNum != nil) {
        udRvnc = [tmpNum integerValue];
    }
    udRvnc = udRvnc + 1;
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:udRvnc forKey:@"userCriteriaPurchase"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    [SessionJson sharedInstance].udRvnc = udRvnc;
}

- (void)checkToResetUdRvnc {
    //udRvnc 초기화 로직
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSNumber *tmpNum = [document numberForKey:@"userCriteriaPurchase"];
    NSInteger udRvnc = 0;
    if(tmpNum != nil) {
        udRvnc = [tmpNum integerValue];
    }
    
    NSNumber *tmpNum2 = [document numberForKey:@"lastPurchaseTimeSec"];
    if(tmpNum2 != nil) {
        NSTimeInterval lastPurchaseTimeSec = [tmpNum2 doubleValue];
        NSTimeInterval currentTimeSec = [DOTUtil currentTimeSec];
        NSInteger expireDate = [SessionJson sharedInstance]._wtUdays;
        NSInteger interval = 0;
        //현재시간과 마지막 구매시간의 간격이 exipireDay(14일)보다 크면 udRvnc값을 0으로 세팅.
        interval = round((currentTimeSec - lastPurchaseTimeSec)/60/60/24);
        if(interval >= expireDate) {
            udRvnc = 0;
        }
    }
    
    NSError *error;
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:udRvnc forKey:@"userCriteriaPurchase"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    [SessionJson sharedInstance].udRvnc = udRvnc;
}

- (void)updateLtRvnc {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
   // NSInteger ltRvnc = [document integerForKey:@"lifeCriteriaPurchase"];
    NSNumber *tmpNum = [document numberForKey:@"lifeCriteriaPurchase"];
    NSInteger ltRvnc = 0;
    if(tmpNum != nil) {
        ltRvnc = [tmpNum integerValue];
    }
    
    //구매 발생시점마다 1씩 증가
    ltRvnc = ltRvnc + 1;
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:ltRvnc forKey:@"lifeCriteriaPurchase"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    [SessionJson sharedInstance].ltRvnc = ltRvnc;
}

- (void)updateCsRvnVsWithRevenueJson:(RevenueJson *)revenueJson {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSTimeInterval recentSessionTimeSec = [document doubleForKey:@"recentSessionTimeSec"];
    NSTimeInterval interval = revenueJson.vtTz / 1000 - recentSessionTimeSec;
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:(NSInteger) interval forKey:@"spendingTimeToPurchase"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    [SessionJson sharedInstance].csRvnVs = (NSInteger) interval;
}

- (void)updateLtrvni {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger ltrvni = [document integerForKey:@"lifePurchaseInterval"];
    
    if(!ltrvni) {
        ltrvni =  0;
    }
    
    NSTimeInterval currentTimeSec = [DOTUtil currentTimeSec];
    NSTimeInterval lastPurchaseTimeSec = [document doubleForKey:@"lastPurchaseTimeSec"];
    
    if(!lastPurchaseTimeSec) {
        ltrvni = 0;
    }
    else {
        ltrvni += [[[NSNumber alloc] initWithDouble:round((currentTimeSec-lastPurchaseTimeSec)/60/60/24)] integerValue];
    }
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:ltrvni forKey:@"lifePurchaseInterval"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];

    [SessionJson sharedInstance].ltrvni = ltrvni;
    
}

- (void)updateLtrvnWithRevenuJson:(RevenueJson *)revenueJson {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger ltrvn = [document integerForKey:@"lifePurchaseAmount"];
 
    if(!ltrvn) {
        ltrvn =  0;
    }

    //구매 발생시점마다 총구매금액만큼 증가
    for(NSInteger i = 0; i < revenueJson.productList.count; i++) {
        ltrvn = ltrvn + [[[revenueJson.productList objectAtIndex:i] objectForKey:@"amt"] integerValue];
    }
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:ltrvn forKey:@"lifePurchaseAmount"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    [SessionJson sharedInstance].ltrvn = ltrvn;
}

- (void)updateLastOrderNoWithOrderNo:(NSString *)orderNo{
    NSError *error;
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setString:orderNo forKey:@"lastPurchaseNo"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    [SessionJson sharedInstance].lastOrderNo = orderNo;
}

- (void)updateFirstOrd {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSString *lastOrderNo = [document stringForKey:@"lastPurchaseNo"];
    
    if(!lastOrderNo || [lastOrderNo isEqualToString:@""]) {
        [SessionJson sharedInstance].firstOrd = @"Y";
    }
    else {
        [SessionJson sharedInstance].firstOrd = @"N";
    }
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setString:[SessionJson sharedInstance].firstOrd forKey:@"isFirstPurchase"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)resetLtRvnVt {
    NSError *error;
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:0 forKey:@"spendingVisitToPurchase"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    [SessionJson sharedInstance].ltRvnVt = 0;
}

- (void)updateLtRvnVt {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger ltRvnVt = [document integerForKey:@"spendingVisitToPurchase"];
    
    if(!ltRvnVt) {
        ltRvnVt = 1;
    }

    ltRvnVt = ltRvnVt + 1;
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setInteger:ltRvnVt forKey:@"spendingVisitToPurchase"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)updatePiTraceWithPi:(NSString *)pi {
    NSError *error;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSString *piTrace = [document stringForKey:@"piTrace"];
    
    if(!piTrace || [piTrace isEqualToString:@""] || piTrace == nil) {
        piTrace = pi;
    }
    else {
        piTrace = [piTrace stringByAppendingString:[NSString stringWithFormat:@"|%@", pi]];
    }
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setString:piTrace forKey:@"piTrace"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    
    [SessionJson sharedInstance].piTrace = piTrace;
}

- (void)saveRecentSessionTimeSec {
    NSError *error;
    NSDate *currentTime = [[NSDate alloc] init];
    NSTimeInterval currentTimeSec = [currentTime timeIntervalSince1970];
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    if(!behaviorDoc) {
        behaviorDoc = [[CBLMutableDocument alloc] initWithID:@"Behavior"];
    }
    
    [behaviorDoc setDouble:currentTimeSec forKey:@"recentSessionTimeSec"];
   

    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)saveEnviromentData {
    
}

- (void)saveAppInfo:(NSMutableArray *)appInfo {
    NSError *error;
    //CBLMutableDocument *appInfoDoc = [[CBLMutableDocument alloc] initWithID:@"AppInfo"];
    CBLMutableDocument *appInfoDoc = [[[LocalDB sharedInstance].database documentWithID:@"AppInfo"] toMutable];
    
    [appInfoDoc setString:[appInfo objectAtIndex:0] forKey:@"domain"];
    [appInfoDoc setInteger:[[appInfo objectAtIndex:1] integerValue]forKey:@"serviceNumber"];
    [appInfoDoc setInteger:[[appInfo objectAtIndex:2] integerValue] forKey:@"expireDate"];
    [appInfoDoc setBoolean:[[appInfo objectAtIndex:3] boolValue] forKey:@"isDebug"];
    [appInfoDoc setBoolean:[[appInfo objectAtIndex:4] boolValue] forKey:@"isInstallRetention"];
    [appInfoDoc setBoolean:[[appInfo objectAtIndex:5] boolValue] forKey:@"isFingerPrint"];
    
    [[LocalDB sharedInstance].database saveDocument:appInfoDoc error:&error];
}

- (void)updateIsVisitNew {
    NSError *error;
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setString:@"Y" forKey:@"visitNew"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)resetAboutNewVistInfo {
    NSError *error;
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    [behaviorDoc setString:@"N" forKey:@"visitNew"];
    [behaviorDoc setString:@"N" forKey:@"dailyUnique"];
    [behaviorDoc setString:@"N" forKey:@"weeklyUnique"];
    [behaviorDoc setString:@"N" forKey:@"monthlyUnique"];
    [behaviorDoc setString:@"N" forKey:@"weeklyUnique2"];
    
    [SessionJson sharedInstance].isVisitNew = @"N";
    [SessionJson sharedInstance].isDf = @"N";
    [SessionJson sharedInstance].isWf = @"N";
    [SessionJson sharedInstance].isMf = @"N";
    [SessionJson sharedInstance].isWfUs = @"N";
    
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)saveSessionExpireTime {
    NSError *error;
    
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    if(!behaviorDoc) {
        behaviorDoc = [[CBLMutableDocument alloc] initWithID:@"Behavior"];
    }
    
    [behaviorDoc setDouble:[SessionJson sharedInstance].vtTz/1000 + 1800 forKey:@"sessionExpireSec"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (void)resetSid {
    NSString *newSid = [[[NSUUID alloc] init] UUIDString];
    
    NSError *error;
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    if(!behaviorDoc) {
        behaviorDoc = [[CBLMutableDocument alloc] initWithID:@"Behavior"];
    }
    
    [behaviorDoc setString:newSid forKey:@"sid"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    //[SessionJson sharedInstance].sid = newSid;
}

- (void)resetVtTz {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Install"];
    long timeOffset = [[document numberForKey:@"timeOffset"] longValue];
    
    NSDate *now = [[NSDate alloc] init];
    NSTimeInterval currentTimeSec = [now timeIntervalSince1970];
    //현재 device 세션발생시간에 timeOffset만큼 더하기
    long long vtTz = [[NSNumber numberWithLongLong:currentTimeSec * 1000] longLongValue] + timeOffset;
    
    NSError *error;
    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    if(!behaviorDoc) {
        behaviorDoc = [[CBLMutableDocument alloc] initWithID:@"Behavior"];
    }
    
    [behaviorDoc setLongLong:vtTz forKey:@"vtTz"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
    //[SessionJson sharedInstance].vtTz = vtTz;
}
@end
