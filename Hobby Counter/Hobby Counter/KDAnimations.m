//
//  KDAnimations.m
//
//  Created by Cady Holmes on 1/12/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDAnimations.h"

@implementation KDAnimations

+ (void)pulse:(CALayer *)layer shrinkTo:(CGFloat)shrink withDuration:(CGFloat)dur then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        CABasicAnimation *a;
        a = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        a.duration=dur/2;
        a.repeatCount=0;
        a.autoreverses=NO;
        a.fromValue=[NSNumber numberWithFloat:1];
        a.toValue=[NSNumber numberWithFloat:1.2];
        [layer addAnimation:a forKey:@"animateScale"];
        
        [CATransaction setCompletionBlock:^{
            [CATransaction begin];
            
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            CABasicAnimation *a;
            a = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            a.duration=dur;
            a.repeatCount=HUGE_VALF;
            a.autoreverses=YES;
            a.fromValue=[NSNumber numberWithFloat:1.2];
            a.toValue=[NSNumber numberWithFloat:shrink];
            [layer addAnimation:a forKey:@"animateScale"];
            
            [CATransaction setCompletionBlock:^{
                if (callback) {
                    callback();
                }
            }];
            
            [CATransaction commit];
        }];
        
        [CATransaction commit];
    });
}

+ (void)stopPulse:(CALayer *)layer withDuration:(CGFloat)dur then:(void(^)(void))callback {
    [layer removeAllAnimations];
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    CABasicAnimation *a;
    a = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    a.duration=dur;
    a.repeatCount=0;
    a.autoreverses=NO;
    a.fromValue=[layer valueForKeyPath:@"transform.scale"];
    a.toValue=[NSNumber numberWithFloat:1.0];
    [layer addAnimation:a forKey:@"animateScale"];
    
    [CATransaction setCompletionBlock:^{
        [layer removeAllAnimations];
        
        if (callback) {
            callback();
        }
    }];
    [CATransaction commit];
    
}

+ (void)rock:(CALayer *)layer degrees:(CGFloat)degrees withDuration:(CGFloat)dur then:(void(^)(void))callback {
    float radians = degrees*M_PI/180;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        CABasicAnimation *b;
        b = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        b.duration=dur;
        b.repeatCount=HUGE_VALF;
        b.autoreverses=YES;
        b.fromValue=[NSNumber numberWithFloat:radians];
        b.toValue=[NSNumber numberWithFloat:-radians];
        
        [layer addAnimation:b forKey:@"animateRotation"];
        
        [CATransaction setCompletionBlock:^{
            if (callback) {
                callback();
            }
        }];
        
        [CATransaction commit];
    });
}

+ (void)stopRock:(CALayer *)layer withDuration:(CGFloat)dur then:(void(^)(void))callback {
    float radians = 360*M_PI/180;
    [layer removeAllAnimations];
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CABasicAnimation *a;
    a = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    a.duration=dur;
    a.repeatCount=0;
    a.autoreverses=NO;
    a.fromValue=[layer valueForKeyPath:@"transform.rotation"];
    a.toValue=[NSNumber numberWithFloat:radians];
    [layer addAnimation:a forKey:@"animateRotation"];
    
    [CATransaction setCompletionBlock:^{
        [layer removeAllAnimations];
        
        if (callback) {
            callback();
        }
    }];
    [CATransaction commit];
    
}

+ (void)jiggle:(UIView*)view {
    [KDAnimations jiggle:view amount:1.08 then:nil];
}

+ (void)jiggle:(UIView*)view amount:(float)amount then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1f
                              delay:0.0f
             usingSpringWithDamping:.5f
              initialSpringVelocity:4.f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             view.transform = CGAffineTransformScale(CGAffineTransformIdentity, amount, amount);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.12f
                                                   delay:0.0f
                                  usingSpringWithDamping:.3f
                                   initialSpringVelocity:10.0f
                                                 options:(UIViewAnimationOptionAllowUserInteraction |
                                                          UIViewAnimationOptionCurveEaseOut)
                                              animations:^{
                                                  view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                              }
                                              completion:^(BOOL finished) {
                                                  if (finished) {
                                                      if (callback) {
                                                          callback();
                                                      }
                                                  }
                                              }];
                         }];
    });
}

