//
//  KDInAppHandler.m
//
//  Created by Cady Holmes on 2/28/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDInAppHandler.h"

static NSString* const delegateError = @"Remember to set the KDInAppHandlerDelegate you louse.";

@interface KDInAppHandler () {
    KDActivityIndicator *spinner;
    BOOL wait;
    BOOL done;
}

@property (nonatomic, strong) NSString *bundleVersion;
@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, strong) NSString *receiptPath;

@end

@implementation KDInAppHandler

+ (KDInAppHandler *)initWithUID:(int)uid productID:(NSString*)pID andDelegate:(id<KDInAppHandlerDelegate>)delegate {
    KDInAppHandler *inApp = [[KDInAppHandler alloc] init];
    inApp.uid = uid;
    inApp.productID = pID;
    inApp.delegate = delegate;
    return inApp;
}
- (void)tapPurchase:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    [self purchase];
}
- (void)tapRestore:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    [self restore];
}
- (void)purchase {
    if([SKPaymentQueue canMakePayments]) {
        [self showSpinner];
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.productID]];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    else{
        KDWarningLabel *warningLabel = [[KDWarningLabel alloc] init];
        [warningLabel flashWithString:@"Oops! Please check your device settings to enable purchases!"];
    }
}

- (void)restore {
    [self showSpinner];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (UIView*)getButtonContainer {
    UIView *view = [self makeButtonContainerWithSize:CGSizeMake(SW(), SH()/6)];
    return view;
}
- (UIView*)makeButtonContainerWithSize:(CGSize)size {
    UIView *inAppButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    UILabel *purchase = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, inAppButtons.bounds.size.width/2, inAppButtons.bounds.size.height)];
    purchase.textAlignment = NSTextAlignmentCenter;
    purchase.userInteractionEnabled = YES;
    purchase.font = [KDHelpers fontSize2];
    purchase.attributedText = [KDHelpers underlinedString:@"Purchase"];
    UILabel *restore = [[UILabel alloc] initWithFrame:CGRectMake(inAppButtons.bounds.size.width/2, 0, inAppButtons.bounds.size.width/2, inAppButtons.bounds.size.height)];
    restore.textAlignment = NSTextAlignmentCenter;
    restore.userInteractionEnabled = YES;
    restore.font = [KDHelpers fontSize2];
    restore.attributedText = [KDHelpers underlinedString:@"Restore"];
    [inAppButtons addSubview:purchase];
    [inAppButtons addSubview:restore];
    
    UITapGestureRecognizer *tapPurchase = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPurchase:)];
    UITapGestureRecognizer *tapRestore = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRestore:)];
    [purchase addGestureRecognizer:tapPurchase];
    [restore addGestureRecognizer:tapRestore];
    
    return inAppButtons;
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        [self purchase:validProduct];
    }
    else if(!validProduct){

    }
}

- (void)purchase:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [self hideSpinner];
    //NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            NSString *productID = transaction.payment.productIdentifier;
            if ([productID isEqualToString:self.productID]) {
                KDWarningLabel *warningLabel = [[KDWarningLabel alloc] init];
                [warningLabel flashWithString:@"Purchases restored!"];
                [self handlePurchaseComplete];
                if (self.checkReceiptOnRestore) {
                    [self getReceipt];
                }
            }
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [self hideSpinner];
    if (self.checkReceiptOnRestore) {
        [self getReceipt];
    }
//    KDWarningLabel *warningLabel = [[KDWarningLabel alloc] init];
//    [warningLabel flashWithString:@"Unable to restore. You haven't purchased this yet!"];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    KDWarningLabel *warningLabel = [[KDWarningLabel alloc] init];
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing:
                //NSLog(@"Transaction state -> Purchasing");
                //probably don't need to ever add code here
                break;
            case SKPaymentTransactionStatePurchased:
                //NSLog(@"Transaction state -> Purchase Successful");
                [self handlePurchaseComplete];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                //NSLog(@"Transaction state -> Restored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //NSLog(@"Transaction state -> Cancelled");
                [self hideSpinner];
                if(transaction.error.code == SKErrorPaymentCancelled){
                    [warningLabel flashWithString:@"Transaction cancelled."];
                } else {
                    [warningLabel flashWithString:@"Oops! Something went wrong... Please try again!"];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateDeferred:
                //NSLog(@"Transaction state -> Deferred");
                [self handlePurchaseComplete];
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (void)handlePurchaseComplete {
    [self hideSpinner];
    id<KDInAppHandlerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdInAppPurchaseComplete:)]) {
        [strongDelegate kdInAppPurchaseComplete:self];
    } else {
        NSLog(@"%@",delegateError);
    }
}

- (void)showSpinner {
    [self hideSpinner];
    spinner = [[KDActivityIndicator alloc] init];
    [spinner showThen:nil];
    [[KDHelpers currentTopViewController].view addSubview:spinner];
}

- (void)hideSpinner {
    if (spinner) {
        [spinner hideThen:^{
            [spinner removeFromSuperview];
            spinner = nil;
        }];
    }
}


- (void)getReceipt {
    self.bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    self.bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    self.receiptPath = [[[NSBundle mainBundle] appStoreReceiptURL] path];

    if([[NSFileManager defaultManager] fileExistsAtPath:self.receiptPath]) {
        [self handleReceipt];
    } else {
        [self requestNewReceipt];
        [self showSpinner];
    }
}

