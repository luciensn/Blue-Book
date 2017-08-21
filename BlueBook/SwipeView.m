//
//  SwipeView.m
//
//  Created by Scott Lucien on 9/12/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "SwipeView.h"

#define EDGE_WIDTH 12

@implementation SwipeView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (point.x < (CGRectGetWidth(self.frame) - EDGE_WIDTH)) {
        return NO;
    }
    return YES;
}

@end
