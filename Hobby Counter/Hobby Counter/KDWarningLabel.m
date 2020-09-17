//
//  KDWarningLabel.m
//
//  Created by Cady Holmes on 1/18/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDWarningLabel.h"

@implementation KDWarningLabel

- (id)init {
    self = [super init];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithText:(NSString *)text {
    self = [super init];
    
    if (self) {
        [self setup];
        self.text = text;
    }
    
    return self;
}

- (void)setup {
    NSString *font = @"HelveticaNeue-UltraLight";
    
    float fontSize = 20;
    UIView *window = [KDHelpers currentTopViewController].view;
    float width = window.bounds.size.width;
    float height = window.bounds.size.height;
    float w = width;
    float h = fontSize * 3;
    
    self.flashDuration = 2;
    
    self.frame = CGRectMake(0, 0, w, h);
    self.textAlignment = NSTextAlignmentCenter;
    self.font = [UIFont fontWithName:font size:fontSize];
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
    self.center = CGPointMake(width/2, height/2);
    self.alpha = 0;
}

+ (void)flashWarningWithText:(NSString*)text {
    KDWarningLabel *warning = [[KDWarningLabel alloc] init];
    [[KDHelpers currentTopViewController].view addSubview:warning];
    [warning flashWithString:text];
}

- (void)flash {
    if (!showing) {
        [self show];
        [KDHelpers wait:self.flashDuration then:^{
            [self hide];
        }];
    }
}

- (void)flashWithString:(NSString *)string {
    if (!showing) {
        NSString *temp = self.text;
        self.text = string;
        [self show];
        [KDHelpers wait:self.flashDuration then:^{
            [self hideThen:^{
                self.text = temp;
            }];
        }];
    }
}

- (void)show {
    showing = YES;
    [KDAnimations animateViewGrowAndShow:self then:nil];
}

- (void)showThen:(void(^)(void))callback {
    showing = YES;
    [KDAnimations animateViewGrowAndShow:self then:^{
        if (callback) {
            callback();
        }
    }];
}

- (void)hide {
    [KDAnimations animateViewShrinkAndWink:self andRemoveFromSuperview:NO then:^{
        showing = NO;
    }];
}

- (void)hideThen:(void(^)(void))callback {
    [KDAnimations animateViewShrinkAndWink:self andRemoveFromSuperview:NO then:^{
        showing = NO;
        if (callback) {
            callback();
        }
    }];
}

- (void)checkVolume {
    float vol = [KDHelpers getVolume];
    if (vol < .4) {
        
        NSString *volWarning = @"Your device volume may be too low!";
        [self flashWithString:volWarning];
    }
}

@end
