//
//  VisitAction.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 25..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "VisitAction.h"
#import "SessionJson.h"

@implementation VisitAction

- (NSInteger)getUdVt {
    NSInteger udVt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userCriteriaVisit"] integerValue];
    
    if(!udVt) {
        udVt =  0;
    }
    
    return udVt;
}

- (NSInteger)getLtvt {
    NSInteger ltvt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lifeCriteriaVisit"] integerValue];
    
    if(!ltvt) {
        ltvt =  0;
    }
    
    return ltvt;
}

- (NSInteger)getLtVi {
    NSInteger ltVi = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lifeVisitInterval"] integerValue];
    
    if(!ltVi) {
        ltVi =  0;
    }
    
    return ltVi;
}

- (NSInteger)getUdRvnc {
    NSInteger udRvnc = [[[NSUserDefaults standardUserDefaults] objectForKey:@"udRvnc"] integerValue];
    
    if(!udRvnc) {
        udRvnc = 0;
    }
    
    return udRvnc;
}

- (NSInteger)getLtRvnc {
    NSInteger ltrvnc = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ltRvnc"] integerValue];
    
    if(!ltrvnc) {
        ltrvnc = 0;
    }
    
    return ltrvnc;
}

- (NSInteger)getLtrvn {
    NSInteger ltrvn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ltrvn"] integerValue];
    
    if(!ltrvn) {
        ltrvn = 0;
    }
    
    return ltrvn;
}

- (NSInteger)getLtrvni {
    NSInteger ltrvni = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ltrvni"] integerValue];
    
    if(!ltrvni) {
        ltrvni = 0;
    }
    
    return ltrvni;
}

- (NSString *)getLastOrderNo {
    NSString *lastOrderNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOrderNumber"];
    
    if(!lastOrderNo) {
        lastOrderNo = @"";
    }
    
    return lastOrderNo;
}
@end
