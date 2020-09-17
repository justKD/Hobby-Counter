//
//  KDCounter.m
//
//  Created by Cady Holmes on 2/2/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDCounterView.h"

@implementation KDCounterView

///////
//delegate methods
- (void)kdCounterHitMax {
    id<KDCounterViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdCounterHitMax:)]) {
        [strongDelegate kdCounterHitMax:self];
    } else {
        NSLog(@"%@",delegateError);
    }
}
- (void)kdCounterHitMin {
    id<KDCounterViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdCounterHitMin:)]) {
        [strongDelegate kdCounterHitMin:self];
    } else {
        NSLog(@"%@",delegateError);
    }
}
- (void)kdCounterDidWrap {
    id<KDCounterViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdCounterDidWrap:)]) {
        [strongDelegate kdCounterDidWrap:self];
    } else {
        NSLog(@"%@",delegateError);
    }
    if (self.willLink) {
        [self kdCounterDidLink];
    }
}
- (void)kdCounterWillEditTitle {
    id<KDCounterViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdCounterWillEditTitle:)]) {
        [strongDelegate kdCounterWillEditTitle:self];
    } else {
        NSLog(@"%@",delegateError);
    }
}
- (void)kdCounterDidLink {
    id<KDCounterViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdCounterDidLink:)]) {
        [strongDelegate kdCounterDidLink:self];
    } else {
        NSLog(@"%@",delegateError);
    }
}
- (void)kdCounterDeleteTapped {
    id<KDCounterViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdCounterDeleteTapped:)]) {
        [strongDelegate kdCounterDeleteTapped:self];
    } else {
        NSLog(@"%@",delegateError);
    }
}
- (void)kdCounterDidChange {
    id<KDCounterViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdCounterDidChange:)]) {
        [strongDelegate kdCounterDidChange:self];
    } else {
        NSLog(@"%@",delegateError);
    }
}
//
///////

+ (KDCounterView *)initWithID:(int)uid {
    
    float width = SW();
    float height = SH() / 4;
    
    KDCounterView *counter = [[KDCounterView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    counter.hasTopBorder = NO;
    counter.hasBottomBorder = YES;
    counter.uid = uid;
    
    return counter;
}

- (void)willMoveToSuperview:(UIView*)superview {
    self.frame = CGRectMake(OX(self), OY(self), VW(superview), VH(self));
    
    [self initialize];
}

- (void)initialize {
    
    colors = [KDColor kdColorsSimple];
    delegateError = @"Remember to set the KDCounterViewDelegate you louse.";
    
    w = VBW(self);
    h = VBH(self);
    
    fontSize = 60;
    titleFontSize = fontSize / 3;
    titleHeight = titleFontSize * 1.1;
    fadeAmount = .05;
    
    if (!self.bgColor) {
        self.bgColor = [UIColor whiteColor];
    }
    if (!self.currentCount) {
        self.currentCount = 0;
    }
    if (!self.interval) {
        self.interval = 1;
    }
    if (!self.borderColor) {
        self.borderColor = [UIColor blackColor];
    }
    if (!self.textColor) {
        self.textColor = [colors objectAtIndex:self.currentColor];
    }
    if (!self.borderLineSize) {
        self.borderLineSize = .5;
    }
    if (!self.borderLineCapStyle) {
        self.borderLineCapStyle = kCALineCapRound;
    }
    if (!self.title) {
        self.title = [NSString stringWithFormat:@"Counter %d",self.uid];
    }

    self.backgroundColor = self.bgColor;
    
    self.containerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.containerView];
    
    currentCountLabel = [KDHelpers makeLabelWithWidth:w/3 andHeight:h];
    currentCountLabel.center = CGPointMake(w/2, h/2);
    currentCountLabel.font = [UIFont fontWithName:KDFontNormal size:fontSize];
    currentCountLabel.textColor = self.textColor;
    [self updateCurrentCountLabel];
    
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerTap:)];
    twoFingerTap.numberOfTouchesRequired = 2;
    [currentCountLabel addGestureRecognizer:twoFingerTap];
    
    UITapGestureRecognizer *tapAdd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAdd:)];
    
    UITapGestureRecognizer *tapSubtract = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSubtract:)];
    
    float buttonHeight = VH(self)-titleHeight;
    UILabel *subtractLabel = [KDHelpers makeLabelWithWidth:w/3 andHeight:buttonHeight];
    subtractLabel.font = [UIFont fontWithName:KDFontNormal size:fontSize];
    subtractLabel.text = @"-";
    subtractLabel.userInteractionEnabled = YES;
    subtractLabel.alpha = fadeAmount;
    [subtractLabel addGestureRecognizer:tapSubtract];
    
    UILabel *addLabel = [KDHelpers makeLabelWithWidth:w/3 andHeight:buttonHeight];
    addLabel.font = [UIFont fontWithName:KDFontNormal size:fontSize*.65];
    addLabel.text = @"﹢";
    addLabel.userInteractionEnabled = YES;
    addLabel.alpha = fadeAmount;
    [KDHelpers setOriginX:w-VW(addLabel) forView:addLabel];
    [addLabel addGestureRecognizer:tapAdd];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRight];
    
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lp:)];
    [self addGestureRecognizer:lp];
    
    [self.containerView addSubview:currentCountLabel];
    [self.containerView addSubview:subtractLabel];
    [self.containerView addSubview:addLabel];
    
    self.layer.masksToBounds = NO;
    if (self.hasTopBorder) {
        [self addBorderWithY:0];
    }
    if (self.hasBottomBorder) {
        [self addBorderWithY:h];
    }
    
    [self makeTitleLabel];
    [self makeSubTitleLabel];
    if (!self.ignoreDeleteOption) {
        [self makeDeleteLabel];
    }
}

