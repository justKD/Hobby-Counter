//
//  KDActivityIndicator.h
//
//  Created by Cady Holmes on 2/21/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"
#import "KDAnimations.h"

@interface KDActivityIndicator : UIView {
    NSArray *dots;
}

@property (nonatomic) UIColor *bannerColor;
@property (nonatomic) UIColor *dotColor;

+ (KDActivityIndicator*)makeAndShowThen:(void(^)(void))callback;
- (void)showThen:(void(^)(void))callback;
- (void)hideThen:(void(^)(void))callback;

@end
