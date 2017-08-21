//
//  BasePeoplePickerNavigationController.h
//
//  Created by Scott Lucien on 4/2/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import AddressBookUI;

@interface BasePeoplePickerNavigationController : ABPeoplePickerNavigationController

// Properties
@property (nonatomic) BOOL shouldRefresh;

// Public Actions
- (void)showContactsList:(id)sender;
- (void)addNewShortcut:(id)sender;
- (void)pushPersonViewControllerWithPerson:(ABRecordRef)person;

@end