+ (void)jiggleAndChangeSize:(UIView*)view amount:(float)amount then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1f
                              delay:0.0f
             usingSpringWithDamping:.5f
              initialSpringVelocity:4.f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             view.transform = CGAffineTransformScale(CGAffineTransformIdentity, amount, amount);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)jiggleAndResetSize:(UIView*)view then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.12f
                              delay:0.0f
             usingSpringWithDamping:.3f
              initialSpringVelocity:10.0f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)scale:(UIView*)view amount:(float)amount duration:(float)dur then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:dur
                              delay:0.0f
             usingSpringWithDamping:.3f
              initialSpringVelocity:7.f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             view.transform = CGAffineTransformScale(CGAffineTransformIdentity, amount, amount);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)scaleReset:(UIView*)view duration:(float)dur then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:dur
                              delay:0.0f
             usingSpringWithDamping:.3f
              initialSpringVelocity:7.f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)rotate:(UIView*)view degrees:(float)degrees duration:(float)dur then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:dur
                              delay:0.0f
             usingSpringWithDamping:.3f
              initialSpringVelocity:7.f
                            options:(UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             view.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)rotateReset:(UIView*)view duration:(float)dur then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:dur
                              delay:0.0f
             usingSpringWithDamping:.3f
              initialSpringVelocity:7.f
                            options:(UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)fade:(UIView*)view alpha:(float)alpha duration:(float)dur then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:dur
                              delay:0.0f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             view.alpha = alpha;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)fadeReset:(UIView*)view duration:(float)dur then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:dur
                              delay:0.0f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             view.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)slide:(UIView*)view amountX:(float)x amountY:(float)y duration:(float)dur then:(void(^)(void))callback {
    
    if (!x) {
        x = 0;
    }
    if (!y) {
        y = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:dur
                              delay:0.0f
             usingSpringWithDamping:.7f
              initialSpringVelocity:4.f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             view.transform = CGAffineTransformMakeTranslation(x, y);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)slideReset:(UIView*)view duration:(float)dur then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:dur
                              delay:0.0f
             usingSpringWithDamping:.7f
              initialSpringVelocity:4.f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)fadeSiblingsForView:(UIView*)view toAlpha:(CGFloat)alpha then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *parent = view.superview;
        for (UIView *other in parent.subviews) {
            if (other != view) {
                [UIView animateWithDuration:.25
                                      delay:0
                     usingSpringWithDamping:.5
                      initialSpringVelocity:.8
                                    options:(UIViewAnimationOptionAllowUserInteraction |
                                             UIViewAnimationOptionCurveEaseInOut)
                                 animations:^{
                                     other.alpha = alpha;
                                 }
                                 completion:^(BOOL finished) {
                                     if (finished) {
                                         if (callback) {
                                             callback();
                                         }
                                     }
                                 }];
            }
        }
    });
}

+ (void)offsetLeft:(UIView*)view amount:(CGFloat)amount then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:.25
                              delay:0
             usingSpringWithDamping:.5
              initialSpringVelocity:.8
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             view.transform = CGAffineTransformMakeTranslation(-amount, 0);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)offsetRight:(UIView*)view amount:(CGFloat)amount then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:.25
                              delay:0
             usingSpringWithDamping:.5
              initialSpringVelocity:.8
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             view.transform = CGAffineTransformMakeTranslation(amount, 0);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)offsetReset:(UIView*)view then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.25
                              delay:0
             usingSpringWithDamping:.5
              initialSpringVelocity:.8
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 if (callback) {
                                     callback();
                                 }
                             }
                         }];
    });
}

+ (void)animateViewGrowAndShow:(UIView*)view then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        if (view) {
            [view.layer addAnimation:showAnimation() forKey:nil];
            view.layer.opacity = 1;
        }
        [CATransaction setCompletionBlock:^{
            if (callback) {
                callback();
            }
        }];
        [CATransaction commit];
    });
}

+ (void)animateViewShrinkAndWink:(UIView*)view andRemoveFromSuperview:(BOOL)removeFromSuperview then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (view) {
            [view.layer addAnimation:hideAnimation() forKey:nil];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            view.layer.opacity = 0;
            if (removeFromSuperview) {
                [view removeFromSuperview];
            }
            if (callback) {
                callback();
            }
        });
    });
}

+ (void)showTouchDownAt:(CGPoint)loc withSize:(CGFloat)size andLineWidth:(CGFloat)lineWidth onView:(UIView*)view then:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *glowView = [KDHelpers circleWithColor:[UIColor clearColor] radius:size borderWidth:lineWidth];
        glowView.center = loc;
        glowView.layer.opacity = 0;
        [view addSubview:glowView];
        
        [CATransaction begin];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        CABasicAnimation *a;
        
        a = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        a.duration      = (((float)rand() / RAND_MAX) * .2) + .12;
        a.repeatCount   = 0;
        a.autoreverses  = YES;
        a.fromValue     = @1;
        a.toValue       = @(.95 - (((float)rand() / RAND_MAX) * .5));
        
        CABasicAnimation* b = [CABasicAnimation animationWithKeyPath:@"opacity"];
        b.fromValue = @0;
        b.toValue = @.3;
        b.duration = (((float)rand() / RAND_MAX) * .3) + .18;
        b.autoreverses = YES;
        b.repeatCount = 1;
        b.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        [glowView.layer addAnimation:a forKey:@"animateScale"];
        [glowView.layer addAnimation:b forKey:@"animateOpacity"];
        
        [CATransaction setCompletionBlock:^{
            if (callback) {
                callback();
            }
        }];
        [CATransaction commit];
    });
}

static CAAnimation* showAnimation()
{
    CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    transform.values = values;
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacity setFromValue:@0.0];
    [opacity setToValue:@1.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.2;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [group setAnimations:@[transform, opacity]];
    return group;
}

static CAAnimation* hideAnimation()
{
    CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.00, 1.00, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
    transform.values = values;
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacity setFromValue:@1.0];
    [opacity setToValue:@0.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = .2;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [group setAnimations:@[transform, opacity]];
    return group;
}

@end
