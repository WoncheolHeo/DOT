//
//  GoalJson.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 26..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "GoalJson.h"
@implementation GoalJson

- (void)setGoal:(NSString *)key value:(double)value {
    [self setValue:[[NSNumber alloc] initWithDouble:value] forKey:key];
}

@end
