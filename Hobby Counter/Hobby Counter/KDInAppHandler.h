//
//  KDInAppHandler.h
//
//  Created by Cady Holmes on 2/28/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "KDActivityIndicator.h"
#import "KDWarningLabel.h"

@protocol KDInAppHandlerDelegate;

@interface KDInAppHandler : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, weak) id<KDInAppHandlerDelegate> delegate;
@property (nonatomic) int uid;
@property (nonatomic, strong) NSString *productID;
@property (nonatomic) BOOL devMode;
@property (nonatomic) BOOL checkReceiptOnRestore;
@property (nonatomic) BOOL suppressUserFeedback;
@property (nonatomic, strong) NSDictionary* receipt;

+ (KDInAppHandler *)initWithUID:(int)uid productID:(NSString*)pID andDelegate:(id<KDInAppHandlerDelegate>)delegate;
- (UIView*)makeButtonContainerWithSize:(CGSize)size;
- (UIView*)getButtonContainer;

- (void)purchase;
- (void)restore;
- (void)getReceipt;

@end

@protocol KDInAppHandlerDelegate <NSObject>
- (void)kdInAppPurchaseComplete:(KDInAppHandler*)inApp;
@optional
- (void)kdInAppHandlerGotReceipt:(KDInAppHandler*)inApp receipt:(NSDictionary*)receipt;
- (void)kdInAppReceiptRequestDidFinish:(KDInAppHandler*)inApp;
- (void)kdInAppReceiptRequestDidFail:(KDInAppHandler*)inApp withError:(NSError*)error;
@end
