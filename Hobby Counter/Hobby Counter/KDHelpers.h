//
//  KDHelpers.h
//
//  Created by Cady Holmes on 1/12/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "KDAnimations.h"
#import "KDColor.h"

static NSString* const KDFontNormal = @"HelveticaNeue-UltraLight";
static NSString* const KDFontBold = @"HelveticaNeue-Light";

static CGFloat const KDFontSizeNormal = 20;
static CGFloat const KDFontSizeMedium = 30;
static CGFloat const KDFontSizeLarge = 40;

static NSString* const KDTextIconHamburger = @"≡";
static NSString* const KDTextIconSaveArrow = @"⤒";
static NSString* const KDTextIconLoadArrow = @"⤓";
static NSString* const KDTextIconLeftArrow = @"‹";
static NSString* const KDTextIconLeftDoubleArrow = @"«";
static NSString* const KDTextIconRightArrow = @"›";
static NSString* const KDTextIconRightDoubleArrow = @"»";
static NSString* const KDTextIconLeftOrnament = @"꧁";
static NSString* const KDTextIconRightOrnament = @"꧂";
static NSString* const KDTextIconDot = @"·";
static NSString* const KDTextIconHeart = @"♡";

#ifdef DEBUG
#define clog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

#define RAND(max) (arc4random() % ((unsigned)max + 1))

static inline float FILTER(float input,float lastInput,float k) {return k*lastInput+(1.0-k)*input;}
static inline float CLIP(float input,float min,float max) {return MAX(min,MIN(max,input));}
static inline float SCALE(float input,float min1,float max1,float min2,float max2) {return (((input-min1)*(max2-min2))/(max1-min1))+min2;}
static inline int CLIPI(int input,int min,int max) {return MAX(min,MIN(max,input));}
static inline int SCALEI(int input,int min1,int max1,int min2,int max2) {return (((input-min1)*(max2-min2))/(max1-min1))+min2;}

static inline CGFloat SH() { return [[UIScreen mainScreen] bounds].size.height; }
static inline CGFloat SW() { return [[UIScreen mainScreen] bounds].size.width; }
static inline CGFloat SBH() { return [UIApplication sharedApplication].statusBarFrame.size.height+3; }
static inline CGFloat OXF(UIView *view) { return view.frame.origin.x; }
static inline CGFloat OYF(UIView *view) { return view.frame.origin.y; }
static inline CGFloat OXB(UIView *view) { return view.bounds.origin.x; }
static inline CGFloat OYB(UIView *view) { return view.bounds.origin.y; }
static inline CGFloat VHF(UIView *view) { return view.frame.size.height; }
static inline CGFloat VWF(UIView *view) { return view.frame.size.width; }
static inline CGFloat VHB(UIView *view) { return view.bounds.size.height; }
static inline CGFloat VWB(UIView *view) { return view.bounds.size.width; }

@interface KDHelpers : NSObject

#pragma helper functions
+ (void)wait:(double)delayInSeconds then:(void(^)(void))callback;
+ (void)async:(void(^)(void))callback;

+ (float)getPanPosition:(UIGestureRecognizer *)sender;

+ (UIViewController *)currentTopViewController;

+ (UIFont*)fontWithSize4;
+ (UIFont*)fontWithSize3;
+ (UIFont*)fontWithSize2;
+ (UIFont*)fontWithSize1;

#pragma draw functions
+ (UIView *)circleWithColor:(UIColor *)color radius:(float)radius borderWidth:(float)borderWidth;
+ (UIView*)popupWithClose:(BOOL)close onView:(UIView*)parent withCloseTarget:(id)target forCloseSelector:(SEL)selector withColor:(UIColor*)color withBlurAmount:(float)blur;
+ (void)addCloseButtonToView:(UIView*)view actionTarget:(id)target selector:(SEL)selector;

#pragma check functions
+ (BOOL)headsetPluggedIn;

+ (BOOL)iPadCheck;
+ (BOOL)iPhoneXCheck;

+ (float)getVolume;
+ (BOOL)checkVolume;




+ (NSAttributedString*)underlinedString:(NSString*)string;



+ (UILabel*)makeLabelWithWidth:(CGFloat)width andHeight:(CGFloat)height;
+ (UILabel*)makeLabelWithWidth:(CGFloat)width andFontSize:(CGFloat)size;

+ (UILabel*)makeLabelWithWidth:(CGFloat)width andAlignment:(NSTextAlignment)align andText:(NSString*)text;
+ (UILabel*)makeLabelWithWidth:(CGFloat)width andAlignment:(NSTextAlignment)align;
+ (void)setFontSize:(CGFloat)size forLabel:(UILabel*)label;
+ (void)setLabelHeightFor:(UILabel*)label fontSize:(CGFloat)size fontName:(NSString*)fontName withText:(NSString*)text;



+ (void)appendView:(UIView*)view toView:(UIView*)source withMarginY:(CGFloat)y andIndentX:(CGFloat)x;

+ (void)setOriginX:(CGFloat)x andY:(CGFloat)y forView:(UIView*)view;
+ (void)setOriginX:(CGFloat)x forView:(UIView*)view;
+ (void)setOriginY:(CGFloat)y forView:(UIView*)view;

+ (void)setWidth:(CGFloat)w forView:(UIView*)view;
+ (void)setHeight:(CGFloat)h forView:(UIView*)view;

+ (void)centerView:(UIView*)view onView:(UIView*)target;

+ (BOOL)stringIsJustSpaces:(NSString*)str;

+ (void)addGradientMaskToView:(UIView*)view;


@end