- (void)handleReceipt {
    wait = YES;
    done = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.receiptPath]) {
        NSData *receipt = [NSData dataWithContentsOfFile:self.receiptPath options:kNilOptions error:nil];
  
        // Create the JSON object that describes the request
        NSError *error;
        NSDictionary *requestContents = @{@"receipt-data": [receipt base64EncodedStringWithOptions:0]};
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
        
        if (!requestData) {
            NSLog(@"Error creating data for request:\n%@",error);
            if (!self.suppressUserFeedback) {
                [KDWarningLabel flashWarningWithText:@"Oops! Something went wrong..."];
                [KDHelpers wait:2.2 then:^{
                    [KDWarningLabel flashWarningWithText:@"Please try again!"];
                }];
            }
        }
        else {
            // send to correct server
            NSString *urlString = @"https://buy.itunes.apple.com/verifyReceipt";
            if (self.devMode) urlString = @"https://sandbox.itunes.apple.com/verifyReceipt";

            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:requestData];
            
            [self handleReceiptAlerts];
            [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (wait) {
                    wait = NO;
                    if (!error) {
                        self.receipt = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"receipt"];
                    }
                }
            }] resume];
        }
    }
}

- (void)handleReceiptAlerts {
    if (!self.suppressUserFeedback) {
        NSArray *alerts = @[@"Validating receipt...",
                            @"Still waiting on Apple to respond...",
                            @"Sorry this is taking so long...",
                            @"Thanks for being patient!",
                            @"Ok... the internet sucks..."
                            ];
        
        [KDHelpers wait:.5 then:^{
            if (wait) {
                for (int i = 0; i <= [alerts count]; i++) {
                    if (i < [alerts count]) {
                        NSString *alert = [alerts objectAtIndex:i];
                        [KDHelpers wait:i*2.5 then:^{
                            if (wait) {
                                [KDWarningLabel flashWarningWithText:alert];
                            } else {
                                [self handleReceiptRetrieved];
                            }
                        }];
                    } else {
                        [KDHelpers wait:(i*2.5)+.5 then:^{
                            if (wait) {
                                wait = NO;
                                [self showTryAgainAlert];
                            } else {
                                [self handleReceiptRetrieved];
                            }
                        }];
                    }
                }
            } else {
                [self handleReceiptRetrieved];
            }
        }];
    }
}

- (void)handleReceiptRetrieved {
    wait = NO;
    if (!done) {
        done = YES;
        if (self.receipt) {
            id<KDInAppHandlerDelegate> strongDelegate = self.delegate;
            if ([strongDelegate respondsToSelector:@selector(kdInAppHandlerGotReceipt:receipt:)]) {
                [strongDelegate kdInAppHandlerGotReceipt:self receipt:self.receipt];
            } else {
                NSLog(@"%@",delegateError);
            }
        } else {
            if (!self.suppressUserFeedback) {
                [KDWarningLabel flashWarningWithText:@"Oops! Something went wrong..."];
                [KDHelpers wait:2.2 then:^{
                    [KDWarningLabel flashWarningWithText:@"Check you network connection!"];
                }];
            }
        }
    }
}

//- (void)showRequestNewReceiptAlert {
//    NSString *title = @"Request Purchase Receipt";
//    NSString *message = @"We need to request a purchase receipt from Apple.\nThis will require a network connection and may require you to enter your Apple ID details.\n\nDo you want to request the receipt now?";
//
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
//        [self requestNewReceipt];
//        [self showSpinner];
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
//
//    }];
//    [alert addAction:okAction];
//    [alert addAction:cancelAction];
//    [[KDHelpers currentTopViewController] presentViewController:alert animated:YES completion:nil];
//}

- (void)showTryAgainAlert {
    NSString *title = @"Failed to Validate Receipt";
    NSString *message = @"We couldn't get a response from Apple's servers. Sometimes this happens! Would you like to try again?";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [self handleReceipt];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No, I'll try later." style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [[KDHelpers currentTopViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)requestNewReceipt {
    //Begin a request for a receipt from Apple
    [KDHelpers currentTopViewController].view.userInteractionEnabled = NO;
    [self showSpinner];
    SKReceiptRefreshRequest *receiptRefreshRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
    [receiptRefreshRequest setDelegate:self];
    [receiptRefreshRequest start];
}

#pragma SKRequestDelegate methods for receipts

- (void)requestDidFinish:(SKRequest *)request {
    [KDHelpers currentTopViewController].view.userInteractionEnabled = YES;
    [self hideSpinner];
    if([[NSFileManager defaultManager] fileExistsAtPath:self.receiptPath]) {
        [self handleReceipt];
    } else {
        if (!self.suppressUserFeedback) {
            [KDWarningLabel flashWarningWithText:@"No valid receipt exists."];
        }
    }
    id<KDInAppHandlerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdInAppReceiptRequestDidFinish:)]) {
        [strongDelegate kdInAppReceiptRequestDidFinish:self];
    } else {
        NSLog(@"%@",delegateError);
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [KDHelpers currentTopViewController].view.userInteractionEnabled = YES;
    [self hideSpinner];
    if (!self.suppressUserFeedback) {
        [KDWarningLabel flashWarningWithText:@"Currently unable to get receipt."];
    }
    id<KDInAppHandlerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdInAppReceiptRequestDidFail:withError:)]) {
        [strongDelegate kdInAppReceiptRequestDidFail:self withError:error];
    } else {
        NSLog(@"%@",delegateError);
    }
}


@end
