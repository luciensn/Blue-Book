//
//  CameraOverlayView.m
//
//  Created by Scott Lucien on 4/2/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "CameraOverlayView.h"

@implementation CameraOverlayView

- (id)init
{
    self = [super init];
    if (self) {
        [self comminInit];
    }
    return self;
}

- (void)comminInit
{
    [self setUserInteractionEnabled:NO];
    
    // add the circle camera overlay view
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width; // 320
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat overlayY = 68;
    CGFloat overlayHeight = screenHeight - overlayY - 70;
    CGFloat padding = 2;
    CGFloat diameter = screenWidth - (padding * 2);
    CGFloat circleY = 22;
    CGFloat alpha = 0.75;
    
    // iPhone 4
    if (screenHeight < 568) {
        overlayY = 40;
        overlayHeight = screenHeight - overlayY - 73;
        circleY = 6;
        alpha = 0.3;
    }
    
    CGRect frame = CGRectMake(0, overlayY, screenWidth, overlayHeight);
    [self setFrame:frame];
    
    // circle path
    UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(padding, circleY, diameter, diameter)];
    [path2 setUsesEvenOddFillRule:YES];
    
    // circle layer
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[path2 CGPath]];
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    // fill path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenWidth, overlayHeight) cornerRadius:0];
    [path setUsesEvenOddFillRule:YES];
    [path appendPath:path2];
    
    // fill layer
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = alpha;
    [self.layer addSublayer:fillLayer];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // forward all touches through (to allow for move and scale gesture)
    return NO;
}

@end
