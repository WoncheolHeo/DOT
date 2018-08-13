//
//  DOTAPIConstant.h
//  DOT
//
//  Created by Woncheol Heo on 2018. 7. 20..
//  Copyright © 2018년 wisetracker. All rights reserved.
//

#import <Foundation/Foundation.h>

#if DEBUG
//#define kDOTApiUrl @"http://192.168.0.4/collector"
//#define kDOTApiUrl @"http://175.158.15.225:8080/collector"
#define kDOTApiUrl @"http://dev-collector001-ncl.nfra.io/collector"

#else
//#define kDOTApiUrl @"http://192.168.0.4/collector"
//#define kDOTApiUrl @"http://175.158.15.225:8080/collector"
#define kDOTApiUrl @"http://dev-collector001-ncl.nfra.io/collector"
#endif
