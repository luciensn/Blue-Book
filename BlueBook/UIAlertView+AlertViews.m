//
//  UIAlertView+AlertViews.m
//
//  Created by Scott Lucien on 10/3/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "UIAlertView+AlertViews.h"

@implementation UIAlertView (AlertViews)

#pragma mark - Alert Views

+ (UIAlertView *)usernamePromptWithDelegate:(id<UIAlertViewDelegate>)delegate
{
    NSString *title = NSLocalizedString(@"Twitter Photo", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *download = NSLocalizedString(@"Download", nil);
    NSString *username = NSLocalizedString(@"Username", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:nil
                                                   delegate:delegate
                                          cancelButtonTitle:cancel
                                          otherButtonTitles:download, nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setPlaceholder:username];
    return alert;
}

+ (UIAlertView *)twitterErrorForUserName:(NSString *)username
{
    NSString *title = NSLocalizedString(@"Couldn't Download Photo", nil);
    NSString *message = NSLocalizedString(@"There was an error downloading the Twitter photo for ", nil);
    NSString *combined = [NSString stringWithFormat:@"%@%@.", message, username];
    NSString *ok = NSLocalizedString(@"OK", nil);
    return [[UIAlertView alloc] initWithTitle:title
                                      message:combined
                                     delegate:nil
                            cancelButtonTitle:ok
                            otherButtonTitles:nil];
}

+ (UIAlertView *)coreDataError
{
    NSString *title = NSLocalizedString(@"Uh-Oh!", nil);
    NSString *message = NSLocalizedString(@"Something went wrong... please try again. If this problem persists, try quitting and restarting the app or contact us for help.", nil);
    NSString *ok = NSLocalizedString(@"OK", nil);
    return [[UIAlertView alloc] initWithTitle:title
                                      message:message
                                     delegate:nil
                            cancelButtonTitle:ok
                            otherButtonTitles:nil];
}

+ (UIAlertView *)sendFeedbackToAddress:(NSString *)address delegate:(id<UIAlertViewDelegate>)delegate
{
    NSString *title = NSLocalizedString(@"Feedback", nil);
    NSString *message = NSLocalizedString(@"Send feedback to", nil);
    NSString *combined = [NSString stringWithFormat:@"%@\n%@", message, address];
    NSString *ok = NSLocalizedString(@"OK", nil);
    return [[UIAlertView alloc] initWithTitle:title
                                      message:combined
                                     delegate:delegate
                            cancelButtonTitle:ok
                            otherButtonTitles:nil];
}

#pragma mark - Action Sheets

+ (UIActionSheet *)removeCellPromptWithDelegate:(id<UIActionSheetDelegate>)delegate name:(NSString *)name
{
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *remove = NSLocalizedString(@"Remove", nil);
    NSString *edit = NSLocalizedString(@"Edit", nil);
    NSString *removeMessage = [NSString stringWithFormat:@"%@ %@", remove, name];
    NSString *editMessage = [NSString stringWithFormat:@"%@ %@", edit, name];
    return [[UIActionSheet alloc] initWithTitle:nil
                                       delegate:delegate
                              cancelButtonTitle:cancel
                         destructiveButtonTitle:removeMessage
                              otherButtonTitles:editMessage, nil];
}

+ (UIActionSheet *)removeAllShortcutsPromptWithDelegate:(id<UIActionSheetDelegate>)delegate
{
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *remove = NSLocalizedString(@"Remove All Shortcuts", nil);
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:delegate
                                                cancelButtonTitle:cancel
                                           destructiveButtonTitle:remove
                                                otherButtonTitles:nil];
    return confirm;
}

+ (UIActionSheet *)optionsForTag:(NSInteger)tag delegate:(id<UIActionSheetDelegate>)delegate
{
    NSString *clearPhoto = NSLocalizedString(@"Remove Photo", nil);
    NSString *addressBook = NSLocalizedString(@"Use Address Book Photo", nil);
    NSString *existingPhoto = NSLocalizedString(@"Choose Existing Photo", nil);
    NSString *takePhoto = NSLocalizedString(@"Take New Photo", nil);
    NSString *twitterPhoto = NSLocalizedString(@"Download Twitter Photo", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    UIActionSheet *actions;
    
    // remove photo option
    if (tag == 101) {
        actions = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:delegate
                                     cancelButtonTitle:cancel
                                destructiveButtonTitle:clearPhoto
                                     otherButtonTitles:addressBook, existingPhoto, takePhoto, twitterPhoto, nil];
        
    } else if (tag == 102) {
        actions = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:delegate
                                     cancelButtonTitle:cancel
                                destructiveButtonTitle:clearPhoto
                                     otherButtonTitles:addressBook, existingPhoto, twitterPhoto, nil];
    } else if (tag == 103) {
        actions = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:delegate
                                     cancelButtonTitle:cancel
                                destructiveButtonTitle:clearPhoto
                                     otherButtonTitles:existingPhoto, takePhoto, twitterPhoto, nil];
    } else if (tag == 104) {
        actions = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:delegate
                                     cancelButtonTitle:cancel
                                destructiveButtonTitle:clearPhoto
                                     otherButtonTitles:existingPhoto, twitterPhoto, nil];
    }
    
    // disable remove photo
    else if (tag == 105) {
        actions = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:delegate
                                     cancelButtonTitle:cancel
                                destructiveButtonTitle:nil
                                     otherButtonTitles:addressBook, existingPhoto, takePhoto, twitterPhoto, nil];
    } else if (tag == 106) {
        actions = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:delegate
                                     cancelButtonTitle:cancel
                                destructiveButtonTitle:nil
                                     otherButtonTitles:addressBook, existingPhoto, twitterPhoto, nil];
    } else if (tag == 107) {
        actions = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:delegate
                                     cancelButtonTitle:cancel
                                destructiveButtonTitle:nil
                                     otherButtonTitles:existingPhoto, takePhoto, twitterPhoto, nil];
    } else if (tag == 108) {
        actions = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:delegate
                                     cancelButtonTitle:cancel
                                destructiveButtonTitle:nil
                                     otherButtonTitles:existingPhoto, twitterPhoto, nil];
    }
    [actions setTag:tag];
    return actions;
}



@end
