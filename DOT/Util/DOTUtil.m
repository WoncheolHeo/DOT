//
//  DOTUtil.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 4..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "DOTUtil.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "NHNetworkTime.h"
@implementation DOTUtil

+ (NSString *)getCurrentDateString{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    NSString* str = [dateFormatter stringFromDate:[[NSDate alloc] init]];
    return str;
}

+ (NSTimeInterval)convertStringToMills:(NSString*)dateString{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    NSTimeInterval parseDate = [[dateFormatter dateFromString:dateString] timeIntervalSince1970];
    return parseDate;
}

+ (NSTimeInterval)currentTimeSec{
    NSDate* date = [[NSDate alloc] init];
    NSTimeInterval timeSec = [date timeIntervalSince1970];
    //double secsUtc1970 = [[NSDate date]timeIntervalSince1970];
    
    return timeSec;
}

+ (NSTimeInterval)currentTimeSecMulti1000{
    NSDate* date = [[NSDate alloc] init];
    NSTimeInterval timeSec = [date timeIntervalSince1970];

    //정수형 15자리로 수정
    return timeSec * 1000;
}

+ (NSTimeInterval)getCurrentNTPTimeSec {
    NSDate *currentNTPTimeSec = [NSDate networkDate];
    NSTimeInterval timeSec = [currentNTPTimeSec timeIntervalSince1970];
    
    return timeSec;
}

+ (NSMutableDictionary *)parseUrlString:(NSString *)urlString {
    NSArray *urlComponents = [urlString componentsSeparatedByString:@"&"];
    NSMutableDictionary *urlParserDictionary = [[NSMutableDictionary alloc] init];

    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [urlParserDictionary setObject:value forKey:key];
    }
    
    return urlParserDictionary;
}

+ (NSTimeInterval)getExpireLongTime:(NSTimeInterval)recentSessionTime type:(NSString *)type {
    NSDate* now = [[NSDate alloc] init];
    
    if( recentSessionTime > 0 ){
        now = [[NSDate alloc] initWithTimeIntervalSince1970:recentSessionTime];
    }
    
    NSCalendar* unitCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    
    NSDateComponents* component = [unitCalendar components:flags fromDate:now];
   
    if([type isEqualToString:@"DU"]){
        component.hour = 23;
        component.minute = 59;
        component.second = 59;
    }else if([type isEqualToString:@"WU"]){
        component.hour = 23;
        component.minute = 59;
        component.second = 59;
        component.day = component.day - component.weekday + 7;
    }else if([type isEqualToString:@"MU"]){
        component.day = 0;
        component.hour = 23;
        component.minute = 59;
        component.second = 59;
        component.month = component.month + 1;
    }else{
        
    }
    now = [unitCalendar dateFromComponents:component];
    NSTimeInterval expireTime = [now timeIntervalSince1970];
    return expireTime;
}

+ (NSTimeInterval)getExpireLongTimeForWeeklyUSType:(NSTimeInterval)recentSessionTime {
    NSDate* now = [[NSDate alloc] init];
    if( recentSessionTime > 0 ){
        now = [[NSDate alloc] initWithTimeIntervalSince1970:recentSessionTime];
    }
    
    NSCalendar* unitCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDateComponents* component = [unitCalendar components:flags fromDate:now];
    
    // ###############################################
    // 일요일 자정으로 로직을 변경함.
    // getNextWeek 구하기
    component.day = component.day + (8-component.weekday);
    
    component.hour = 23;
    component.minute = 59;
    component.second = 59;
    
    now = [unitCalendar dateFromComponents:component];
    NSTimeInterval expireTime = [now timeIntervalSince1970];
    return expireTime;
}
@end
