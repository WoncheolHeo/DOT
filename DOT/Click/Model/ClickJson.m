//
//  ClickJson.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 25..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "ClickJson.h"
#import "ClickData.h"
@implementation ClickJson
static ClickJson *clickJson = nil;
+ (ClickJson *)sharedInstance{
//    static dispatch_once_t pred;
//    static ClickJson *clickJson = nil;
//    dispatch_once(&pred, ^{
//        clickJson = [[super alloc] initUniqueInstance];
//    });
//    return clickJson;
    
    if(clickJson == nil) {
        clickJson = [[ClickJson alloc] initUniqueInstance];
    }
    return clickJson;
}

-(instancetype) initUniqueInstance {
    return [super init];
}

+ (void)clearInstance {
     clickJson = nil;
}

@end
