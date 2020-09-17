//
//  KDTextField.h
//
//  Created by Cady Holmes on 2/4/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"
#import "KDAnimations.h"
#import "KDColor.h"

@interface KDTextField : UITextField

@property (nonatomic) int uid;
@property (nonatomic) float fontSize;
@property (nonatomic) float width;
@property (nonatomic) BOOL hasUnderline;

+ (KDTextField *)initWithID:(int)uid;

@end
