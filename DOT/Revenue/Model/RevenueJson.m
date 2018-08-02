//
//  RevenueJson.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 26..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "RevenueJson.h"
#import "RevenueData.h"
@implementation RevenueJson

static RevenueJson *revenueJson = nil;
+ (RevenueJson *)sharedInstance{
//    static dispatch_once_t pred;
//    static RevenueJson *revenueJson = nil;
//    dispatch_once(&pred, ^{
//        revenueJson = [[super alloc] initUniqueInstance];
//    });
//    return revenueJson;
    
    if(revenueJson == nil) {
        revenueJson = [[RevenueJson alloc] initUniqueInstance];
    }
    return revenueJson;
}

-(instancetype) initUniqueInstance {
    self = [super init];
    
    if(self) {
        self.productList = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (void)clearInstance {
    revenueJson = nil;
}

@end
