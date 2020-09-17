//
//  KDAnimations.h
//
//  Created by Cady Holmes on 1/12/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"
#import "KDColor.h"

@interface KDAnimations : NSObject

+ (void)pulse:(CALayer *)layer shrinkTo:(CGFloat)shrink withDuration:(CGFloat)dur then:(void(^)(void))callback;
+ (void)stopPulse:(CALayer *)layer withDuration:(CGFloat)dur then:(void(^)(void))callback;

+ (void)rock:(CALayer *)layer degrees:(CGFloat)degrees withDuration:(CGFloat)dur then:(void(^)(void))callback;
+ (void)stopRock:(CALayer *)layer withDuration:(CGFloat)dur then:(void(^)(void))callback;

+ (void)jiggle:(UIView*)view;
+ (void)jiggle:(UIView*)view amount:(float)amount then:(void(^)(void))callback;
+ (void)jiggleSize:(UIView*)view amount:(float)amount then:(void(^)(void))callback;
+ (void)jiggleSizeReset:(UIView*)view then:(void(^)(void))callback;

+ (void)scale:(UIView*)view amount:(float)amount duration:(float)dur then:(void(^)(void))callback;
+ (void)scaleReset:(UIView*)view duration:(float)dur then:(void(^)(void))callback;

+ (void)rotate:(UIView*)view degrees:(float)degrees duration:(float)dur then:(void(^)(void))callback;
+ (void)rotateReset:(UIView*)view duration:(float)dur then:(void(^)(void))callback;

+ (void)slide:(UIView*)view amountX:(float)x amountY:(float)y duration:(float)dur then:(void(^)(void))callback;
+ (void)slideReset:(UIView*)view duration:(float)dur then:(void(^)(void))callback;

+ (void)fade:(UIView*)view alpha:(float)alpha duration:(float)dur then:(void(^)(void))callback;
+ (void)fadeReset:(UIView*)view duration:(float)dur then:(void(^)(void))callback;

+ (void)fadeSiblingsForView:(UIView*)view toAlpha:(CGFloat)alpha then:(void(^)(void))callback;

+ (void)offsetLeft:(UIView*)view amount:(CGFloat)amount then:(void(^)(void))callback;
+ (void)offsetRight:(UIView*)view amount:(CGFloat)amount then:(void(^)(void))callback;
+ (void)offsetReset:(UIView*)view then:(void(^)(void))callback;

+ (void)animateViewGrowAndShow:(UIView*)view then:(void(^)(void))callback;
+ (void)animateViewShrinkAndWink:(UIView*)view andRemoveFromSuperview:(BOOL)removeFromSuperview then:(void(^)(void))callback;

+ (void)showTouchDownAt:(CGPoint)loc withSize:(CGFloat)size andLineWidth:(CGFloat)lineWidth onView:(UIView*)view then:(void(^)(void))callback;

@end
