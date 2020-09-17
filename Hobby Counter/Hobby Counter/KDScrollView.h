//
//  KDScrollView.h
//
//  Created by Cady Holmes on 2/7/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDKit.h"

@interface KDScrollView : UIScrollView

@property (nonatomic) int uid;
//@property (nonatomic) BOOL horizontal;

// add code to handle horizontal
// add code to handle paginated

+ (KDScrollView *)initWithID:(int)uid;
+ (KDScrollView *)initWithID:(int)uid andFrame:(CGRect)rect;

- (void)appendView:(UIView*)view;
- (void)updateContentSize;

@end
