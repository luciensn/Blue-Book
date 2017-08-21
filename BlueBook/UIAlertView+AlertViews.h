//
//  UIAlertView+AlertViews.h
//
//  Created by Scott Lucien on 10/3/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UIAlertView (AlertViews)

#pragma mark - Alert Views

+ (UIAlertView *)usernamePromptWithDelegate:(id<UIAlertViewDelegate>)delegate;

+ (UIAlertView *)twitterErrorForUserName:(NSString *)username;

+ (UIAlertView *)coreDataError;

+ (UIAlertView *)sendFeedbackToAddress:(NSString *)address delegate:(id<UIAlertViewDelegate>)delegate;

#pragma mark - Action Sheets

+ (UIActionSheet *)removeCellPromptWithDelegate:(id<UIActionSheetDelegate>)delegate name:(NSString *)name;

+ (UIActionSheet *)removeAllShortcutsPromptWithDelegate:(id<UIActionSheetDelegate>)delegate;

+ (UIActionSheet *)optionsForTag:(NSInteger)tag delegate:(id<UIActionSheetDelegate>)delegate;

@end
