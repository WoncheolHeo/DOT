//
//  LocalDB.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 11..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CouchbaseLite/CouchbaseLite.h>
@interface LocalDB : NSObject

@property ( nonatomic) CBLDatabase *database;

+ (instancetype)sharedInstance;

@end
