//
//  User.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 22..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "User.h"
#import "SessionJson.h"

@implementation User

- (void)setUser {
    SessionJson *sessionJson = [SessionJson sharedInstance];
    sessionJson.mbr = self.member;
    sessionJson.sx = self.gender;
    sessionJson.ut1 = self.attribute1;
    sessionJson.ut2 = self.attribute2;
    sessionJson.ut3 = self.attribute3;
    sessionJson.ut4 = self.attribute4;
    sessionJson.ut5 = self.attribute5;
    sessionJson.mbl = self.memberGrade;
    sessionJson.mbid = self.memberId;
    sessionJson.isLogin = self.isLogin;
}
@end
