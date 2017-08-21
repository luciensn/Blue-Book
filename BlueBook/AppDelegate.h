//
//  AppDelegate.h
//
//  Created by Scott Lucien on 12/12/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

#import "BasePeoplePickerNavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ABPeoplePickerNavigationControllerDelegate>

// Class Methods
+ (AppDelegate *)appDelegate;

// Properties
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BasePeoplePickerNavigationController *navigationController;
@property (strong, nonatomic) NSDate *resignTime;

// Instance Methods
- (NSURL *)applicationDocumentsDirectory;

@end
