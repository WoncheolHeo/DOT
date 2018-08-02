
//  SessionJson.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 22..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "SessionJson.h"
#import "Environment.h"
#import "VisitAction.h"
#import "DOTUtil.h"
#import <AdSupport/ASIdentifierManager.h>
#import "NHNetworkTime.h"
@implementation SessionJson
static SessionJson *sesseionJson = nil;
+ (SessionJson *)sharedInstance{
    if(sesseionJson == nil) {
        sesseionJson = [[SessionJson alloc] initUniqueInstance];
    }
    return sesseionJson;
}

-(instancetype) initUniqueInstance {
    Environment *enviroment = [[Environment alloc] init];
    //NewSession발생 후 최초 sharedInstance할때 호출 or 앱실행시 호출됨.
    
    //userInfo
    self.mbr = [self getMbr];
    self.sx = [self getSx];
    self.ag = [self getAg];
    self.ut1 = [self getUt1];
    self.ut2 = [self getUt2];
    self.ut3 = [self getUt3];
    self.ut4 = [self getUt4];
    self.ut5 = [self getUt5];
    self.mbl = [self getMbl];
    self.mbid = [self getMbid];
    self.isLogin = [self getIsLogin];
    
    self.lng = [enviroment getLng];
    self.cntr = [enviroment getCntr];
    self.tz = [enviroment getTz];
    self.os = [enviroment getOs];
    self.sr = [enviroment getSr];
    self.phone = [enviroment getPhone];
    self.apVr = [enviroment getApVr];
    self.cari = [enviroment getCari];
    self.isWifi = [enviroment getIsWifi];
    self.lnch = [enviroment getInch];
    self.plat = [enviroment getPlatfrom];
    
    //순수방문 체크
    self.isVisitNew = [self getIsVisitNew];
    self.isDf = [self getIsDf];
    self.isWf = [self getIsWf];
    self.isMf = [self getIsMf];
    self.isWfUs = [self getIsWfUs];
    
    NSDate *deviceTime = [[NSDate alloc] init];
    self.deviceTime = [deviceTime timeIntervalSince1970];
    
    self.networkTime = [[NSDate networkDate] timeIntervalSince1970];
    self.vtTz = [self getVtTz];
    //NTP시간 적용
    [self saveSessionExpireTime];
    
    //식별자
    self.advtId = [self getAdid];
    self.uuid = [self getUUID];
    [self saveUUID];
    self.sid = [self getSId];
    [self saveSid];
    self.advtFlag = [self getAdvtFlag];
    self.dSource = @"SDK";
    
    self.udVt = [self getUdVt];
    self.ltvt = [self getLtvt];
    
    //Purchase발생 후 업데이되는 값들
    self.udRvnc = [self getUdRvnc];
    self.ltRvnc = [self getLtRvnc];
    self.csRvnVs = 0;
    self.ltrvni = [self getLtrvni];
    self.lastOrderNo = [self getLastOrderNo];
    self.firstOrd = [self getFirstOrd];
    self.ltrvn = [self getLtrvn];
    self.ltRvnVt = [self getLtRvnVt];

    return [super init];
}

- (NSString *)getAdid {
    ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
    NSString *idfa = [[manager advertisingIdentifier] UUIDString];
    if( [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"] ){
        idfa = @"";
    }
    
    // ###########################################################
    // hash 로직을 쓰도록 되어 있다면 adid를 해시처리해서 저장하도록 로직 추가.
//
//    if( [WiseTrackerCore getFlagAdvertisingIdHasToHash] ){
//        // hash 로직 추가.
//        NSString* _ndTemp = [BSUtil getHashString_SHA256:_idfa];
//        if( _ndTemp != nil && ![_ndTemp isEqualToString:@""]){
//            _idfa = _ndTemp;
//        }
//    }
    
    return idfa;
}

+ (void)clearInstance {
    sesseionJson = nil;
}

- (NSString *)getMbr {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *member = [document stringForKey:@"member"];
    
    return member;
}

- (NSString *)getAg {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *age = [document stringForKey:@"age"];
    
    return age;
}

- (NSString *)getSx {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *gender = [document stringForKey:@"gender"];
    
    return gender;
}

- (NSString *)getUt1 {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *attribute1 = [document stringForKey:@"attribute1"];
    
    return attribute1;
}

- (NSString *)getUt2 {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *attribute2 = [document stringForKey:@"attribute2"];
    
    return attribute2;
}

- (NSString *)getUt3 {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *attribute3 = [document stringForKey:@"attribute3"];
    
    return attribute3;
}

- (NSString *)getUt4 {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *attribute4 = [document stringForKey:@"attribute4"];
    
    return attribute4;
}

- (NSString *)getUt5 {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *attribute5 = [document stringForKey:@"attribute5"];
    
    return attribute5;
}

- (NSString *)getMbl {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *memberGrade = [document stringForKey:@"memberGrade"];
    
    return memberGrade;
}

- (NSString *)getMbid {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *memberId = [document stringForKey:@"memberId"];
    
    return memberId;
}

- (NSString *)getIsLogin {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"UserInfo"];
    NSString *isLogin = [document stringForKey:@"isLogin"];
    
    return isLogin;
}


- (NSInteger)getAdvtFlag {
    ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
    NSInteger advtFlag = manager.advertisingTrackingEnabled;
    return advtFlag;
}

- (NSString *)getUUID {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Enviroment"];
    NSString *uuid = [document stringForKey:@"uuid"];
    
    if(!uuid) {
        uuid = [[[NSUUID alloc] init] UUIDString];
    }
    
    return uuid;
}

