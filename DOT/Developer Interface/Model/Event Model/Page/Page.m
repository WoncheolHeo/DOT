//
//  Page.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 3..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "Page.h"
#import "PagesJson.h"
#import "SessionJson.h"
#import "DOTUtil.h"
#import "SessionController.h"

@interface Page ()
@property (nonatomic) SessionController *sessionController;
@end

@implementation Page

- (instancetype)init {
    if(self = [super init]) {
        self.sessionController = [[SessionController alloc] init];
    }
    return self;
}

- (void)setPageIdentity:(NSString *)pageIndetity {
    self.pi = pageIndetity;
    [self.sessionController updatePiTraceWithPi:self.pi];
}

- (void)setSearchingResult:(NSInteger)searchingResult {
    self.searchResult = [[NSNumber alloc] initWithInteger:searchingResult];
   
    if(searchingResult == 0) {
        [SessionJson sharedInstance].isSFail = @"Y";
    }
    else {
        [SessionJson sharedInstance].isSFail = @"N";
    }
}
@end
