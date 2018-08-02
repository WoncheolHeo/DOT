//
//  PagesJson.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 25..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "PagesJson.h"
@implementation PagesJson
static PagesJson *pagesJson = nil;
+ (PagesJson *)sharedInstance{
//static dispatch_once_t pred;
    
//    dispatch_once(&pred, ^{
//        pagesJson = [[super alloc] initUniqueInstance];
//    });
//    return pagesJson;
    if(pagesJson == nil) {
        pagesJson = [[PagesJson alloc] initUniqueInstance];
    }
    return pagesJson;
}

-(instancetype) initUniqueInstance {
    self = [super init];
    if(self) {
    }
    return self;
}

+ (void)clearInstance {
    pagesJson = nil;
}
@end
