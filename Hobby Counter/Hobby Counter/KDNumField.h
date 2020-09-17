//
//  KDNumField.h
//
//  Created by Cady Holmes on 2/5/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"
#import "KDAnimations.h"
#import "KDColor.h"

@protocol KDNumFieldDelegate;

@interface KDNumField : UIView <UITextFieldDelegate> {
    UIView *numpad;
    BOOL isNegative;
    float numPadFontSize;
    
    NSString *delegateError;
}

@property (nonatomic, weak) id<KDNumFieldDelegate> delegate;

@property (nonatomic) int uid;
@property (nonatomic, strong) UITextField *textfield;
@property (nonatomic) float fontSize;
@property (nonatomic) BOOL hasUnderline;

@property (nonatomic) int value;

+ (KDNumField *)initWithID:(int)uid;

@end

@protocol KDNumFieldDelegate <NSObject>
- (void)kdNumFieldDidReturn:(KDNumField*)numfield;

@end
