//
//  SDFIAPHelper.m
//
//  Created by Trent Milton on 30/12/2013.
//  Copyright (c) 2013 shaydes.dsgn. All rights reserved.
//
//

#import "SDFIAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface SDFIAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation SDFIAPHelper {
    SKProductsRequest *_productsRequest;
    RequestProductsCompletionHandler _requestProductsCompletionHandler;
    RestoreProductsCompletionHandler _restoreProductsCompletionHandler;
    NSSet *_productIdentifiers;
    NSMutableSet *_purchasedProductIdentifiers;
}

- (id) initWithProductIdentifiers:(NSSet *)productIdentifiers {

    if ((self = [super init])) {

        // Store product identifiers
        _productIdentifiers = productIdentifiers;

        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            @synchronized(_purchasedProductIdentifiers) {
                if (productPurchased && ![_purchasedProductIdentifiers containsObject:productIdentifier]) {
                    [_purchasedProductIdentifiers addObject:productIdentifier];
                }
            }
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    _requestProductsCompletionHandler = [completionHandler copy];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];

}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    NSLog(@"Loaded list of products...");
    _productsRequest = nil;

    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }

    _requestProductsCompletionHandler(YES, skProducts);
    _requestProductsCompletionHandler = nil;

}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");

    _productsRequest = nil;
    _requestProductsCompletionHandler(NO, nil);
    _requestProductsCompletionHandler = nil;

}

- (BOOL) productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void) buyProduct:(SKProduct *)product {
    NSLog(@"Buying %@...", product.productIdentifier);

    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) restoreCompletedTransactions:(RestoreProductsCompletionHandler)completionHandler {
    _restoreProductsCompletionHandler = [completionHandler copy];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - IAP Payment

- (void) completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");

    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");

    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"failedTransaction...");

    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDFIAPHelperNotificationProductPurchaseFailed object:transaction.payment.productIdentifier userInfo:nil];
}

- (void) provideContentForProductIdentifier:(NSString *)productIdentifier {

    @synchronized(_purchasedProductIdentifiers) {
        [_purchasedProductIdentifiers addObject:productIdentifier];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDFIAPHelperNotificationProductPurchased object:productIdentifier userInfo:nil];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    for (SKPaymentTransaction *transaction in queue.transactions) {
        [self restoreTransaction:transaction];
    }
    _restoreProductsCompletionHandler(YES, queue.transactions);
    _restoreProductsCompletionHandler = nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"Restore failed: %@", error);
    _restoreProductsCompletionHandler(NO, nil);
}

@end