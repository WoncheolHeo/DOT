//
//  LocalDB.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 11..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "LocalDB.h"

@implementation LocalDB

+ (LocalDB *)sharedInstance{
    static dispatch_once_t pred;
    static LocalDB *localDB = nil;
    dispatch_once(&pred, ^{
        localDB = [[super alloc] initUniqueInstance];
    });
    return localDB;
}
- (instancetype) initUniqueInstance {
    self = [super init];
    if(self) {
        NSError *error;
        self.database = [[CBLDatabase alloc] initWithName:@"DOTLocalDB" error:&error];
    }
    return self;
}
@end
