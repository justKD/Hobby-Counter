//
//  KDActivityIndicator.m
//
//  Created by Cady Holmes on 2/21/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDActivityIndicator.h"

@implementation KDActivityIndicator

+ (KDActivityIndicator*)makeAndShowThen:(void(^)(void))callback {
    KDActivityIndicator *spinner = [[KDActivityIndicator alloc] init];
    [[KDHelpers currentTopViewController].view addSubview:spinner];
    [spinner showThen:callback];
    
    return spinner;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self setup];
}

- (void)setup {
    float fontSize = 20;
    UIView *window = [KDHelpers currentTopViewController].view;
    float width = window.bounds.size.width;
    float height = window.bounds.size.height;
    float w = width;
    float h = fontSize * 3;
    
    self.frame = CGRectMake(0, 0, w, h);
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
    if (self.bannerColor) {
        self.backgroundColor = self.bannerColor;
    }
    self.center = CGPointMake(width/2, height/2);
    self.userInteractionEnabled = NO;
    
    UILabel *a = [self makeDot];
    UILabel *b = [self makeDot];
    UILabel *c = [self makeDot];
    UILabel *d = [self makeDot];
    UILabel *e = [self makeDot];
    
//    a.textColor = [UIColor colorWithRed:238/255.0 green:82/255.0 blue:83/255.0 alpha:1];
//    b.textColor = [UIColor colorWithRed:255/255.0 green:159/255.0 blue:67/255.0 alpha:1];
//    c.textColor = [UIColor colorWithRed:254/255.0 green:202/255.0 blue:87/255.0 alpha:1];
//    d.textColor = [UIColor colorWithRed:16/255.0 green:172/255.0 blue:132/255.0 alpha:1];
//    e.textColor = [UIColor colorWithRed:46/255.0 green:134/255.0 blue:222/255.0 alpha:1];
    
    float x = self.bounds.size.width / 2;
    float y = (self.bounds.size.height / 2) - (self.bounds.size.height / 13);
    float z = 40;
    
    c.center = CGPointMake(x, y);
    b.center = CGPointMake(x - z, y);
    d.center = CGPointMake(x + z, y);
    a.center = CGPointMake(x - z - z, y);
    e.center = CGPointMake(x + z + z, y);
    
    NSArray *arr = @[a, b, c, d, e];
    dots = [NSArray arrayWithArray:arr];
    
    for (UILabel *dot in dots) {
        [self addSubview:dot];
    }
}

- (UILabel*)makeDot {
    UILabel *dot = [[UILabel alloc] init];
    
    dot.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    dot.textAlignment = NSTextAlignmentCenter;
    dot.textColor = [UIColor whiteColor];
    if (self.dotColor) {
        dot.textColor = self.dotColor;
    }
    dot.text = @"·";
    dot.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:100];
    
    return dot;
}

- (void)showThen:(void(^)(void))callback {
    [KDAnimations animateViewGrowAndShow:self then:^{
        [self animate];
        if (callback) {
            callback();
        }
    }];
}
- (void)animate {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < dots.count; i++) {
            float interval = .66;
            UILabel *dot = [dots objectAtIndex:i];
            [KDHelpers wait:i*(interval/3) then:^{
                [KDAnimations pulse:dot.layer shrinkTo:.2 withDuration:interval then:nil];
            }];
        }
    });
}
- (void)stopAnimate {
    for (int i = 0; i < dots.count; i++) {
        UILabel *dot = [dots objectAtIndex:i];
        [KDAnimations stopPulse:dot.layer withDuration:0 then:nil];
    }
}

- (void)hideThen:(void(^)(void))callback {
    [KDAnimations animateViewShrinkAndWink:self andRemoveFromSuperview:NO then:^{
        [self stopAnimate];
        if (callback) {
            callback();
        }
    }];
}

@end
