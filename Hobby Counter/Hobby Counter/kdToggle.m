//
//  kdToggle.m
//
//  Created by Cady Holmes on 12/12/17.
//  Copyright © 2017 Cady Holmes. All rights reserved.
//

#import "kdToggle.h"

@implementation kdToggle

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (kdToggle *)initWithID:(int)uid {
    kdToggle *toggle = [[kdToggle alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    toggle.uid = uid;
    
    return toggle;
}

- (void)willMoveToSuperview:(UIView*)newSuperview {
    [self setDefaults];
}

///////
//delegate methods
- (void)kdToggleWasToggled {
    id<kdToggleDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdToggleWasToggled:)]) {
        [strongDelegate kdToggleWasToggled:self];
    }
}

///////
//setup
- (void)setDefaults {
    empty = YES;
    
    if (!self.isOn) {
        self.isOn = NO;
    }
    if (self.size) {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.size, self.size)];
        [self.label setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.imageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    if (!self.animDuration) {
        self.animDuration = .3;
    }
    if (!self.cornerRadius) {
        self.cornerRadius = 0;
    }
    if (!self.borderWidth) {
        self.borderWidth = .5;
    }
    if (!self.borderColor) {
        self.borderColor = [UIColor blackColor];
    }
    if (!self.onColor) {
        self.onColor = [UIColor lightGrayColor];
    }
    if (!self.offColor) {
        self.offColor = [UIColor clearColor];
    }
    if (!self.font) {
        self.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:self.size*.8];
    }
    
    UIColor *color = self.offColor;
    if (self.isOn) {
        color = self.onColor;
    }
    [self setBackgroundColor:color];
    
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:self.cornerRadius];
    [self.layer setBorderWidth:self.borderWidth];
    [self.layer setBorderColor:self.borderColor.CGColor];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    if (self.backgroundImage) {
        empty = NO;
        [self.imageView setImage:self.backgroundImage];
    }
    [self addSubview:self.imageView];
    
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.label setFont:self.font];
    if (self.text) {
        empty = NO;
        [self.label setText:self.text];
    } else {
        if (empty) {
            [self.label setText:@"X"];
            [self.label setHidden:YES];
        }
    }
    [self addSubview:self.label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToggle:)];
    [self addGestureRecognizer:tap];
    
    [self animateState];
}

///////
- (void)setOn:(BOOL)on {
    self.isOn = on;
    [self animateState];
}

- (void)tapToggle:(UITapGestureRecognizer*)sender {
    [self toggleState];
}

- (void)toggleState {
    self.isOn = !self.isOn;
    [self animateState];
    [self kdToggleWasToggled];
}

- (void)animateState {
    UIColor *endColor = self.offColor;

    if (self.isOn) {
        endColor = self.onColor;
    }
    
    if (empty) {
        if (self.isOn) {
            self.label.hidden = NO;
        } else {
            self.label.hidden = YES;
        }
    } else {
        if (self.text) {
            if (self.isOn) {
                self.label.alpha = 1;
            } else {
                self.label.alpha = .45;
            }
        }
        if (self.backgroundImage) {
            if (self.isOn) {
                self.imageView.alpha = 1;
            } else {
                self.imageView.alpha = .25;
            }
        }
    }
    
    [self setBackgroundColor:endColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1f
                              delay:0.0f
             usingSpringWithDamping:.5f
              initialSpringVelocity:4.f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.075, 1.075);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.12f
                                                   delay:0.0f
                                  usingSpringWithDamping:.3f
                                   initialSpringVelocity:10.0f
                                                 options:(UIViewAnimationOptionAllowUserInteraction |
                                                          UIViewAnimationOptionCurveEaseOut)
                                              animations:^{
                                                  self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                              }
                                              completion:^(BOOL finished) {
                                              }];
                         }];
    });
}

@end
