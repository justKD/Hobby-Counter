//
//  KDColor.m
//
//  Created by Cady Holmes on 2/5/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import "KDColor.h"

@implementation KDColor

+ (NSArray*)kdColorsSimple {
    NSArray *arr = @[
                     [KDColor black],
                     [KDColor red],
                     [KDColor blue],
                     [KDColor green],
                     [KDColor purple],
                     [KDColor orange],
                     [KDColor cyan],
                     [KDColor yellow],
                     [KDColor pink]
                     ];
    
    return arr;
}

+ (UIColor*)red {
    //rgba(238, 82, 83, 1.0)
    //#ee5253
    CGFloat r = 238/255.0;
    CGFloat g = 82/255.0;
    CGFloat b = 83/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)lightRed {
    //rgba(255, 107, 107, 1.0)
    //#ff6b6b
    CGFloat r = 255/255.0;
    CGFloat g = 107/255.0;
    CGFloat b = 107/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)blue {
    //rgba(46, 134, 222, 1.0)
    //#2e86de
    CGFloat r = 46/255.0;
    CGFloat g = 134/255.0;
    CGFloat b = 222/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)lightBlue {
    //rgba(84, 160, 255, 1.0)
    //#54a0ff
    CGFloat r = 84/255.0;
    CGFloat g = 160/255.0;
    CGFloat b = 255/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)cyan {
    //rgba(10, 189, 227, 1.0)
    //#0abde3
    CGFloat r = 10/255.0;
    CGFloat g = 189/255.0;
    CGFloat b = 227/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)lightCyan {
    //rgba(72, 219, 251, 1.0)
    //#48dbfb
    CGFloat r = 79/255.0;
    CGFloat g = 219/255.0;
    CGFloat b = 251/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)green {
    //rgba(16, 172, 132, 1.0)
    //#10ac84
    CGFloat r = 16/255.0;
    CGFloat g = 172/255.0;
    CGFloat b = 132/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)lightGreen {
    //rgba(29, 209, 161, 1.0)
    //#1dd1a1
    CGFloat r = 29/255.0;
    CGFloat g = 209/255.0;
    CGFloat b = 161/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)orange {
    //rgba(255, 159, 67, 1.0)
    //#ff9f43
    CGFloat r = 255/255.0;
    CGFloat g = 159/255.0;
    CGFloat b = 67/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)yellow {
    //rgba(254, 202, 87, 1.0)
    //#feca57
    CGFloat r = 254/255.0;
    CGFloat g = 202/255.0;
    CGFloat b = 87/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)purple {
    //rgba(95, 39, 205, 1.0)
    //#5f27cd
    CGFloat r = 95/255.0;
    CGFloat g = 39/255.0;
    CGFloat b = 205/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)darkPurple {
    //rgba(52, 31, 151, 1.0)
    //#341f97
    CGFloat r = 52/255.0;
    CGFloat g = 31/255.0;
    CGFloat b = 151/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)pink {
    //rgba(243, 104, 224, 1.0)
    //#f368e0
    CGFloat r = 243/255.0;
    CGFloat g = 104/255.0;
    CGFloat b = 224/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)lightPink {
    //rgba(255, 159, 243, 1.0)
    //#ff9ff3
    CGFloat r = 255/255.0;
    CGFloat g = 159/255.0;
    CGFloat b = 243/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)gray {
    //rgba(131, 149, 167, 1.0)
    //#8395a7
    CGFloat r = 131/255.0;
    CGFloat g = 149/255.0;
    CGFloat b = 167/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)lightGray {
    //rgba(200, 214, 229, 1.0)
    //#c8d6e5
    CGFloat r = 200/255.0;
    CGFloat g = 214/255.0;
    CGFloat b = 229/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)darkGray {
    //rgba(87, 101, 116, 1.0)
    //#576574
    CGFloat r = 87/255.0;
    CGFloat g = 101/255.0;
    CGFloat b = 116/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)black {
    //rgba(34, 47, 62, 1.0)
    //#222f3e
    CGFloat r = 34/255.0;
    CGFloat g = 47/255.0;
    CGFloat b = 62/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)jade {
    //rgba(0, 210, 211, 1.0)
    //#00d2d3
    CGFloat r = 0/255.0;
    CGFloat g = 210/255.0;
    CGFloat b = 211/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}
+ (UIColor*)darkJade {
    //rgba(1, 163, 164, 1.0)
    //#01a3a4
    CGFloat r = 1/255.0;
    CGFloat g = 163/255.0;
    CGFloat b = 164/255.0;
    CGFloat a = 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return color;
}

@end
