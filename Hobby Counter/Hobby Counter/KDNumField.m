//
//  KDNumField.m
//
//  Created by Cady Holmes on 2/5/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDNumField.h"

@implementation KDNumField

///////
//delegate methods

- (void)kdNumFieldDidReturn {
    id<KDNumFieldDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(kdNumFieldDidReturn:)]) {
        [strongDelegate kdNumFieldDidReturn:self];
    } else {
        NSLog(@"%@",delegateError);
    }
}

//
///////

+ (KDNumField *)initWithID:(int)uid {
    
    KDNumField *numfield = [[KDNumField alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    numfield.uid = uid;
    
    return numfield;
}

- (void)willMoveToSuperview:(UIView*)superview {
    [self initialize];
}

- (void)initialize {
    
    delegateError = @"Remember to set the KDNumFieldDelegate you louse.";

    numPadFontSize = 30;
    
    if (!self.fontSize) {
        self.fontSize = 20;
    }
    
    [self makeTextField];
}
- (void)makeTextField {
    self.textfield = [[UITextField alloc] initWithFrame:self.bounds];
    self.textfield.delegate = self;
    self.textfield.font = [UIFont fontWithName:KDFontNormal size:self.fontSize];
    self.textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textfield.clearButtonMode = UITextFieldViewModeNever;
    self.textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textfield.borderStyle = UITextBorderStyleNone;
    self.textfield.tintColor = [UIColor blackColor];
    self.textfield.textAlignment = NSTextAlignmentCenter;
    
    UIView* dummyView = [[UIView alloc] init];
    self.textfield.inputView = dummyView;
    
    self.textfield.text = [NSString stringWithFormat:@"%d",self.value];
    
    
    if (self.hasUnderline) {
        CALayer *border = [CALayer layer];
        CGFloat borderWidth = .5;
        border.borderColor = [UIColor darkGrayColor].CGColor;
        border.frame = CGRectMake(0, VH(self)-borderWidth, VW(self), VH(self));
        border.borderWidth = borderWidth;
        [self.layer addSublayer:border];
        self.layer.masksToBounds = YES;
    }
    
    [self addSubview:self.textfield];
}
- (void)makeNumpad {
    float width = SW();
    float height = SH()/3;
    numpad = [[UIView alloc] initWithFrame:CGRectMake(0, SH(), width, height)];

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(VW(numpad), 0)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [KDColor black].CGColor;
    shapeLayer.lineWidth = .5;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [numpad.layer addSublayer:shapeLayer];
    
    float size = VH(numpad);
    UIView *pad = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    pad.center = CGPointMake(VBW(numpad)/2, VBH(numpad)/2);
    
    int count = 1;
    float padwidth = VW(pad);
    float padheight = VH(pad)/4;
    float numwidth = padwidth/3;
    for (int i = 0; i < 4; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, padheight*i, padwidth, padheight)];
        
        for (int j = 0; j < 3; j++) {
            UILabel *number = [KDHelpers makeLabelWithWidth:numwidth andHeight:padheight];
            number.font = [UIFont fontWithName:KDFontNormal size:numPadFontSize];
            if (count < 10) {
                number.text = [NSString stringWithFormat:@"%d",count];
                number.tag = count;
                [KDHelpers setOriginX:numwidth*j forView:number];
                
                [view addSubview:number];
            } else {
                if (count == 11) {
                    number.text = @"0";
                    number.tag = 0;
                    [KDHelpers setOriginX:numwidth*j forView:number];
                    
                    [view addSubview:number];
                }
            }
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNumber:)];
            [number addGestureRecognizer:tap];
            
            count++;
        }
        
        [pad addSubview:view];
    }
    
    float keywidth = numwidth*2;
    float keyFontSize = numPadFontSize*.66;
    UILabel *deletekey = [KDHelpers makeLabelWithWidth:keywidth andHeight:padheight];
    deletekey.font = [UIFont fontWithName:KDFontNormal size:keyFontSize];
    deletekey.text = @"delete";
    [KDHelpers setOriginY:VBH(numpad)-padheight forView:deletekey];
    
    UITapGestureRecognizer *tapDelete = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDelete:)];
    [deletekey addGestureRecognizer:tapDelete];
    
    UILabel *returnkey = [KDHelpers makeLabelWithWidth:keywidth andHeight:padheight];
    returnkey.font = [UIFont fontWithName:KDFontNormal size:keyFontSize];
    returnkey.text = @"return";
    [KDHelpers setOriginX:VBW(numpad)-keywidth andY:VBH(numpad)-padheight forView:returnkey];
    
    UITapGestureRecognizer *tapReturn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReturn:)];
    [returnkey addGestureRecognizer:tapReturn];
    
    
    float space = (VW(numpad)-VW(pad))/2;
    UILabel *negativekey = [KDHelpers makeLabelWithWidth:space andHeight:padheight];
    if (isNegative) {
        negativekey.font = [UIFont fontWithName:KDFontBold size:numPadFontSize];
    } else {
        negativekey.font = [UIFont fontWithName:KDFontNormal size:numPadFontSize];
    }
    negativekey.text = @"+/-";
    
    UITapGestureRecognizer *tapNegative = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNegative:)];
    [negativekey addGestureRecognizer:tapNegative];
    
    UILabel *closekey = [KDHelpers makeLabelWithWidth:space andHeight:padheight];
    closekey.font = [UIFont fontWithName:KDFontNormal size:keyFontSize];
    closekey.text = @"cancel";
    [KDHelpers setOriginX:VW(numpad)-space forView:closekey];
    
    UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClose:)];
    [closekey addGestureRecognizer:tapClose];

    
    numpad.backgroundColor = [UIColor whiteColor];
    [numpad addSubview:pad];
    [numpad addSubview:deletekey];
    [numpad addSubview:returnkey];
    [numpad addSubview:negativekey];
    [numpad addSubview:closekey];
}

