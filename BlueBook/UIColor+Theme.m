//
//  UIColor+Theme.m
//
//  Created by Scott Lucien on 9/18/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "UIColor+Theme.h"

@implementation UIColor (Theme)

+ (UIColor *)themeColor {
    return [UIColor colorWithRed:(41.0/255.0) green:(128.0/255.0) blue:(185.0/255.0) alpha:1.0]; // #2980b9
    //return [UIColor colorWithRed:(52.0/255.0) green:(73.0/255.0) blue:(94.0/255.0) alpha:1.0]; // #34495e
    //return [UIColor colorWithRed:(0.0/255.0) green:(160.0/255.0) blue:(145.0/255.0) alpha:1.0]; // #00A091
}

+ (UIColor *)noDataLabelTextColor {
    return [UIColor colorWithRed:(230.0/255.0) green:(230.0/255.0) blue:(230.0/255.0) alpha:1.0];
}

@end