- (void)addBorderWithY:(float)y {
    float pad = 0;
    if (self.borderLineMargin) {
        pad = self.borderLineMargin;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(pad, y)];
    [path addLineToPoint:CGPointMake(w-pad, y)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = self.borderColor.CGColor;
    shapeLayer.lineWidth = self.borderLineSize;
    shapeLayer.lineCap = self.borderLineCapStyle;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.layer addSublayer:shapeLayer];
}

- (void)twoFingerTap:(UITapGestureRecognizer*)sender {
    if (!self.ignoreChangeColor) {
        self.currentColor++;
        self.currentColor = self.currentColor % colors.count;
        self.textColor = [colors objectAtIndex:self.currentColor];
        titleLabel.textColor = self.textColor;
        subTitleLabel.textColor = self.textColor;
        currentCountLabel.textColor = self.textColor;
        [KDAnimations jiggle:currentCountLabel];
        
        [self kdCounterDidChange];
    }
}

- (void)tapAdd:(UITapGestureRecognizer*)sender {
    if (self.countDown) {
        [self downCount];
    } else {
        [self upCount];
    }
    [self handleAnimateTapPlusMinus:sender.view];
}
- (void)tapSubtract:(UITapGestureRecognizer*)sender {
    if (self.countDown) {
        [self upCount];
    } else {
        [self downCount];
    }
    [self handleAnimateTapPlusMinus:sender.view];
}
- (void)handleAnimateTapPlusMinus:(UIView*)view {
    float fadeDur = .11;
    [KDAnimations jiggle:view];
    [KDAnimations fade:view alpha:1 duration:fadeDur then:^{
        [KDAnimations fade:view alpha:fadeAmount duration:fadeDur then:nil];
    }];
}
- (void)swipeLeft:(UISwipeGestureRecognizer*)sender {
    if (editView || settingsView) {
        [self hideSubView];
    } else {
        [self showDeleteOption];
    }
}
- (void)swipeRight:(UISwipeGestureRecognizer*)sender {
    if (deleteLabelShown) {
        [self hideDeleteOption];
    } else {
        if (editView) {
            [self hideSubView];
        }
        if (!settingsView) {
            [self showSettingsView];
        }
    }
}
- (void)lp:(UILongPressGestureRecognizer*)sender {
    if (self.hasMinCount) {
        if (self.currentCount != self.minCount) {
            [self setCountTo:self.minCount];
        }
    } else {
        if (self.currentCount != 0) {
            [self setCountTo:0];
        }
    }
}

