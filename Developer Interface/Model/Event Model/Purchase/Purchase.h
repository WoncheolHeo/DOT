//
//  Purchase.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 6. 28..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
#import "CustomValue.h"
#import "LocalDB.h"

@interface Purchase : NSObject

@property (nonatomic) NSMutableArray <Product *> *orderProductList;
@property (nonatomic) Product *orderProduct;
@property (nonatomic) CustomValue *customValueSet;
@property (nonatomic) NSString *orderNo;
@property (nonatomic) NSString *keywordCategory;
@property (nonatomic) NSString *keyword;

@property (nonatomic) NSMutableArray <NSMutableDictionary *> *productDicList;

//Local DB
@property (nonatomic) CBLDatabase *database;
@property (nonatomic) CBLMutableDocument *behaviorDoc;
@property (nonatomic) CBLMutableDocument *enviromentDoc;

- (void)setPurchase;
- (instancetype)init;
@end
