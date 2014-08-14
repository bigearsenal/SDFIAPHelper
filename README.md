SDFIAPHelper
============

This is a helper for iOS in app purchases which has been heavily based on the tutorial from [here](http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial).

If you have any trouble with using this class just refer to the tutorial mentioned above.

# Usage

1. Create your subclass of SDFIAPHelper. Follow the **DemoIAPHelper** example on exactly what you need to modify.

2. In **AppDelegate** load the products. This is required to have them ready early so they can be accessed later on.

		- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		    // This will load up products for later use
		    [DemoIAPHelper loadProducts];
		    return YES;
		}

3. When you want to process purchases you can use the following method which will do a **buy** or **restore**. If you want to separate the buy and restore it should be a trivial task for you to split out the below method.

		(void) buyOrRestoreExtras {
		  self.processingView.hidden = NO;
		  SKProduct *product = [DemoIAPHelper productForIdentifier:kGFProductExtrasProductID];
		  // There is something to buy or restore
		  if (product) {
		    [[DemoIAPHelper sharedInstance] restoreCompletedTransactions:^(BOOL success, NSArray *products) {
		      // First do a simple test to see if it worked
		      if (!success) {
		        [self setProcessingVisible:NO];
		        return;
		      }
		      // Otherwise check if something actually happened
		      BOOL restored = NO;
		      for (SKPaymentTransaction *pt in products) {
		        if ([pt.originalTransaction.payment.productIdentifier isEqualToString:kGFProductExtrasProductID]) {
		          restored = YES;
		        }
		      }
		      // Only if the extras isn't purchased do we buy it.
		      if (!restored) {
		        [[DemoIAPHelper sharedInstance] buyProduct:product];
		      }
		    }];
		  } else {
				// Something has gone wrong
		    self.processingView.hidden = YES;
		    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		    av.tag = -1;
		    av.message = @"Something went wrong. You can't get or restore the extras at the moment. Maybe you aren't connect to the internets?";
		    [av show];
		  }
		}
