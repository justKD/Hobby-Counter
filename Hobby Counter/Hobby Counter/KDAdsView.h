//
//  KDAdsView.h
//
//  Created by Cady Holmes on 2/27/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"

@import FBAudienceNetwork;

@protocol KDAdsViewDelegate;

@interface KDAdsView : UIView

@property (nonatomic, weak) id<KDAdsViewDelegate> delegate;
@property (nonatomic) int uid;

@property (nonatomic) BOOL removeAds;
@property (nonatomic) BOOL devMode;

@property (nonatomic) float bannerAdHeight;
@property (nonatomic) float bannerAdWidth;
@property (nonatomic) float bannerAdOffset;
@property (nonatomic) NSArray *personalAds;

+ (KDAdsView *)initWithUID:(int)uid andDelegate:(id<KDAdsViewDelegate>)delegate andDevMode:(BOOL)devMode;
+ (void)setRemoveAds:(BOOL)remove;
- (void)checkAds;

- (void)makeFBBannerAdWithPlacementID:(NSString*)placementID;
- (void)makeFBRectangleAdWithPlacementID:(NSString*)placementID andWidth:(CGFloat)width;

- (void)makeFBInterstitialAdWithPlacementID:(NSString*)placementID;
- (void)showInterstitialAdFB;
- (void)resetInterstitialAdFB;

@end

@protocol KDAdsViewDelegate <NSObject>
- (void)kdAd:(KDAdsView*)adView didTapPersonalAdWithGesture:(UITapGestureRecognizer*)sender;
@optional
- (void)kdAd:(KDAdsView*)adView withFBBannerAd:(FBAdView*)bannerAd didFailWithError:(NSError*)error;
- (void)kdAd:(KDAdsView*)adView didLoadWithFBBannerAd:(FBAdView*)bannerAd;
- (void)kdAdDidFinishInterstitial:(KDAdsView*)adView;
@end
