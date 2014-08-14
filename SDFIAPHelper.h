//
//  SDFIAPHelper.h
//
//  Created by Trent Milton on 30/12/2013.
//  Copyright (c) 2013 shaydes.dsgn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kSDFIAPHelperNotificationProductPurchased @"kSDFIAPHelperNotificationProductPurchased"
#define kSDFIAPHelperNotificationProductPurchaseFailed @"kSDFIAPHelperNotificationProductPurchaseFailed"

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);
typedef void (^RestoreProductsCompletionHandler)(BOOL success, NSArray * products);

@interface SDFIAPHelper : NSObject

@property (nonatomic, strong) NSArray *products;

- (id) initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void) requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void) buyProduct:(SKProduct *)product;
- (void) restoreCompletedTransactions:(RestoreProductsCompletionHandler)completionHandler;
- (BOOL) productPurchased:(NSString *)productIdentifier;

@end
