//
//  Purchase.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 28..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "Purchase.h"
#import "RevenueJson.h"
#import "DOTUtil.h"

@implementation Purchase

- (instancetype)init {
    //self.database = [LocalDB sharedInstance].database;
//    self.behaviorDoc = [[CBLMutableDocument alloc] initWithID:@"Behavior"];
 //   self.enviromentDoc = [[CBLMutableDocument alloc] initWithID:@"Enviroment"];
    
    return self;
}

- (void)setOrderProductList:(NSMutableArray<Product *> *)productList {

    self.productDicList = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < productList.count; i++) {
         
        NSMutableDictionary *productDic = [[NSMutableDictionary alloc] init];
        
        [productDic setValue:[productList objectAtIndex:i].firstCategory forKey:@"pg1"];
        [productDic setValue:[productList objectAtIndex:i].secondCategory forKey:@"pg2"];
        [productDic setValue:[productList objectAtIndex:i].thirdCategory forKey:@"pg3"];
        [productDic setValue:[productList objectAtIndex:i].detailCategory forKey:@"pg4"];
        [productDic setValue:[productList objectAtIndex:i].productCode forKey:@"pno"];
        [productDic setValue:[productList objectAtIndex:i].attribute1 forKey:@"pnAtr1"];
        [productDic setValue:[productList objectAtIndex:i].attribute2 forKey:@"pnAtr2"];
        [productDic setValue:[productList objectAtIndex:i].attribute3 forKey:@"pnAtr3"];
        [productDic setValue:[productList objectAtIndex:i].attribute4 forKey:@"pnAtr4"];
        [productDic setValue:[productList objectAtIndex:i].attribute5 forKey:@"pnAtr5"];
        [productDic setValue:[productList objectAtIndex:i].attribute6 forKey:@"pnAtr6"];
        [productDic setValue:[productList objectAtIndex:i].attribute7 forKey:@"pnAtr7"];
        [productDic setValue:[productList objectAtIndex:i].attribute8 forKey:@"pnAtr8"];
        [productDic setValue:[productList objectAtIndex:i].attribute9 forKey:@"pnAtr9"];
        [productDic setValue:[productList objectAtIndex:i].attribute10 forKey:@"pnAtr10"];
        [productDic setValue:[[NSNumber alloc] initWithDouble:[productList objectAtIndex:i].orderAmount] forKey:@"amt"];
        [productDic setValue:[[NSNumber alloc] initWithInteger:[productList objectAtIndex:i].orderQuantity] forKey:@"ea"];
        [productDic setValue:[[NSNumber alloc] initWithDouble:[productList objectAtIndex:i].refundAmount] forKey:@"rfnd"];
        [productDic setValue:[[NSNumber alloc] initWithInteger:[productList objectAtIndex:i].refundQuantity] forKey:@"rfea"];
        [productDic setValue:[productList objectAtIndex:i].productOrderNo forKey:@"ordPno"];
        
        [self.productDicList addObject:productDic];
    }
}

- (void)setOrderProduct:(Product *)orderProduct {
    
    self.productDicList = [[NSMutableArray alloc] init];
    NSMutableDictionary *productDic = [[NSMutableDictionary alloc] init];
    
    [productDic setValue:orderProduct.firstCategory forKey:@"pg1"];
    [productDic setValue:orderProduct.secondCategory forKey:@"pg2"];
    [productDic setValue:orderProduct.thirdCategory forKey:@"pg3"];
    [productDic setValue:orderProduct.detailCategory forKey:@"pg4"];
    [productDic setValue:orderProduct.productCode forKey:@"pno"];
    [productDic setValue:orderProduct.attribute1 forKey:@"pnAtr1"];
    [productDic setValue:orderProduct.attribute2 forKey:@"pnAtr2"];
    [productDic setValue:orderProduct.attribute3 forKey:@"pnAtr3"];
    [productDic setValue:orderProduct.attribute4 forKey:@"pnAtr4"];
    [productDic setValue:orderProduct.attribute5 forKey:@"pnAtr5"];
    [productDic setValue:orderProduct.attribute6 forKey:@"pnAtr6"];
    [productDic setValue:orderProduct.attribute7 forKey:@"pnAtr7"];
    [productDic setValue:orderProduct.attribute8 forKey:@"pnAtr8"];
    [productDic setValue:orderProduct.attribute9 forKey:@"pnAtr9"];
    [productDic setValue:orderProduct.attribute10 forKey:@"pnAtr10"];
    [productDic setValue:[[NSNumber alloc] initWithDouble:orderProduct.orderAmount] forKey:@"amt"];
    [productDic setValue:[[NSNumber alloc] initWithInteger:orderProduct.orderQuantity] forKey:@"ea"];
    [productDic setValue:[[NSNumber alloc] initWithDouble:orderProduct.refundAmount] forKey:@"rfnd"];
    [productDic setValue:[[NSNumber alloc] initWithInteger:orderProduct.refundQuantity] forKey:@"rfea"];
    [productDic setValue:orderProduct.productOrderNo forKey:@"ordPno"];
    
    [self.productDicList addObject:productDic];
}

