//
//  ClickEvent.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 3..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "ClickEvent.h"
#import "ClickJson.h"
#import "DOTUtil.h"

@implementation ClickEvent

- (void)setSearchClickEvent:(NSString *)value {
    self.ckTp = @"SCH";
    self.ckData = value;
}

- (void)setClickEvent:(NSString *)value {
    self.ckTp = @"CKC";
    self.ckData = value;
}

- (void)setPushClickEvent:(NSString *)value {
    self.ckTp = @"PSH";
    self.ckData = value;
}

- (void)setClickEvent {
    ClickJson *clickJson = [ClickJson sharedInstance];
    
    clickJson.vtTz = [[NSNumber numberWithLongLong:[DOTUtil currentTimeSecMulti1000]] longLongValue];
    clickJson.ckTp = self.ckTp;
    clickJson.ckData = self.ckData;
    
    clickJson.mvt1 = self.customValue.customerValue1;
    clickJson.mvt2 = self.customValue.customerValue2;
    clickJson.mvt3 = self.customValue.customerValue3;
    clickJson.mvt4 = self.customValue.customerValue4;
    clickJson.mvt5 = self.customValue.customerValue5;
    clickJson.mvt6 = self.customValue.customerValue6;
    clickJson.mvt7 = self.customValue.customerValue7;
    clickJson.mvt8 = self.customValue.customerValue8;
    clickJson.mvt9 = self.customValue.customerValue9;
    clickJson.mvt10 = self.customValue.customerValue10;
    
}
@end
