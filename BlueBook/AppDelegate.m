//
//  AppDelegate.m
//
//  Created by Scott Lucien on 12/12/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import AddressBookUI;

#import "AppDelegate.h"
#import "CoreDataManager.h"
#import "TwitterManager.h"
//#import "UIColor+Theme.h"

@implementation AppDelegate

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Application Events

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // set the app tint color
    //[self.window setTintColor:[UIColor themeColor]];
    
    // disable NSURL caching
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    
    // authenticate against the Twitter API
    [TwitterManager checkForAuthentication];
    
    // set up the core data manager
    [CoreDataManager sharedManager];
    
    // load the root view controller
    _navigationController = [[BasePeoplePickerNavigationController alloc] init];
    [_navigationController setPeoplePickerDelegate:self];
    
    // initialize the window
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_window setRootViewController:_navigationController];
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self setResignTime:[NSDate date]];
    [self saveChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveChanges];
}

#pragma mark - Private Methods

- (void)saveChanges
{
    [[CoreDataManager sharedManager] saveObjectIndexPaths];
    [[CoreDataManager sharedManager] saveContext];
}

#pragma mark - ABPeoplePickerNavigationController Delegate (All Contacts List)

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [_navigationController pushPersonViewControllerWithPerson:person];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    return;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
