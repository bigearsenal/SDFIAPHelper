//
//  DemoIAPHelper.h
//
//  Created by Trent Milton on 30/12/2013.
//  Copyright (c) 2013 shaydes.dsgn. All rights reserved.
//

#define kGFExtrasProductIdentifier @"com.shaydesdsgn.demo.extras"

#import "SDIAPHelper.h"

@interface DemoIAPHelper : SDIAPHelper

+ (DemoIAPHelper *) sharedInstance;
+ (void) loadProducts;
+ (SKProduct *) productForIdentifier:(NSString *)identifier;

@end
