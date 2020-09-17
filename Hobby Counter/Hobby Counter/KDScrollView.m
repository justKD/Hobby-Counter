//
//  KDScrollView.m
//
//  Created by Cady Holmes on 2/7/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDScrollView.h"

@implementation KDScrollView

+ (KDScrollView *)initWithID:(int)uid {
    
    KDScrollView *scrollView = [[KDScrollView alloc] init];
    scrollView.uid = uid;
    
    return scrollView;
}

+ (KDScrollView *)initWithID:(int)uid andFrame:(CGRect)rect {
    
    KDScrollView *scrollView = [[KDScrollView alloc] initWithFrame:rect];
    scrollView.uid = uid;
    
    return scrollView;
}

- (void)willMoveToSuperview:(UIView*)superview {
    [self initialize];
}

- (void)initialize {
}

- (void)appendView:(UIView*)view {
    NSArray *subviews = [NSArray arrayWithArray:self.subviews];
    if (subviews.count > 0) {
        [KDHelpers appendView:view toView:[self.subviews lastObject] withMarginY:0 andIndentX:0];

    }
    [self addSubview:view];
    [self updateContentSize];
}

- (void)updateContentSize {
    CGRect contentRect = CGRectZero;
    
    for (UIView *view in self.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    self.contentSize = contentRect.size;
}

@end
