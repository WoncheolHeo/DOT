//
//  SessionManager.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 3..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionJson.h"
#import "RevenueJson.h"

@interface SessionManager : NSObject
+ (instancetype)sharedInstance;
@end
