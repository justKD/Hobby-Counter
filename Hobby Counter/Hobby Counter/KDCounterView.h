//
//  KDCounterView.h
//
//  Created by Cady Holmes on 2/2/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"
#import "KDAnimations.h"
#import "KDColor.h"
#import "KDNumField.h"
#import "kdToggle.h"
#import "KDTextField.h"

@protocol KDCounterViewDelegate;

@interface KDCounterView : UIView <KDNumFieldDelegate, kdToggleDelegate, UITextFieldDelegate> {
    UILabel *currentCountLabel;
    UILabel *titleLabel;
    UILabel *subTitleLabel;
    
    float w;
    float h;
    float fontSize;
    float fadeAmount;
    
    float titleFontSize;
    float titleHeight;
    
    UIView *editView;
    UIView *settingsView;
    
    NSString *delegateError;
    
    KDNumField *minNum;
    KDNumField *maxNum;
    kdToggle *minToggle;
    kdToggle *maxToggle;
    kdToggle *wrapToggle;
    kdToggle *linkToggle;
    
    NSArray *colors;
    
    UILabel *deleteLabel;
    BOOL deleteLabelShown;
}

@property (nonatomic, weak) id<KDCounterViewDelegate> delegate;

@property (nonatomic) int uid;

@property (nonatomic) int currentCount;
@property (nonatomic) int lastCount;
@property (nonatomic) int maxCount;
@property (nonatomic) int minCount;
@property (nonatomic) BOOL hasMaxCount;
@property (nonatomic) BOOL hasMinCount;
@property (nonatomic) int interval;

@property (nonatomic) float borderLineSize;
@property (nonatomic) float borderLineMargin;

@property (nonatomic) BOOL countDown;
@property (nonatomic) BOOL hasTopBorder;
@property (nonatomic) BOOL hasBottomBorder;
@property (nonatomic) BOOL willWrap;
@property (nonatomic) BOOL willLink;

@property (nonatomic) BOOL ignoreChangeColor;
@property (nonatomic) BOOL ignoreDeleteOption;

@property (nonatomic) int currentColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, strong) NSString *borderLineCapStyle;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

@property (nonatomic, strong) UIView *containerView;

+ (KDCounterView *)initWithID:(int)uid;

- (void)upCount;
- (void)downCount;
- (void)setCountTo:(int)count;
- (void)updateCurrentCountLabel;

@end

@protocol KDCounterViewDelegate <NSObject>
- (void)kdCounterHitMax:(KDCounterView*)counter;
- (void)kdCounterHitMin:(KDCounterView*)counter;
- (void)kdCounterDidWrap:(KDCounterView*)counter;
- (void)kdCounterWillEditTitle:(KDCounterView*)counter;
- (void)kdCounterDidLink:(KDCounterView*)counter;
- (void)kdCounterDeleteTapped:(KDCounterView*)counter;
- (void)kdCounterDidChange:(KDCounterView*)counter;
@end

