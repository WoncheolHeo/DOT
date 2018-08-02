//
//  VisitAction.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 25..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VisitAction : NSObject
@property (nonatomic) NSInteger udVt;
@property (nonatomic) NSInteger ltvt;
@property (nonatomic) NSInteger ltVi;

@property (nonatomic) NSInteger udRvnc;
@property (nonatomic) NSInteger ltRvnc;
@property (nonatomic) NSInteger csRvnVs;
@property (nonatomic) NSString *lastOrderNo;
@property (nonatomic) NSString *firstOrd;
@property (nonatomic) NSInteger ltrvni;
@property (nonatomic) NSInteger ltrvn;


- (NSInteger)getUdVt;
- (NSInteger)getLtvt;
- (NSInteger)getLtVi;

- (NSInteger)getUdRvnc;
- (NSInteger)getLtRvnc;
- (NSInteger)getLtrvn;
- (NSInteger)getLtrvni;
- (NSString *)getLastOrderNo;
@end
