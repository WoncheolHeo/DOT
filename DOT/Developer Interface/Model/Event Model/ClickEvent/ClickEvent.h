//
//  ClickEvent.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 3..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomValue.h"
#import "Product.h"

@interface ClickEvent : NSObject
@property (nonatomic) CustomValue *customValue;
@property (nonatomic) NSString *ckTp;
@property (nonatomic) NSString *ckData;


- (void)setClickEvent;
- (void)setSearchClickEvent:(NSString *)value;
- (void)setClickEvent:(NSString *)value;
- (void)setPushClickEvent:(NSString *)value;
@end
