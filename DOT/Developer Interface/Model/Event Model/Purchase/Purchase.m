//
//  Purchase.m
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 28..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import "Purchase.h"

@implementation Purchase

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
@end
