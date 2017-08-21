//
//  UIBarButtonItem+ButtonItems.h
//
//  Created by Scott Lucien on 10/3/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UIBarButtonItem (ButtonItems)

#pragma mark - System Buttons

+ (UIBarButtonItem *)doneButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)addButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)cancelButtonWithTarget:(id)target action:(SEL)action;

#pragma mark - Custom Buttons

+ (UIBarButtonItem *)backButton;

+ (UIBarButtonItem *)listButtonWithTarget:(id)target action:(SEL)action;

#pragma mark - Edit Mode Controls

+ (UIButton *)editModeHelpButtonWithTarget:(id)target action:(SEL)action;

+ (UIButton *)editModeDoneButtonWithTarget:(id)target action:(SEL)action;

+ (UILabel *)editModeLabel;

@end
