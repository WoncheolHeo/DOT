//
//  SessionController.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 3..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "SessionManager.h"
#import "DOTUtil.h"

@implementation SessionManager

+ (SessionManager *)sharedInstance{
    static dispatch_once_t pred;
    static SessionManager *sessionManager = nil;
    dispatch_once(&pred, ^{
        sessionManager = [[super alloc] initUniqueInstance];
    });
    return sessionManager;
}

-(instancetype) initUniqueInstance {
    [self createSession];
    return [super init];
}

- (NSString *)createSession {
    
    return @"";
}
@end