- (NSInteger)getUdVt {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger udVt = [document integerForKey:@"userCriteriaVisit"] ;

    if(!udVt) {
        udVt =  1;
    }
    
    return udVt;
}

- (NSInteger)getLtvt {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger ltvt = [document integerForKey:@"lifeCriteriaVisit"] ;
    
    if(!ltvt) {
        ltvt =  1;
    }
    
    return ltvt;
}

- (void)saveSessionExpireTime {

}

- (void)saveUUID {
    NSError *error;
    
    CBLMutableDocument *enviromentDoc = [[[LocalDB sharedInstance].database documentWithID:@"Enviroment"] toMutable];
    if(!enviromentDoc) {
        enviromentDoc = [[CBLMutableDocument alloc] initWithID:@"Enviroment"];
    }
    
    [enviromentDoc setString:self.uuid forKey:@"uuid"];
    [[LocalDB sharedInstance].database saveDocument:enviromentDoc error:&error];
}

- (NSInteger)getUdRvnc {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger udRvnc = [document integerForKey:@"userCriteriaPurchase"] ;
    
    if(!udRvnc) {
        udRvnc =  0;
    }
    

    return udRvnc;
}

- (NSInteger)getLtRvnc {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger ltrvnc = [document integerForKey:@"lifeCriteriaPurchase"] ;
    
    if(!ltrvnc) {
        ltrvnc = 0;
    }
    
    return ltrvnc;
}

- (NSInteger)getCsRvnVs {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger csRvnVs = [document integerForKey:@"spendingTimeToPurchase"];
    
    if(!csRvnVs) {
        csRvnVs = 0;
    }
    
    return csRvnVs;
}
- (NSInteger)getLtrvni {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger ltrvni = [document integerForKey:@"lifePurchaseInterval"];
    
    if(!ltrvni) {
        ltrvni = 0;
    }
    
    return ltrvni;
}

- (NSString *)getLastOrderNo {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSString *lastOrderNo = [document stringForKey:@"lastPurchaseNo"];
    
    if(!lastOrderNo) {
        lastOrderNo = @"";
    }
    
    return lastOrderNo;
}

- (NSString *)getFirstOrd {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSString *firstOrd = [document stringForKey:@"isFirstPurchase"];
    
    if(!firstOrd) {
        firstOrd = @"N";
    }
    
    return firstOrd;
}

- (NSInteger)getLtRvnVt {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger ltRvnVt = [document integerForKey:@"spendingVisitToPurchase"];
    
    if(!ltRvnVt) {
        ltRvnVt = 1;
    }
    
    return ltRvnVt;
}

- (NSInteger)getLtrvn {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSInteger ltrvn = [document integerForKey:@"lifePurchaseAmount"];
    
    if(!ltrvn) {
        ltrvn = 0;
    }
    
    return ltrvn;
}

- (long long)getVtTz {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    long long vtTz = [document longLongForKey:@"vtTz"];
//    long long vtTz;
//    if([self.isVisitNew isEqualToString:@"Y"]) {
//        NSDate *now = [[NSDate alloc] init];
//        NSTimeInterval currentTimeSec = [now timeIntervalSince1970];
//        vtTz = [[NSNumber numberWithLongLong:currentTimeSec * 1000] longLongValue];
//    }
//    else {
//        CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
//        vtTz = [document longLongForKey:@"vtTz"];
//    }
//        vtTz = [[NSNumber numberWithLongLong:self.networkTime] longLongValue];
//        if(self.timeOffset == nil) {
//            NSDate *networkTime = [NSDate networkDate];
//            self.networkTime = [networkTime timeIntervalSince1970];
//            self.timeOffset = @(self.networkTime - self.deviceTime);
//            vtTz = [[NSNumber numberWithLongLong:self.networkTime * 1000] longLongValue];
//        }
//        else if(self.timeOffset != nil) {
//            self.networkTime = self.deviceTime + [self.timeOffset doubleValue];
//            self.vtTz = [[NSNumber numberWithLongLong:self.networkTime * 1000] longLongValue];
//        }
//    }
    
    return vtTz;
}

- (NSString *)getSId {
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    NSString *sid = [document stringForKey:@"sid"];
 
//    NSString *sid;
//    if([self.isVisitNew isEqualToString:@"Y"]) {
//        NSString *newSid = [[[NSUUID alloc] init] UUIDString];
//        sid = newSid;
//    }
//    else {
//        CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
//        NSString *existSid = [document stringForKey:@"sid"];
//        sid = existSid;
//    }
    return sid;
}

- (void)saveSid {
    NSError *error;

    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
    if(!behaviorDoc) {
        behaviorDoc = [[CBLMutableDocument alloc] initWithID:@"Behavior"];
    }

    [behaviorDoc setString:self.sid forKey:@"sid"];
    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
}

- (NSString *)getIsVisitNew {
    NSString *isVisitNew;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    isVisitNew = [document stringForKey:@"visitNew"];
    return isVisitNew;
}

- (NSString *)getIsDf{
    NSString *isDf;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    isDf = [document stringForKey:@"dailyUnique"];
    return isDf;
}

- (NSString *)getIsWf{
    NSString *isWf;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    isWf = [document stringForKey:@"weeklyUnique"];
    return isWf;
}

- (NSString *)getIsMf{
    NSString *isMf;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    isMf = [document stringForKey:@"monthlyUnique"];
    return isMf;
}

- (NSString *)getIsWfUs{
    NSString *isWfUs;
    CBLDocument *document = [[LocalDB sharedInstance].database documentWithID:@"Behavior"];
    isWfUs = [document stringForKey:@"weeklyUnique2"];
    return isWfUs;
}
@end