- (void)setCountTo:(int)count {
    self.lastCount = self.currentCount;
    self.currentCount = count;
    [self updateCurrentCountLabel];
    [self kdCounterDidChange];
}
- (void)upCount {
    self.lastCount = self.currentCount;
    self.currentCount = self.currentCount + self.interval;
    if (self.hasMaxCount) {
        if (self.currentCount > self.maxCount) {
            int newCount = self.maxCount;
            if (self.hasMinCount) {
                if (self.willWrap) {
                    [self kdCounterDidWrap];
                    newCount = self.minCount;
                }
            }
            self.currentCount = newCount;
        }
        
        if (self.currentCount == self.maxCount) {
            [self kdCounterHitMax];
        }
    }
    [self updateCurrentCountLabel];
}
- (void)downCount {
    self.lastCount = self.currentCount;
    self.currentCount = self.currentCount - self.interval;
    if (self.hasMinCount) {
        if (self.currentCount < self.minCount) {
            int newCount = self.minCount;
            if (self.hasMaxCount) {
                if (self.willWrap) {
                    [self kdCounterDidWrap];
                    newCount = self.maxCount;
                }
            }
            self.currentCount = newCount;
        }
        
        if (self.currentCount == self.minCount) {
            [self kdCounterHitMin];
        }
    }
    [self updateCurrentCountLabel];
}

- (void)updateCurrentCountLabel {
    if (currentCountLabel) {
        currentCountLabel.text = [NSString stringWithFormat:@"%d",self.currentCount];
    }
    [KDAnimations jiggle:currentCountLabel];
    [self kdCounterDidChange];
}

- (void)makeTitleLabel {
    float pad = 10;

    titleLabel = [KDHelpers makeLabelWithWidth:(w/2)-pad andHeight:titleHeight];
    [KDHelpers setOriginX:pad andY:h-titleHeight-(pad/2) forView:titleLabel];
    titleLabel.font = [UIFont fontWithName:KDFontNormal size:titleFontSize];
    titleLabel.textColor = self.textColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = self.title;
    titleLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTitle:)];
    [titleLabel addGestureRecognizer:tap];

    [self.containerView addSubview:titleLabel];
}

- (void)makeSubTitleLabel {
    float pad = 10;
    
    subTitleLabel = [KDHelpers makeLabelWithWidth:(w/2)-pad andHeight:titleHeight];
    [KDHelpers setOriginX:w-VW(subTitleLabel)-pad andY:h-titleHeight-(pad/2) forView:subTitleLabel];
    subTitleLabel.font = [UIFont fontWithName:KDFontNormal size:titleFontSize*.85];
    subTitleLabel.textColor = self.textColor;
    subTitleLabel.textAlignment = NSTextAlignmentRight;
    if (self.subtitle) {
        subTitleLabel.text = self.subtitle;
    }
    subTitleLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSubTitle:)];
    [subTitleLabel addGestureRecognizer:tap];
    
    [self.containerView addSubview:subTitleLabel];
}

