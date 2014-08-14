//
//  DemoIAPHelper.m
//
//  Created by Trent Milton on 30/12/2013.
//  Copyright (c) 2013 shaydes.dsgn. All rights reserved.
//

#import "DemoIAPHelper.h"

@implementation DemoIAPHelper

+ (DemoIAPHelper *) sharedInstance {
    static dispatch_once_t once;
    static DemoIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      kGFExtrasProductIdentifier,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

+ (void) loadProducts {
    [[DemoIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            [DemoIAPHelper sharedInstance].products = products;
        } else {
            NSLog(@"Error loading products");
        }
    }];
}

+ (SKProduct *) productForIdentifier:(NSString *)identifier {
    for (SKProduct *p in [DemoIAPHelper sharedInstance].products) {
        if ([p.productIdentifier isEqualToString:kGFExtrasProductIdentifier]) {
            return p;
        }
    }
    return nil;
}

@end
