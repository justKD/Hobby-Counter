//
//  KDAdsView.m
//
//  Created by Cady Holmes on 2/27/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDAdsView.h"

static NSString* const delegateError = @"Remember to set the KDAdsViewDelegate you louse.";
static NSString* const removeAdsKey = @"KDAds_removeAdsBool";

static CGFloat const cornerRadius = 10;

@interface KDAdsView () <FBAdViewDelegate, FBInterstitialAdDelegate> {
    UILabel *personalAd;
    NSTimer *adTimer;
    BOOL adLoaded;
    BOOL adShown;
    int personalAdCount;
    
    NSString *placementIDFB;
    
    UIView *bannerAdView;
    FBAdView *bannerAdFB1;
    FBAdView *bannerAdFB2;
    BOOL bannerAdFBSwitch;
    
    FBInterstitialAd *interstitialAdFB;
    
    BOOL useBannerAdFB;
    BOOL useRectangleAdFB;
    
    int percentCounter;
    
    float bannerAdTimerDuration;
}

@end

@implementation KDAdsView

#pragma KDAdsView delegate methods
/* Facebook Banner Ad Delegate Methods */
- (void)kdAdWithFBBannerAdDidFailWithError:(NSError *)error {
    id<KDAdsViewDelegate> strongDelegate = self.delegate;
    FBAdView *banner;
    if (bannerAdFBSwitch) {
        banner = bannerAdFB1;
    } else {
        banner = bannerAdFB2;
    }
    if ([strongDelegate respondsToSelector:@selector(kdAd:withFBBannerAd:didFailWithError:)]) {
        [strongDelegate kdAd:self withFBBannerAd:banner didFailWithError:error];
    } else {
        //NSLog(@"%@\nMissing kdAd:withFBBannerAd:didFailWithError:",delegateError);
    }
}
- (void)kdAdDidLoadWithFBBannerAd {
    id<KDAdsViewDelegate> strongDelegate = self.delegate;
    FBAdView *banner;
    if (bannerAdFBSwitch) {
        banner = bannerAdFB1;
    } else {
        banner = bannerAdFB2;
    }
    if ([strongDelegate respondsToSelector:@selector(kdAd:didLoadWithFBBannerAd:)]) {
        [strongDelegate kdAd:self didLoadWithFBBannerAd:banner];
    } else {
        //NSLog(@"%@",delegateError);
    }
}
- (void)kdAdDidTapPersonalAdWithGesture:(UITapGestureRecognizer*)sender {
    id<KDAdsViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdAd:didTapPersonalAdWithGesture:)]) {
        [strongDelegate kdAd:self didTapPersonalAdWithGesture:sender];
    } else {
        NSLog(@"%@\nMissing kdAd:didTapPersonalAdWithGesture:",delegateError);
    }
}
/* Facebook Interstitial Ad Delegate Methods */
- (void)kdAdDidFinishInterstitial {
    id<KDAdsViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdAdDidFinishInterstitial:)]) {
        [strongDelegate kdAdDidFinishInterstitial:self];
    } else {
        //NSLog(@"%@",delegateError);
    }
}

#pragma init
+ (KDAdsView *)initWithUID:(int)uid andDelegate:(id<KDAdsViewDelegate>)delegate andDevMode:(BOOL)devMode {
    KDAdsView *ads = [[KDAdsView alloc] init];
    ads.uid = uid;
    ads.delegate = delegate;
    ads.devMode = devMode;
    [ads checkAds];
    return ads;
}
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!bannerAdTimerDuration) {
        bannerAdTimerDuration = 28;
    }
    if (!self.removeAds) {
        // banner ads and rectangle ads
        if (bannerAdView) {
            // fb banner ads
            if (useBannerAdFB || useRectangleAdFB) {
                [self handleFBBannerAd];
            }
        }
    }
}
- (void)hide {
    adShown = NO;
    if (bannerAdView) {
        if (useBannerAdFB) {
            [KDAnimations slide:self amountX:0 amountY:self.bannerAdHeight*2 duration:.5 then:^{
                [KDAnimations slide:self amountX:-SW() amountY:0 duration:0 then:nil];
            }];
        }
        if (useRectangleAdFB) {
            [KDAnimations fade:self alpha:0 duration:.55 then:nil];
        }
    }
}
- (void)show {
    adShown = YES;
    if (bannerAdView) {
        if (useBannerAdFB) {
            [KDAnimations slide:self amountX:0 amountY:0 duration:.55 then:nil];
        }
        if (useRectangleAdFB) {
            [KDAnimations fadeReset:self duration:.55 then:nil];
        }
    }
}
- (void)checkAds {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",removeAdsKey]];
    
    if ([fileManager fileExistsAtPath:path]) {
        self.removeAds = YES;
    }
    
    if (self.removeAds) {
        self.bannerAdHeight = 0;
        self.bannerAdWidth = 0;
        self.bannerAdOffset = 0;
    } else {
        self.bannerAdHeight = 90;
        self.bannerAdWidth = SW() * .95;
        self.bannerAdOffset = (SW()-self.bannerAdWidth)/2;
        if ([KDHelpers iPhoneXCheck]) {
            self.bannerAdOffset = self.bannerAdOffset + 40;
        }
    }
}
+ (void)setRemoveAds:(BOOL)remove {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",removeAdsKey]];
    if (remove) {
        NSArray *array = @[@0];
        
        [fileManager createFileAtPath:path
                             contents:nil
                           attributes:nil];
        
        [array writeToFile:path atomically:YES];
    } else {
        [fileManager removeItemAtPath:path error:nil];
    }
}
- (NSString*)getPersonalAd {
    NSString *str = [self.personalAds objectAtIndex:personalAdCount];
    personalAdCount++;
    personalAdCount = personalAdCount % [self.personalAds count];
    return str;
}
- (void)tapPersonalAd:(UITapGestureRecognizer*)sender {
    [self kdAdDidTapPersonalAdWithGesture:sender];
}

