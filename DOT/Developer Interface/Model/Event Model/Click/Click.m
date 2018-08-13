//
//  Click.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 8. 6..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "Click.h"

@implementation Click

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

@end
