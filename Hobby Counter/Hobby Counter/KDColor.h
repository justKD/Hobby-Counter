//
//  KDColor.h
//
//  Created by Cady Holmes on 2/5/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromHex(hexvalue_replace_hash_with_0x) [UIColor colorWithRed:((float)((hexvalue_replace_hash_with_0x & 0xFF0000) >> 16))/255.0 \
green:((float)((hexvalue_replace_hash_with_0x & 0xFF00) >> 8))/255.0 \
blue:((float)(hexvalue_replace_hash_with_0x & 0xFF))/255.0 \
alpha:1.0]

@interface KDColor : NSObject

+ (NSArray*)kdColorsSimple;

+ (UIColor*)red;
+ (UIColor*)lightRed;
+ (UIColor*)blue;
+ (UIColor*)lightBlue;
+ (UIColor*)cyan;
+ (UIColor*)lightCyan;
+ (UIColor*)green;
+ (UIColor*)lightGreen;
+ (UIColor*)orange;
+ (UIColor*)yellow;
+ (UIColor*)purple;
+ (UIColor*)darkPurple;
+ (UIColor*)pink;
+ (UIColor*)lightPink;
+ (UIColor*)gray;
+ (UIColor*)lightGray;
+ (UIColor*)darkGray;
+ (UIColor*)black;
+ (UIColor*)jade;
+ (UIColor*)darkJade;


@end
