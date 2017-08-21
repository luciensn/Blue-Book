//
//  FaceCell.m
//
//  Created by Scott Lucien on 5/31/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "FaceCell.h"
#import "CustomCollectionView.h"

@implementation FaceCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    [self setExclusiveTouch:YES];
    [self setMultipleTouchEnabled:NO];
}

#pragma mark - Public Methods

- (void)setUpLongPressWithTarget:(id)target action:(SEL)action
{
    _longfellowDeeds = [[UILongPressGestureRecognizer alloc] init];
    [_longfellowDeeds setNumberOfTouchesRequired:1];
    [_longfellowDeeds setCancelsTouchesInView:YES];
    [_longfellowDeeds addTarget:target action:action];
    [_longfellowDeeds setMinimumPressDuration:0.75];
    [_longfellowDeeds setDelegate:target];
    [self addGestureRecognizer:_longfellowDeeds];
}

- (void)hideEverything
{
    [_faceImage setHidden:YES];
    [_nameLabel setHidden:YES];
}

- (void)showEverything
{
    [_faceImage setHidden:NO];
    [_faceImage setAlpha:1.0];
    [_nameLabel setHidden:NO];
}

- (void)setEditingMode:(BOOL)editingMode
{
    (editingMode) ? [self startEditingMode] : [self stopEditingMode];
}

- (void)startShaking
{
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    float startAngle = (-1.75) * M_PI/180.0;
    float stopAngle = -startAngle;
    quiverAnim.fromValue = [NSNumber numberWithFloat:startAngle];
    quiverAnim.toValue = [NSNumber numberWithFloat:3 * stopAngle];
    quiverAnim.autoreverses = YES;
    quiverAnim.duration = 0.15;
    quiverAnim.repeatCount = HUGE_VALF;
    float timeOffset = (float)(arc4random() % 150)/150 - 0.50;
    quiverAnim.timeOffset = timeOffset;
    [self.layer addAnimation:quiverAnim forKey:@"shaking"];
}

- (void)stopShaking
{
    [self.layer removeAnimationForKey:@"shaking"];
}

#pragma mark - Private Methods

- (void)startEditingMode
{
    [self startShaking];
    [_longfellowDeeds setMinimumPressDuration:0.08];
}

- (void)stopEditingMode
{
    [self stopShaking];
    [_longfellowDeeds setMinimumPressDuration:0.75];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        [_faceImage setAlpha:0.5];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            [_faceImage setAlpha:1.0];
        }];
    }
}

@end