- (void)tapTitle:(UITapGestureRecognizer*)sender {
    [self showEditTitleDialogue:NO];
}
- (void)tapSubTitle:(UITapGestureRecognizer*)sender {
    [self showEditTitleDialogue:YES];
}
- (void)showSettingsView {
    settingsView = [self makeSubView];
    
    float pad = VW(self)/20;
    UIView *topContainer = [self makeSettingsTopContainerWithPadding:pad];
    UIView *bottomContainer = [self makeSettingsBottomContainerWithPadding:pad];
    [settingsView addSubview:topContainer];
    [settingsView addSubview:bottomContainer];
    [settingsView sendSubviewToBack:topContainer];
    [self showSubView:settingsView];
}
- (UIView*)makeSettingsBottomContainerWithPadding:(float)pad {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, VH(self)/2, VW(self), VH(self)/2)];
    NSLog(@"%d",self.maxCount);
    float width = VBW(view)/3;
    float height = VBH(view);
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    UIView *center = [[UIView alloc] initWithFrame:CGRectMake(width, 0, width, height)];
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(width*2, 0, width, height)];
    
    NSArray *containers = @[left,center,right];
    //NSArray *labels = @[@"min",@"max",@"interval"];
    int count = 0;
    for (int i = 0; i < containers.count; i++) {
        UIView *subview = [containers objectAtIndex:i];
        float margin = 14;
        float subwidth = VBW(subview);
        float subheight = (VBH(subview)/2);
        
        switch (count) {
            case 0:
                minNum = [KDNumField initWithID:count];
                minNum.frame = CGRectMake(0, 0, subwidth, subheight);
                minNum.delegate = self;
                minNum.userInteractionEnabled = NO;
                minNum.alpha = .5;
                minNum.textfield.text = 0;
                [subview addSubview:minNum];
                
                if (self.hasMinCount) {
                    minNum.userInteractionEnabled = YES;
                    [KDAnimations fade:minNum alpha:1 duration:.3 then:nil];
                } else {
                    minNum.userInteractionEnabled = NO;
                    [KDAnimations fade:minNum alpha:.5 duration:.3 then:nil];
                }
                
                minToggle = [self makeToggleWithID:0];
                [KDHelpers setWidth:subwidth-(margin) forView:minToggle];
                [KDHelpers setOriginX:margin/2 andY:subheight forView:minToggle];
                minToggle.text = @"use min";
                [minToggle setOn:self.hasMinCount];
                [subview addSubview:minToggle];
                
                if (self.hasMinCount) {
                    minNum.userInteractionEnabled = YES;
                    minNum.textfield.text = [NSString stringWithFormat:@"%d",self.minCount];
                    [KDAnimations fade:minNum alpha:1 duration:.3 then:nil];
                }
                break;
            case 1:
                maxNum = [KDNumField initWithID:count];
                maxNum.frame = CGRectMake(0, 0, subwidth, subheight);
                maxNum.delegate = self;
                maxNum.userInteractionEnabled = NO;
                maxNum.alpha = .5;
                maxNum.textfield.text = @"0";
                [subview addSubview:maxNum];
                
                maxToggle = [self makeToggleWithID:1];
                [KDHelpers setWidth:subwidth-(margin) forView:maxToggle];
                [KDHelpers setOriginX:margin/2 andY:subheight forView:maxToggle];
                maxToggle.text = @"use max";
                [maxToggle setOn:self.hasMaxCount];
                [subview addSubview:maxToggle];
                
                if (self.hasMaxCount) {
                    maxNum.userInteractionEnabled = YES;
                    maxNum.textfield.text = [NSString stringWithFormat:@"%d",self.maxCount];
                    [KDAnimations fade:maxNum alpha:1 duration:.3 then:nil];
                }
                break;
            case 2:
                linkToggle = [self makeToggleWithID:2];
                [KDHelpers setWidth:subwidth-(margin) forView:linkToggle];
                [KDHelpers setOriginX:margin/2 andY:0 forView:linkToggle];
                linkToggle.text = @"link";
                [linkToggle setOn:self.willLink];
                [subview addSubview:linkToggle];
                
                wrapToggle = [self makeToggleWithID:3];
                [KDHelpers setWidth:subwidth-(margin) forView:wrapToggle];
                [KDHelpers setOriginX:margin/2 andY:subheight forView:wrapToggle];
                wrapToggle.text = @"wrap";
                [wrapToggle setOn:self.willWrap];
                [subview addSubview:wrapToggle];
                break;
            
            default:
                break;
        }
        
        [view addSubview:subview];
        
        count++;
    }
    
    return view;
}
- (kdToggle*)makeToggleWithID:(int)uid {
    kdToggle *toggle = [kdToggle initWithID:uid];
    toggle.font = [UIFont fontWithName:KDFontNormal size:18];
    toggle.onColor = [KDColor lightGray];
    toggle.delegate = self;
    toggle.cornerRadius = 12;
    return toggle;
}
- (UIView*)makeSettingsTopContainerWithPadding:(float)pad {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VW(self), VH(self)/2)];

    // title label
    //
    float x = pad;
    float y = VBH(view)/2;
    KDTextField *titlefield = [KDTextField initWithID:self.uid];
    titlefield.width = (w/2)-(pad*2);
    [KDHelpers setOriginX:x andY:y forView:titlefield];
    titlefield.delegate = self;
    titlefield.tag = 0;
    if (![KDHelpers stringIsJustSpaces:self.title]) {
        titlefield.text = self.title;
        titlefield.placeholder = self.title;
    } else {
        titlefield.placeholder = @"title";
    }
    [view addSubview:titlefield];
    
    
    //subtitle label
    //
    x = VBW(titlefield)+(pad*3);
    KDTextField *subTitlefield = [KDTextField initWithID:self.uid];
    subTitlefield.width = (w/2)-(pad*2);
    [KDHelpers setOriginX:x andY:y forView:subTitlefield];
    subTitlefield.delegate = self;
    subTitlefield.tag = 1;
    if (![KDHelpers stringIsJustSpaces:self.subtitle]) {
        subTitlefield.text = self.subtitle;
        subTitlefield.placeholder = self.subtitle;
    } else {
        subTitlefield.placeholder = @"subtitle";
    }
    [view addSubview:subTitlefield];
    
    return view;
}


