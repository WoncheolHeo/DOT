//
//  GoalJson.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 26..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "GoalJson.h"
@implementation GoalJson
static GoalJson *goalJson = nil;
+ (GoalJson *)sharedInstance{
//    static dispatch_once_t pred;
//    dispatch_once(&pred, ^{
//        goalJson = [[super alloc] initUniqueInstance];
//    });
//    return goalJson;
    if(goalJson == nil) {
        goalJson = [[GoalJson alloc] initUniqueInstance];
    }
    return goalJson;
}

-(instancetype) initUniqueInstance {
    return [super init];
}

- (void)setGoal:(NSString *)key value:(double)value {
    [self setValue:[[NSNumber alloc] initWithDouble:value] forKey:key];
}

+ (void)clearInstance {
    goalJson = nil;
}
@end
