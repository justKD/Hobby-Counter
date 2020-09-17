//
//  KDHelpers.m
//
//  Created by Cady Holmes on 1/12/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDHelpers.h"

@implementation KDHelpers

+ (UIView *)circleWithColor:(UIColor *)color radius:(float)radius borderWidth:(float)borderWidth {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * radius, 2 * radius)];
    circle.backgroundColor = [UIColor clearColor];
    
    UIBezierPath *knobPath = [UIBezierPath bezierPath];
    [knobPath addArcWithCenter:CGPointMake(circle.bounds.size.width/2, circle.bounds.size.height/2) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [knobPath CGPath];
    layer.strokeColor = [UIColor blackColor].CGColor;
    layer.fillColor = color.CGColor;
    layer.lineWidth = borderWidth;
    layer.lineJoin = kCALineJoinBevel;
    layer.strokeEnd = 1;
    layer.drawsAsynchronously = YES;
    
    [circle.layer addSublayer:layer];
    
    return circle;
}

+ (void)wait:(double)delayInSeconds then:(void(^)(void))callback {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
        if(callback){
            callback();
        }
    });
    
    /*
     [self wait:<#(double)#> then:^{
     
     }];
     */
}

+ (void)async:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(callback){
            callback();
        }
    });
    
    /*
     [self async:^{
     
     }];
     */
}

+ (float)getPanPosition:(UIGestureRecognizer *)sender {
    float pos = [sender locationInView:sender.view].y;
    pos = 100 - ((pos/sender.view.frame.size.height) * 100);
    pos = MIN(pos, 100);
    pos = MAX(pos, 0);
    return pos;
}

+ (UIView*)popupWithClose:(BOOL)close onView:(UIView*)parent withCloseTarget:(id)target forCloseSelector:(SEL)selector withColor:(UIColor*)color withBlurAmount:(float)blur {
    
    //UIView *parent = [KDHelpers currentTopViewController].view;
    CGRect frame = parent.bounds;

    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    if (color) {
        [view setBackgroundColor:color];
    }
    
    if (blur) {
        
        [view setBackgroundColor:[UIColor clearColor]];
        
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

        visualEffectView.backgroundColor = color;

        visualEffectView.frame = view.bounds;
        visualEffectView.alpha = blur;

        [view addSubview:visualEffectView];
    }
    
    if (close) {
        [KDHelpers addCloseButtonToView:view actionTarget:target selector:selector];
    }
    
    return view;
}

/*  popupWithClose example use
 
 - (void)tapHelp:(UITapGestureRecognizer*)sender {
 
 UIView *help = [KDHelpers popupWithClose:YES withCloseTarget:self forCloseSelector:@selector(closeHelp:) withColor:[UIColor whiteColor] withBlurAmount:0];
 [KDAnimations animateViewGrowAndShow:help then:nil];
 [self.view addSubview:help];
 
 [KDAnimations jiggle:sender.view];
 }
 
 - (void)closeHelp:(UITapGestureRecognizer*)sender {
 [KDAnimations animateViewShrinkAndWink:sender.view.superview andRemoveFromSuperview:YES then:nil];
 }
 
*/

+ (void)addCloseButtonToView:(UIView*)view actionTarget:(id)target selector:(SEL)selector {
    
    float closeSize = 40;
    UILabel *close = [[UILabel alloc] initWithFrame:CGRectMake(VWB(view)-closeSize-20, OYB(view)+SBH(), closeSize, closeSize)];
    [close setFont:[UIFont fontWithName:KDFontNormal size:20]];
    [close setUserInteractionEnabled:YES];
    [close setText:@"X"];
    [close setTextAlignment:NSTextAlignmentCenter];
    close.backgroundColor = [UIColor whiteColor];
    close.layer.cornerRadius = 20;
    close.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [close addGestureRecognizer:tap];
    
    [view addSubview:close];
}

+ (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

+ (NSAttributedString*)underlinedString:(NSString*)string {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:string
                                                              attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
    return str;
}

+ (BOOL)headsetPluggedIn {
    // Get array of current audio outputs (there should only be one)
    NSArray *outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    
    NSString *portName = [[outputs objectAtIndex:0] portName];
    
    if ([portName isEqualToString:@"Headphones"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)iPadCheck {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        return YES;
    }
    return NO;
}
+ (BOOL)iPhoneXCheck {
    //NSLog(@"%f",[[UIScreen mainScreen] bounds].size.height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //NSLog(@"iphone");
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (screenSize.height == 812) {
            //NSLog(@"iphone x");
            return YES;
        }
    }
    return NO;
}

+ (float)getVolume {
    float vol = [[AVAudioSession sharedInstance] outputVolume];
    return vol;
}
+ (BOOL)checkVolume {
    BOOL check = YES;
    if ([KDHelpers getVolume] < .4) {
        check = NO;
    }
    return check;
}

+ (UILabel*)makeLabelWithWidth:(CGFloat)width andHeight:(CGFloat)height {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    label.preferredMaxLayoutWidth = width;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:KDFontNormal size:24];
    label.userInteractionEnabled = YES;
    
    return label;
}