- (void)showEditTitleDialogue:(BOOL)subtitle {
    if (deleteLabelShown) {
        [self hideDeleteOption];
    }
    
    editView = [self makeSubView];
    
    float xPad = 40;
    
    KDTextField *textfield = [KDTextField initWithID:self.uid];
    textfield.width = w-(xPad*2);
    [KDHelpers setOriginX:xPad andY:(h/2)-(titleHeight/2) forView:textfield];
//    textfield.frame = CGRectMake(xPad, (h/2)-(titleHeight/2), w-(xPad*2), titleHeight);
    textfield.delegate = self;
    
    int tag = 0;
    NSString *str;
    if (subtitle) {
        tag = 1;
        if ([KDHelpers stringIsJustSpaces:self.subtitle]) {
            str = @"subtitle";
        } else {
            str = self.subtitle;
            
        }
    } else {
        if ([KDHelpers stringIsJustSpaces:self.title]) {
            str = @"title";
        } else {
            str = self.title;
        }
    }
    
    textfield.tag = tag;
    textfield.placeholder = str;

    [textfield becomeFirstResponder];

    
    [editView addSubview:textfield];
    
    [self showSubView:editView];
    [self kdCounterWillEditTitle];
}

-(UIView *)makeSubView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-VBW(self), 0, VBW(self), VBH(self))];
    view.backgroundColor = self.bgColor;
    
    float closeSize = 50;
    UILabel *close = [KDHelpers makeLabelWithWidth:closeSize andHeight:closeSize];
    [KDHelpers setOriginX:VBW(self)-closeSize forView:close];
    close.text = @"X";
    
    UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClose:)];
    [close addGestureRecognizer:tapClose];
    
    [view addSubview:close];
    
    return view;
}
- (void)showSubView:(UIView*)view {
    if (view) {
        [self addSubview:view];
        [KDAnimations slide:view amountX:VW(view) amountY:0 duration:.5 then:nil];
        [KDAnimations fade:self.containerView alpha:0 duration:.1 then:nil];
    }
}
- (void)hideSubView {
    if (editView) {
        [KDAnimations slide:editView amountX:-VW(editView) amountY:0 duration:.5 then:^{
            [editView removeFromSuperview];
            editView = nil;
        }];
        [KDAnimations fade:self.containerView alpha:1 duration:.1 then:nil];
    } else {
        if (settingsView) {
            [KDAnimations slide:settingsView amountX:-VW(settingsView) amountY:0 duration:.5 then:^{
                [settingsView removeFromSuperview];
                settingsView = nil;
            }];
            [KDAnimations fade:self.containerView alpha:1 duration:.1 then:nil];
        }
    }
}
- (void)makeDeleteLabel {
    deleteLabel = [KDHelpers makeLabelWithWidth:VW(self)/3 andHeight:VH(self)];
    [KDHelpers setOriginX:VW(self) andY:-1.5 forView:deleteLabel];
    deleteLabel.textColor = [UIColor whiteColor];
    deleteLabel.backgroundColor = [KDColor red];
    deleteLabel.text = @"delete";
    
    UITapGestureRecognizer *tapDelete = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDelete:)];
    [deleteLabel addGestureRecognizer:tapDelete];
    
    [self addSubview:deleteLabel];
}
- (void)tapDelete:(UITapGestureRecognizer*)sender {
    [self kdCounterDeleteTapped];
    [KDAnimations jiggle:sender.view];
}
- (void)showDeleteOption {
    deleteLabelShown = YES;
    [KDAnimations slide:deleteLabel amountX:-VW(deleteLabel) amountY:0 duration:.3 then:nil];
}
- (void)hideDeleteOption {
    deleteLabelShown = NO;
    [KDAnimations slide:deleteLabel amountX:VW(deleteLabel) amountY:0 duration:.3 then:nil];
}
- (void)tapClose:(UITapGestureRecognizer*)sender {
    [self hideSubView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        switch ((int)textField.tag) {
                
            case 0: // title
                self.title = textField.text;
                titleLabel.text = textField.text;
                if ([KDHelpers stringIsJustSpaces:textField.text]) {
                    textField.text = @"";
                    textField.placeholder = @"title";
                } else {
                    textField.placeholder = textField.text;
                }
                break;
                
            case 1: // subtitle
                self.subtitle = textField.text;
                subTitleLabel.text = textField.text;
                if ([KDHelpers stringIsJustSpaces:textField.text]) {
                    textField.text = @"";
                    textField.placeholder = @"subtitle";
                } else {
                    textField.placeholder = textField.text;
                }
                break;
                
            default:
                break;
        }
    }
    [self kdCounterDidChange];
    [textField resignFirstResponder];
    if (editView) {
        [self hideSubView];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = @"";
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    if (editView) {
        [self hideSubView];
    }
}

- (void)kdNumFieldDidReturn:(KDNumField *)numfield {
    NSLog(@"%d",numfield.uid);
    
    switch (numfield.uid) {
        case 0: //min
            self.minCount = [numfield.textfield.text intValue];
            if (self.hasMaxCount) {
                int checkValue = self.maxCount-1;
                if (numfield.value > checkValue) {
                    numfield.textfield.text = [NSString stringWithFormat:@"%d",checkValue];
                    numfield.value = checkValue;
                }
            }
            
            break;
            
        case 1: //max
            self.maxCount = [numfield.textfield.text intValue];
            if (self.hasMinCount) {
                int checkValue = self.minCount+1;
                if (numfield.value < checkValue) {
                    numfield.textfield.text = [NSString stringWithFormat:@"%d",checkValue];
                    numfield.value = checkValue;
                }
            }
            
            break;

            
        default:
            break;
    }
    [self kdCounterDidChange];
}

- (void)kdToggleWasToggled:(kdToggle *)toggle {
    switch (toggle.uid) {
        case 0:
            self.hasMinCount = toggle.isOn;
            if (self.hasMinCount) {
                minNum.userInteractionEnabled = YES;
                [KDAnimations fade:minNum alpha:1 duration:.3 then:nil];
                [minNum.textfield becomeFirstResponder];
            } else {
                minNum.userInteractionEnabled = NO;
                [KDAnimations fade:minNum alpha:.5 duration:.3 then:nil];
                [minNum.textfield resignFirstResponder];
            }
            break;
            
        case 1:
            self.hasMaxCount = toggle.isOn;
            if (self.hasMaxCount) {
                maxNum.userInteractionEnabled = YES;
                [KDAnimations fade:maxNum alpha:1 duration:.3 then:nil];
                [maxNum.textfield becomeFirstResponder];
            } else {
                minNum.userInteractionEnabled = NO;
                [KDAnimations fade:maxNum alpha:.5 duration:.3 then:nil];
                [maxNum.textfield resignFirstResponder];
            }
            break;
            
        case 2:
            self.willLink = toggle.isOn;
            if (self.willLink) {
                if (!self.hasMinCount) {
                    self.hasMinCount = YES;
                    [minToggle setOn:YES];
                }
                if (!self.hasMaxCount) {
                    self.hasMaxCount = YES;
                    [maxToggle setOn:YES];
                }
                if (!self.willWrap) {
                    self.willWrap = YES;
                    [wrapToggle setOn:YES];
                }
                if (self.maxCount <= self.minCount) {
                    self.maxCount = self.minCount + 1;
                    maxNum.textfield.text = [NSString stringWithFormat:@"%d",self.maxCount];
                }
                
                maxNum.userInteractionEnabled = YES;
                [KDAnimations fade:maxNum alpha:1 duration:.3 then:nil];
                minNum.userInteractionEnabled = YES;
                [KDAnimations fade:minNum alpha:1 duration:.3 then:nil];
            }
            break;
        
        case 3:
            self.willWrap = toggle.isOn;
            break;
            
        default:
            break;
    }
    [self kdCounterDidChange];
}

@end
