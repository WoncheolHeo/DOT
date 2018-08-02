//
//  Environment.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 25..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "Environment.h"
#import "SessionJson.h"
#import <UIKit/UIKit.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "DOTReachability.h"
#import "LocalDB.h"
@implementation Environment

- (NSString *)getLng {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (NSString *)getCntr {
    CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
    NSString *countryCode = carrier.isoCountryCode;
    
    if(countryCode != nil) {
        return countryCode;
    }
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

- (NSString *)getIP {
    //추가
    
    return @"";
}

- (NSString *)getTz {
    long time = [[NSTimeZone systemTimeZone] secondsFromGMT] / 3600;
    return [[NSString alloc] initWithFormat:@"%ld",time];
}

- (NSString *)getOs {
    NSString* version = [[UIDevice currentDevice] systemVersion];
    NSString* string = [version substringWithRange:NSMakeRange(0,[version rangeOfString:@"."].location)];
    return [NSString stringWithFormat:@"%@%@",@"I",string];
}

- (NSString *)getSr {
    CGRect bounds =[[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = bounds.size.height;
    float scale = [[UIScreen mainScreen] scale];
    
    return [NSString stringWithFormat: @"%d*%d/%.1f",width,height,scale];
}

- (NSString *)getPhone {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (NSString *)getApVr {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (void)setGpsIsOn:(NSString *)gpsIsOn {
    //self.gps = gpsIsOn;
    [SessionJson sharedInstance].gps = gpsIsOn;
}

- (NSString *)getCari {
    CTTelephonyNetworkInfo* netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* sub = [netInfo subscriberCellularProvider];
    if(sub != nil){
        CTCarrier* carrier = sub;
        NSString* name = [carrier carrierName];
        return name;
    }
    return @"ios";
}

- (NSInteger)getIsWifi {
    DOTReachablityType networkType = [DOTReachability isConnectedToNetworkOfType];
    switch(networkType){
        case WiFi :
            return 2; // WIFI
        case WWAN :
            return 1; //3G 4G
        default :
            return 0; //네트워크 접근 불가
    }
}

- (NSString *)getPlatfrom {
    return @"IOS";
}

- (double)getInch {
    //추가
    
    return 11.2;
}
@end