- (void)tapNumber:(UITapGestureRecognizer*)sender {
    NSString *string = [NSString stringWithFormat:@"%@%d",self.textfield.text,(int)sender.view.tag];
    self.textfield.text = string;
    
    [KDAnimations jiggle:sender.view amount:1.2 then:nil];
}
- (void)tapDelete:(UITapGestureRecognizer*)sender {
    NSString *string = self.textfield.text;
    if (string.length > 0) {
        string = [string substringToIndex:[string length]-1];
        self.textfield.text = string;
    }

    [KDAnimations jiggle:sender.view amount:1.2 then:nil];
}
- (void)tapReturn:(UITapGestureRecognizer*)sender {
    if (self.textfield.text.length > 0) {
        int val = [self.textfield.text intValue];
        if (isNegative) {
            val = 0 - val;
        }
        self.value = val;
    }
    
    [KDAnimations jiggle:self.textfield];
    [KDAnimations jiggle:sender.view amount:1.2 then:nil];
    [self.textfield resignFirstResponder];
    [self kdNumFieldDidReturn];
}
- (void)tapClose:(UITapGestureRecognizer*)sender {
    [self closeNumpad];
    
    [KDAnimations jiggle:self.textfield];
    [KDAnimations jiggle:sender.view amount:1.2 then:nil];
    [self.textfield resignFirstResponder];
}
- (void)tapNegative:(UITapGestureRecognizer*)sender {
    isNegative = !isNegative;
    
    UILabel *label = (UILabel*)sender.view;
    if (isNegative) {
        label.font = [UIFont fontWithName:KDFontBold size:numPadFontSize];
    } else {
        label.font = [UIFont fontWithName:KDFontNormal size:numPadFontSize];
    }
    
    
    [KDAnimations jiggle:self.textfield];
    [KDAnimations jiggle:sender.view amount:1.2 then:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    [self makeNumpad];
    [[KDHelpers currentTopViewController].view addSubview:numpad];
    [KDAnimations slide:numpad amountX:0 amountY:-VH(numpad) duration:.3 then:nil];

    textField.text = @"";
    textField.placeholder = [NSString stringWithFormat:@"%d",self.value];
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self closeNumpad];
}

- (void)closeNumpad {
    self.textfield.text = [NSString stringWithFormat:@"%d",self.value];
    [KDAnimations slide:numpad amountX:0 amountY:VH(numpad) duration:.3 then:^{
        [numpad removeFromSuperview];
        numpad = nil;
    }];
}

@end
