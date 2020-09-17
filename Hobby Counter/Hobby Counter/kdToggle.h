//
//  kdToggle.h
//
//  Created by Cady Holmes on 12/12/17.
//  Copyright © 2017 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"
#import "KDAnimations.h"
#import "KDColor.h"

@protocol kdToggleDelegate;

@interface kdToggle : UIView {
    BOOL empty;
}

@property (nonatomic, weak) id<kdToggleDelegate> delegate;
@property (nonatomic) int uid;
@property (nonatomic) BOOL isOn;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *offColor;
@property (nonatomic, strong) UIColor *onColor;

@property (nonatomic) CGFloat size;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat animDuration;

+ (kdToggle *)initWithID:(int)uid;
- (void)setOn:(BOOL)on;

@end

@protocol kdToggleDelegate <NSObject>
- (void)kdToggleWasToggled:(kdToggle *)toggle;
@end

/*
 kdToggle *toggle = [kdToggle initWithID:0];
 toggle.center = CGPointMake(50, 100);
 toggle.delegate = self;
 [self.view addSubview:toggle];
 */
