//
//  CircleImagePickerController.m
//
//  Created by Scott Lucien on 4/3/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "CircleImagePickerController.h"
#import "CameraOverlayView.h"
#import "UIView+FindSubviews.h"

@implementation CircleImagePickerController

- (id)initWithDelegate:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate
            sourceType:(UIImagePickerControllerSourceType)sourceType
{
    self = [super init];
    if (self) {
        [self setDelegate:delegate];
        [self setAllowsEditing:YES];
        [self setSourceType:sourceType];
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            CameraOverlayView *overlay = [[CameraOverlayView alloc] init];
            [self setCameraOverlayView:overlay];
        }
    }
    return self;
}

#pragma mark - UIImagePickerControllerSourceTypeCamera

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // add the dim views to the PLCropOverlayPreviewBottomBar
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIViewController *cameraViewController = (UIViewController *)self.viewControllers[0];
        UIView *previewBottomBar = [cameraViewController.view findFirstSubviewOfClass:@"PLCropOverlayPreviewBottomBar"];
        if (previewBottomBar) {
            
            CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
            CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
            
            CGRect topBarFrame = CGRectMake(0, -497.5, screenWidth, 70);
            CGRect bottomBarFrame = CGRectMake(0, 2.5, screenWidth, 70);
            
            // iPhone 4
            if (screenHeight < 568) {
                topBarFrame = CGRectMake(0, -408, screenWidth, 44);
                bottomBarFrame = CGRectMake(0, -43, screenWidth, 115);
            }
            
            UIView *topDimView = [self dimViewWithFrame:topBarFrame];
            UIView *bottomDimView = [self dimViewWithFrame:bottomBarFrame];
            [previewBottomBar addSubview:topDimView];
            [previewBottomBar sendSubviewToBack:topDimView];
            [previewBottomBar addSubview:bottomDimView];
            [previewBottomBar sendSubviewToBack:bottomDimView];
            [previewBottomBar setClipsToBounds:NO];
        }
    }
}

- (UIView *)dimViewWithFrame:(CGRect)frame
{
    UIView *dimView = [[UIView alloc] initWithFrame:frame];
    [dimView setBackgroundColor:[UIColor blackColor]];
    [dimView setAlpha:0.75];
    return dimView;
}

#pragma mark - UIImagePickerControllerSourceTypeSavedPhotosAlbum

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];

    // show the circle overlay over the image view
    // this was previously located in the navigation controller delegate -[willShowViewController:]
    if (self.sourceType != UIImagePickerControllerSourceTypeCamera) {
        if ([viewController isKindOfClass:NSClassFromString(@"PLUIImageViewController")]) {
            
            // hide the square overlay
            //UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1] subviews] objectAtIndex:0];
            UIView *plCropOverlay = [viewController.view findFirstSubviewOfClass:@"PLCropOverlayCropView"];
            [plCropOverlay setHidden:YES];
            
            CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width; // 320
            CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
            CGFloat diameter = screenWidth;
            CGFloat circleY = ((screenHeight / 2) - (diameter / 2));
            
            // circle path
            UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, circleY, diameter, diameter)];
            [path2 setUsesEvenOddFillRule:YES];
            
            // circle layer
            CAShapeLayer *circleLayer = [CAShapeLayer layer];
            [circleLayer setPath:[path2 CGPath]];
            [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
            
            // fill path
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenWidth, screenHeight - 72) cornerRadius:0];
            [path setUsesEvenOddFillRule:YES];
            [path appendPath:path2];
            
            // fill layer
            CAShapeLayer *fillLayer = [CAShapeLayer layer];
            fillLayer.path = path.CGPath;
            fillLayer.fillRule = kCAFillRuleEvenOdd;
            fillLayer.fillColor = [UIColor blackColor].CGColor;
            fillLayer.opacity = 0.75;
            [viewController.view.layer addSublayer:fillLayer];
        }
    }
}

@end
