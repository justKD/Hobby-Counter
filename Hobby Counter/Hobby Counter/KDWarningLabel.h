//
//  KDWarningLabel.h
//
//  Created by Cady Holmes on 1/18/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"
#import "KDAnimations.h"

@interface KDWarningLabel : UILabel {
    BOOL showing;
}

@property (nonatomic) float flashDuration;

+ (void)flashWarningWithText:(NSString*)text;
- (id)initWithText:(NSString *)text;
- (void)flash;
- (void)flashWithString:(NSString *)string;
- (void)show;
- (void)showThen:(void(^)(void))callback;
- (void)hide;
- (void)hideThen:(void(^)(void))callback;

- (void)checkVolume;

@end
