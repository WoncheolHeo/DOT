//
//  Click.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 8. 6..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomValue.h"
#import "Product.h"

@interface Click : NSObject

@property (nonatomic) CustomValue *customValue;
@property (nonatomic) NSString *ckTp;
@property (nonatomic) NSString *ckData;

- (void)setSearchClickEvent:(NSString *)value;
- (void)setClickEvent:(NSString *)value;
- (void)setPushClickEvent:(NSString *)value;

@end
