//
//  UIView+FindSubviews.m
//
//  Created by Scott Lucien on 4/3/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "UIView+FindSubviews.h"

@implementation UIView (FindSubviews)

- (void)printAllSubviews
{
    for (UIView *subview in self.subviews) {
        NSLog(@"%@: %@", self.class, subview.class);
        [subview printAllSubviews];
    }
}

- (UIView *)findFirstSubviewOfClass:(NSString *)className
{
    Class clazz = NSClassFromString(className);
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:clazz]) {
            return subview;
        }
        UIView *foundSubview = [subview findFirstSubviewOfClass:className];
        if (foundSubview) {
            return foundSubview;
        }
    }
    return nil;
}


@end