#pragma Facebook Audience Network Banner Ad (shown on bottom of screen) or Rectangle Ad
// when these are instantiated and added to the view hierarchy, they will run on a timer until removed from view. No need to reload or manage further.
- (void)addFBBanner:(FBAdView*)banner {
    banner.frame = bannerAdView.bounds;
    [bannerAdView addSubview:banner];
    [self show];
    [self resetFBBannerAd];
}
- (void)handleFBBannerAd {
    if (!self.removeAds) {
        if (bannerAdView) {
            for (UIView *view in bannerAdView.subviews) {
                [view removeFromSuperview];
            }
            if (useBannerAdFB || useRectangleAdFB) {
                FBAdView *banner;
                if (bannerAdFBSwitch) {
                    banner = bannerAdFB1;
                    bannerAdFB2 = nil;
                } else {
                    banner = bannerAdFB2;
                    bannerAdFB1 = nil;
                }
                if (adLoaded) {
                    [self addFBBanner:banner];
                } else {
                    [KDHelpers wait:.75 then:^{
                        if (adLoaded) {
                            [self addFBBanner:banner];
                        } else {
                            [KDHelpers wait:.75 then:^{
                                if (adLoaded) {
                                    [self addFBBanner:banner];
                                } else {
                                    float width = bannerAdView.bounds.size.width;
                                    float height = bannerAdView.bounds.size.height;
                                    float w = width * .85;
                                    float h = height * .85;
                                    personalAd = [KDHelpers makeLabelWithWidth:self.bannerAdWidth andHeight:self.bannerAdHeight];
                                    personalAd.frame = CGRectMake((width-w)/2, (height-h)/2, w, h);
                                    personalAd.font = [UIFont fontWithName:KDFontNormal size:20 * .75];
                                    personalAd.textAlignment = NSTextAlignmentCenter;
    
                                    if (self.personalAds) {
                                        personalAd.text = [self getPersonalAd];
                                    }
    
                                    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPersonalAd:)];
                                    [personalAd addGestureRecognizer:t];
    
                                    [bannerAdView addSubview:personalAd];
                                    [self show];
    
                                    [self resetFBBannerAd];
                                }
                            }];
                        }
                    }];
                }
            }
        }
        [self makeBannerAdTimer];
    }
}
- (void)resetFBBannerAd {
    bannerAdFBSwitch = !bannerAdFBSwitch;
    adLoaded = NO;
    
    NSString *pID = [NSString stringWithFormat:@"%@",placementIDFB];
    if (self.devMode) {
        pID = [NSString stringWithFormat:@"IMG_16_9_APP_INSTALL#%@",placementIDFB];
    }
    FBAdView *bannerAd;
    FBAdSize size = kFBAdSizeHeight90Banner;
    if (useRectangleAdFB) {
        size = kFBAdSizeHeight250Rectangle;
    }
    bannerAd  = [[FBAdView alloc] initWithPlacementID:pID
                                               adSize:size
                                   rootViewController:[KDHelpers currentTopViewController]];
    bannerAd.tag = 0;
    bannerAd.delegate = self;
    [bannerAd loadAd];
    
    if (bannerAdFBSwitch) {
        bannerAdFB1 = bannerAd;
    } else {
        bannerAdFB2 = bannerAd;
    }
}
- (void)makeBannerAdTimer {
    if (!self.removeAds) {
        if (adTimer) {
            [adTimer invalidate];
            adTimer = nil;
        }
        adTimer = [NSTimer scheduledTimerWithTimeInterval:bannerAdTimerDuration repeats:YES block:^(NSTimer *timer){
            if (adShown) {
                [self hide];
            }
            [KDHelpers wait:.5 then:^{
                [self handleFBBannerAd];
            }];
        }];
    }
}

