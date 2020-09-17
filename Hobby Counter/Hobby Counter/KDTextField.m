//
//  KDTextField.m
//
//  Created by Cady Holmes on 2/4/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDTextField.h"

@implementation KDTextField

+ (KDTextField *)initWithID:(int)uid {
    KDTextField *textfield = [[KDTextField alloc] init];
    textfield.font = [UIFont fontWithName:KDFontNormal size:20];
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield.keyboardType = UIKeyboardTypeDefault;
    textfield.returnKeyType = UIReturnKeyDone;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield.borderStyle = UITextBorderStyleNone;
    textfield.tintColor = [UIColor blackColor];
    
    textfield.uid = uid;
    textfield.fontSize = 20;
    textfield.width = SW();
    
    return textfield;
}

- (void)willMoveToSuperview:(UIView*)superview {

    float x = self.frame.origin.x;
    float y = self.frame.origin.y;
    
    if (self.width == SW()) {
        if (self.frame.size.width < SW()) {
            self.width = self.frame.size.width;
        }
    }
    
    self.frame = CGRectMake(x, y, self.width, self.fontSize*1.1);
    
    if (self.hasUnderline) {
        CALayer *border = [CALayer layer];
        CGFloat borderWidth = .5;
        border.borderColor = [UIColor darkGrayColor].CGColor;
        border.frame = CGRectMake(0, VH(self)-borderWidth, VW(self), VH(self));
        border.borderWidth = borderWidth;
        [self.layer addSublayer:border];
        self.layer.masksToBounds = YES;
    }
}



//- (void)openRenameDialogueWithTag:(int)tag {
//    UIView *view = [self makeDialoguePopup];
//    float sw = view.bounds.size.width;
//    float textFieldMargin = 50;
//    float textFieldHeight = 100;
//    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(textFieldMargin, view.bounds.size.height/3, sw-textFieldMargin, textFieldHeight)];
//    textfield.font = [UIFont fontWithName:self.font size:self.fontSize*1.25];
//    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
//    textfield.keyboardType = UIKeyboardTypeDefault;
//    textfield.returnKeyType = UIReturnKeyDone;
//    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
//    textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    textfield.delegate = self;
//    textfield.borderStyle = UITextBorderStyleNone;
//    textfield.tintColor = [UIColor blackColor];
//
//    NSString *place = @"   Rename";
//    textfield.placeholder = place;
//    textfield.tag = tag;
//    [view addSubview:textfield];
//
//    [self animateViewGrowAndShow:view];
//    [self addSubview:view];
//    [textfield becomeFirstResponder];
//}

@end
