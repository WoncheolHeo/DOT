//
//  Referrer.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 6..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "Referrer.h"
#import "SessionJson.h"
#import "DOTUtil.h"
@implementation Referrer

- (void)parseDeepLink:(NSString *)deepLink {
    
    NSMutableDictionary *deepLinkDictionary = [[NSMutableDictionary alloc] init];
    deepLinkDictionary = [DOTUtil parseUrlString:deepLink];

    SessionJson *sessionJson = [SessionJson sharedInstance];
    sessionJson.wts = [deepLinkDictionary objectForKey:@"_wts"];
    sessionJson.wtc = [deepLinkDictionary objectForKey:@"_wtc"];
    sessionJson.wtm = [deepLinkDictionary objectForKey:@"_wtm"];
    sessionJson.wtw = [deepLinkDictionary objectForKey:@"_wtw"];
    sessionJson.wtclkTime = [[deepLinkDictionary objectForKey:@"_wtclkTime"] integerValue];
    sessionJson.wtaffid = [deepLinkDictionary objectForKey:@"_wtaffid"];
    sessionJson.wtbffid = [deepLinkDictionary objectForKey:@"_wtbffid"];
    sessionJson.wtref = deepLink;
    
    
}

- (void)parseReferrer:(NSString *)referrer {

    NSMutableDictionary *referrerDictionary = [[NSMutableDictionary alloc] init];
    referrerDictionary = [DOTUtil parseUrlString:referrer];
    
    SessionJson *sessionJson = [SessionJson sharedInstance];
    sessionJson.its = [referrerDictionary objectForKey:@"_wts"];
    sessionJson.itc = [referrerDictionary objectForKey:@"_wtc"];
    sessionJson.itm = [referrerDictionary objectForKey:@"_wtm"];
    sessionJson.itw = [referrerDictionary objectForKey:@"_wtw"];
    sessionJson.itaffid = [referrerDictionary objectForKey:@"_wtaffid"];
    sessionJson.itbffid = [referrerDictionary objectForKey:@"_wtbffid"];
    sessionJson.itclkTime = [[referrerDictionary objectForKey:@"_wtclkTime"] integerValue];
    sessionJson.installReferrer = referrer;
}

@end
