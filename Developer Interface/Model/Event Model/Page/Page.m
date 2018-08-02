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
    self.sessionController = [[SessionController alloc] init];
    return self;
}

- (void)setPageIdentity:(NSString *)pageIndetity {
    self.pi = pageIndetity;
    [PagesJson sharedInstance].pID = self.pi;
    
    [self.sessionController updatePiTrace];
}

- (void)setSearchingResult:(NSInteger)searchingResult {
    self.searchResult = searchingResult;
   
    if(searchingResult == 0) {
        [SessionJson sharedInstance].isSFail = @"Y";
    }
    else {
        [SessionJson sharedInstance].isSFail = @"N";
    }
    [PagesJson sharedInstance].sresult = [[NSNumber alloc] initWithInteger:self.searchResult];
}

- (void)setPage {
    PagesJson *pagesJson = [PagesJson sharedInstance];
    
    pagesJson.scart = self.keywordCategory;
    pagesJson.skwd = self.keyword;
    
    pagesJson.mvt1 = self.customValueSet.customerValue1;
    pagesJson.mvt2 = self.customValueSet.customerValue2;
    pagesJson.mvt3 = self.customValueSet.customerValue3;
    pagesJson.mvt4 = self.customValueSet.customerValue4;
    pagesJson.mvt5 = self.customValueSet.customerValue5;
    pagesJson.mvt6 = self.customValueSet.customerValue6;
    pagesJson.mvt7 = self.customValueSet.customerValue7;
    pagesJson.mvt8 = self.customValueSet.customerValue8;
    pagesJson.mvt9 = self.customValueSet.customerValue9;
    pagesJson.mvt10 = self.customValueSet.customerValue10;
    
    pagesJson.cp = self.contentPath;
    
    pagesJson.pi = self.pi;
// 
//    if(!self.searchResult) {
//        pagesJson.sresult = [[NSNumber alloc] initWithInteger:self.searchResult];
//    }
    pagesJson.pg1 = self.product.firstCategory;
    pagesJson.pg2 = self.product.secondCategory;
    pagesJson.pg3 = self.product.thirdCategory;
    pagesJson.pg4 = self.product.detailCategory;
    pagesJson.pnc = self.product.productCode;
    pagesJson.pnAtr1 = self.product.attribute1;
    pagesJson.pnAtr2 = self.product.attribute2;
    pagesJson.pnAtr3 = self.product.attribute3;
    pagesJson.pnAtr4 = self.product.attribute4;
    pagesJson.pnAtr5 = self.product.attribute5;
    pagesJson.pnAtr6 = self.product.attribute6;
    pagesJson.pnAtr7 = self.product.attribute7;
    pagesJson.pnAtr8 = self.product.attribute8;
    pagesJson.pnAtr9 = self.product.attribute9;
    pagesJson.pnAtr10 = self.product.attribute10;
}

@end
