//
//  UIBarButtonItem+ButtonItems.m
//
//  Created by Scott Lucien on 10/3/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "UIBarButtonItem+ButtonItems.h"
#import "AppDelegate.h"
#import "UIColor+Theme.h"

@implementation UIBarButtonItem (ButtonItems)

#pragma mark - System Buttons

+ (UIBarButtonItem *)doneButtonWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
}

+ (UIBarButtonItem *)addButtonWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:target action:action];
}

+ (UIBarButtonItem *)cancelButtonWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:target action:action];
}

#pragma mark - Custom Buttons

+ (UIBarButtonItem *)backButton
{
    NSString *title = NSLocalizedString(@"Back", nil);
    return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:nil action:nil];
}

+ (UIBarButtonItem *)listButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *img = [[UIImage imageNamed:@"menu_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleBordered target:target action:action];
}

#pragma mark - Edit Mode Controls

+ (UIButton *)editModeHelpButtonWithTarget:(id)target action:(SEL)action
{
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [helpButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [helpButton setBackgroundColor:[UIColor clearColor]];
    [helpButton setImageEdgeInsets:UIEdgeInsetsMake(0, -42, 0, 0)];
    [helpButton setFrame:CGRectMake(0, 20, 96, 44)];
    return helpButton;
}

+ (UIButton *)editModeDoneButtonWithTarget:(id)target action:(SEL)action
{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.f]];
    [doneButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [doneButton setTitleEdgeInsets:UIEdgeInsetsMake(2, 21, 0, 0)];
    [doneButton setBackgroundColor:[UIColor clearColor]];
    [doneButton setFrame:CGRectMake((width - 80), 20, 80, 44)];
    return doneButton;
}

+ (UILabel *)editModeLabel
{
    UILabel *label = [[UILabel alloc] init];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont boldSystemFontOfSize:17.f]];
    [label setText:NSLocalizedString(@"Edit", nil)];
    [label setTextAlignment:NSTextAlignmentCenter];
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect labelFrame = CGRectMake((width / 2) - 50, 20, 100, 44);
    [label setFrame:labelFrame];
    return label;
}

@end