+ (UILabel*)makeLabelWithWidth:(CGFloat)width andFontSize:(CGFloat)size {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, size*1.1)];
    label.preferredMaxLayoutWidth = width;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:KDFontNormal size:size];
    label.userInteractionEnabled = YES;
    
    return label;
}

+ (UILabel*)makeLabelWithWidth:(CGFloat)width andAlignment:(NSTextAlignment)align andText:(NSString*)text {
    UILabel *label = [KDHelpers makeLabelWithWidth:width andAlignment:align];
    label.text = text;
    [KDHelpers setLabelHeightFor:label fontSize:KDFontSizeNormal fontName:KDFontNormal withText:text];
    return label;
}

+ (UILabel*)makeLabelWithWidth:(CGFloat)width andAlignment:(NSTextAlignment)align {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.preferredMaxLayoutWidth = width;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.textAlignment = align;
    label.userInteractionEnabled = YES;
    return label;
}
+ (void)setFontSize:(CGFloat)size forLabel:(UILabel*)label {
    label.font = [UIFont fontWithName:label.font.fontName size:size];
    [KDHelpers setLabelHeightFor:label fontSize:size fontName:label.font.fontName withText:label.text];
}
+ (void)setLabelHeightFor:(UILabel*)label fontSize:(CGFloat)size fontName:(NSString*)fontName withText:(NSString*)text {
    float width = label.frame.size.width;
    if (!fontName) {
        fontName = @"HelveticaNeue-UltraLight";
    }
    label.font = [UIFont fontWithName:fontName size:size];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:label.font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    label.frame = rect;
    label.text = text;
    [KDHelpers setWidth:width forView:label];
}

+ (UIFont*)fontWithSize1 {
    UIFont *font = [UIFont fontWithName:KDFontNormal size:KDFontSizeNormal];
    return font;
}
+ (UIFont*)fontWithSize2 {
    UIFont *font = [UIFont fontWithName:KDFontNormal size:KDFontSizeMedium];
    return font;
}
+ (UIFont*)fontWithSize3 {
    UIFont *font = [UIFont fontWithName:KDFontNormal size:KDFontSizeLarge];
    return font;
}
+ (UIFont*)fontWithSize4 {
    UIFont *font = [UIFont fontWithName:KDFontBold size:KDFontSizeLarge];
    return font;
}

+ (void)appendView:(UIView*)view toView:(UIView*)source withMarginY:(CGFloat)y andIndentX:(CGFloat)x {
    CGRect frame = CGRectMake(source.bounds.origin.x + x,
                              source.frame.origin.y + source.frame.size.height + y,
                              view.bounds.size.width,
                              view.bounds.size.height);
    [view setFrame:frame];
}

+ (void)setOriginX:(CGFloat)x andY:(CGFloat)y forView:(UIView*)view {
    CGRect frame = CGRectMake(x, y, view.frame.size.width, view.frame.size.height);
    [view setFrame:frame];
}

+ (void)setOriginX:(CGFloat)x forView:(UIView*)view {
    CGRect frame = CGRectMake(x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    [view setFrame:frame];
}

+ (void)setOriginY:(CGFloat)y forView:(UIView*)view {
    CGRect frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
    [view setFrame:frame];
}

+ (void)setWidth:(CGFloat)w forView:(UIView*)view {
    CGRect frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, w, view.frame.size.height);
    [view setFrame:frame];
}

+ (void)setHeight:(CGFloat)h forView:(UIView*)view {
    CGRect frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, h);
    [view setFrame:frame];
}

+ (void)centerView:(UIView*)view onView:(UIView*)target {
    view.center = CGPointMake(VWB(target)/2, VHB(target)/2);
}

+ (BOOL)stringIsJustSpaces:(NSString*)str {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[str stringByTrimmingCharactersInSet:set] length] > 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (void)addGradientMaskToView:(UIView*)view {
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = view.bounds;
    gradientMask.colors = @[(id)[UIColor clearColor].CGColor,
                            (id)[UIColor whiteColor].CGColor,
                            (id)[UIColor whiteColor].CGColor,
                            (id)[UIColor clearColor].CGColor];
    gradientMask.locations = @[@0.0, @0.08, @0.92, @1.0];
    view.layer.masksToBounds = YES;
    view.layer.mask = gradientMask;
}

@end