#pragma Facebook Audience Network Banner Ad
- (void)makeFBBannerAdWithPlacementID:(NSString*)placementID {
    if (!self.removeAds) {
        adLoaded = NO;
        useBannerAdFB = YES;
        placementIDFB = placementID;
        bannerAdFBSwitch = NO;
        self.frame = CGRectMake((SW()-self.bannerAdWidth)/2, SH()-self.bannerAdHeight-self.bannerAdOffset, self.bannerAdWidth, self.bannerAdHeight);
        bannerAdView = [[UIView alloc] initWithFrame:self.bounds];
        bannerAdView.layer.cornerRadius = cornerRadius;
        bannerAdView.layer.masksToBounds = YES;
        [self addSubview:bannerAdView];
        [KDAnimations slide:self amountX:-SW() amountY:0 duration:0 then:nil];
        
        [self resetFBBannerAd];
    }
}

#pragma Facebook Audience Network Rectangle Ad
- (void)makeFBRectangleAdWithPlacementID:(NSString*)placementID andWidth:(CGFloat)width {
    if (!self.removeAds) {
        adLoaded = NO;
        useRectangleAdFB = YES;
        placementIDFB = placementID;
        bannerAdFBSwitch = NO;
        self.frame = CGRectMake(0, 0, width, 250);
        bannerAdView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:bannerAdView];
        [KDAnimations fade:self alpha:0 duration:0 then:nil];
        
        [self resetFBBannerAd];
    }
}

#pragma Facebook Audience Network Interstitial Ad
// single fire - will need to reset the object after ad is viewed
- (void)makeFBInterstitialAdWithPlacementID:(NSString*)placementID {
    if (!self.removeAds) {
        self.frame = [KDHelpers currentTopViewController].view.frame;
        
        placementIDFB = placementID;
        adLoaded = NO;
        
        NSString *pID = [NSString stringWithFormat:@"%@",placementIDFB];
        if (self.devMode) {
            pID = [NSString stringWithFormat:@"VID_HD_16_9_15S_LINK#%@",placementIDFB];
        }
        
        interstitialAdFB = [[FBInterstitialAd alloc] initWithPlacementID:pID];
        interstitialAdFB.delegate = self;
        [interstitialAdFB loadAd];
    }
}
- (void)showInterstitialAdFB {
    if (adLoaded) {
        [interstitialAdFB showAdFromRootViewController:[KDHelpers currentTopViewController]];
    } else {
        [self.superview bringSubviewToFront:self];
        
        UIView *placeholder = [[UIView alloc] initWithFrame:self.bounds];
        placeholder.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        placeholder.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [KDHelpers makeLabelWithWidth:placeholder.bounds.size.width*.9 andAlignment:NSTextAlignmentCenter andText:[self getPersonalAd]];
        [KDHelpers setFontSize:28 forLabel:label];
        label.center = CGPointMake(placeholder.bounds.size.width/2, placeholder.bounds.size.height*.333);
        
        percentCounter = 0;
        
        UILabel *label2 = [KDHelpers makeLabelWithWidth:placeholder.bounds.size.width*.9 andAlignment:NSTextAlignmentCenter andText:[NSString stringWithFormat:@"Getting ready...\n\n%d %%",percentCounter]];
        label2.center = CGPointMake(placeholder.bounds.size.width/2, placeholder.bounds.size.height*.666);
        
        [placeholder addSubview:label];
        [placeholder addSubview:label2];
        [KDAnimations animateViewGrowAndShow:placeholder then:nil];
        [self addSubview:placeholder];

        
        adTimer = [NSTimer scheduledTimerWithTimeInterval:.08 repeats:YES block:^(NSTimer *timer){
            percentCounter++;
            if (percentCounter <= 100) {
                label2.text = [NSString stringWithFormat:@"Getting Ready...\n\n%d %%",percentCounter];
            }
            if (percentCounter == 100) {
                [KDAnimations jiggle:label2];
            }
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:8.5 repeats:NO block:^(NSTimer *timer){
            [KDAnimations animateViewShrinkAndWink:placeholder andRemoveFromSuperview:YES then:^{
                [adTimer invalidate];
                adTimer = nil;
                [KDHelpers wait:.05 then:^{
                    [self kdAdDidFinishInterstitial];
                }];
            }];
        }];
    }
}
- (void)resetInterstitialAdFB {
    [self.superview sendSubviewToBack:self];
    [self makeFBInterstitialAdWithPlacementID:placementIDFB];
}
#pragma Facebook Audience Network delegate methods
- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    adLoaded = NO;
    
    // fb banner ad
    if (adView.tag == 0) {
        [self kdAdWithFBBannerAdDidFailWithError:error];
    }
    
    // fb rectangle ad
    if (adView.tag == 1) {
        
    }
    
    // fb interstitial ad
    if (adView.tag == 2) {
        
    }
}
- (void)adViewDidLoad:(FBAdView *)adView {
    adLoaded = YES;
    
    // fb banner ad
    if (adView.tag == 0) {
        [self kdAdDidLoadWithFBBannerAd];
    }
    
    // fb rectangle ad
    if (adView.tag == 1) {
        
    }
}

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    adLoaded = YES;
}
- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    [self kdAdDidFinishInterstitial];
}
- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd {

}

@end
