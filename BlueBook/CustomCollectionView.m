//
//  CustomCollectionView.m
//
//  Created by Scott Lucien on 10/8/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "CustomCollectionView.h"
#import "UIColor+Theme.h"

@interface CustomCollectionView ()

// Properties
@property (strong, nonatomic) UILabel *noDataLabel;

@end

#pragma mark -

@implementation CustomCollectionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // set up the "no data" label
    CGFloat height = [[UIScreen mainScreen] bounds].size.height - 64 - 44;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect frame = CGRectMake(0, 0, width,  height);
    _noDataLabel = [[UILabel alloc] initWithFrame:frame];
    [_noDataLabel setUserInteractionEnabled:NO];
    [_noDataLabel setTextColor:[UIColor noDataLabelTextColor]];
    [_noDataLabel setBackgroundColor:[UIColor clearColor]];
    [_noDataLabel setFont:[UIFont systemFontOfSize:23.f]];
    [_noDataLabel setTextAlignment:NSTextAlignmentCenter];
    [_noDataLabel setText:NSLocalizedString(@"No Shortcuts", nil)];
    [self addSubview:_noDataLabel];
}

- (void)reloadData
{
    [super reloadData];
    [self showOrHideNoDataLabel];
}

- (void)showOrHideNoDataLabel
{
    if ([self numberOfSections] < 1) {
        [_noDataLabel setHidden:NO];
    } else {
        [_noDataLabel setHidden:YES];
    }
}

// restrict the touch events to ONE touch only
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    NSSet *set = [event touchesForWindow:self.window];
    return (set.count == 1);
}

@end