- (void)setPurchase {
    RevenueJson *revenueJson = [RevenueJson sharedInstance];
   
    //revenueData에 값세팅(필요여부 차후판단)
    
    revenueJson.vtTz = [[NSNumber numberWithLongLong:[DOTUtil currentTimeSecMulti1000]] longLongValue];
    revenueJson.scart = self.keywordCategory;
    revenueJson.skwd = self.keyword;
   
    revenueJson.mvt1 = self.customValueSet.customerValue1;
    revenueJson.mvt2 = self.customValueSet.customerValue2;
    revenueJson.mvt3 = self.customValueSet.customerValue3;
    revenueJson.mvt4 = self.customValueSet.customerValue4;
    revenueJson.mvt5 = self.customValueSet.customerValue5;
    revenueJson.mvt6 = self.customValueSet.customerValue6;
    revenueJson.mvt7 = self.customValueSet.customerValue7;
    revenueJson.mvt8 = self.customValueSet.customerValue8;
    revenueJson.mvt9 = self.customValueSet.customerValue9;
    revenueJson.mvt10 = self.customValueSet.customerValue10;
    
    revenueJson.productList = self.productDicList;
    revenueJson.ordNo = self.orderNo;
    
    //revenueJsonDict 값세팅
//    if(revenueJson.vtTz) {
//        [revenueJsonDict setValue:[[NSNumber alloc] initWithInteger:revenueJson.vtTz] forKey:@"vtTz"];
//    }
//
//    [revenueJsonDict setValue:revenueJson.scart forKey:@"scart"];
//    [revenueJsonDict setValue:revenueJson.skwd forKey:@"skwd"];
//
//    //CustomValue setting
//    [revenueJsonDict setValue:revenueJson.mvt1 forKey:@"mvt1"];
//    [revenueJsonDict setValue:revenueJson.mvt2 forKey:@"mvt2"];
//    [revenueJsonDict setValue:revenueJson.mvt3 forKey:@"mvt3"];
//    [revenueJsonDict setValue:revenueJson.mvt4 forKey:@"mvt4"];
//    [revenueJsonDict setValue:revenueJson.mvt5 forKey:@"mvt5"];
//    [revenueJsonDict setValue:revenueJson.mvt6 forKey:@"mvt6"];
//    [revenueJsonDict setValue:revenueJson.mvt7 forKey:@"mvt7"];
//    [revenueJsonDict setValue:revenueJson.mvt8 forKey:@"mvt8"];
//    [revenueJsonDict setValue:revenueJson.mvt9 forKey:@"mvt9"];
//    [revenueJsonDict setValue:revenueJson.mvt10 forKey:@"mvt10"];
//
//    //Product setting
//    if(revenueJson.productList.count > 0) {
//        [revenueJsonDict setValue:revenueJson.productList forKey:@"product"];
//    }
//
//    [revenueJsonDict setValue:revenueJson.ordNo forKey:@"ordNo"];
//
//    //마지막 구매시간 저장
//    NSError *error;
//    double currentSec = [DOTUtil currentTimeSec];
//
//    CBLMutableDocument *behaviorDoc = [[[LocalDB sharedInstance].database documentWithID:@"Behavior"] toMutable];
//    if(!behaviorDoc) {
//        behaviorDoc = [[CBLMutableDocument alloc] initWithID:@"Behavior"];
//    }
//
//    [behaviorDoc setDouble:currentSec forKey:@"lastPurchaseTimeSec"];
//    [[LocalDB sharedInstance].database saveDocument:behaviorDoc error:&error];
//
//    revenueJson.finalRevenueJson = revenueJsonDict;
    
}
@end
