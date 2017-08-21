//
//  BasePeoplePickerNavigationController.m
//
//  Created by Scott Lucien on 4/2/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "BasePeoplePickerNavigationController.h"
#import "CollectionViewController.h"
#import "OptionsViewController.h"
#import "CoreDataManager.h"
#import "UIBarButtonItem+ButtonItems.h"

#define ALL_CONTACTS_LIST 99

@interface BasePeoplePickerNavigationController () <UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, ABNewPersonViewControllerDelegate>

// Properties
@property (strong, nonatomic) CollectionViewController *collectionViewController;
@property (strong, nonatomic) ABPersonViewController *personViewController;
@property (strong, nonatomic) UIViewController *listViewController;
@property (strong, nonatomic) UIBarButtonItem *addContactButton;

@end

#pragma mark -

@implementation BasePeoplePickerNavigationController

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadTheAddressBook];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)setup
{
    [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self setDelegate:self];
    [self setShouldRefresh:NO];
    
    // get the list view controller
    
    //NSLog(@"%@", self.viewControllers);
    
    //_listViewController = [self.viewControllers objectAtIndex:0];
    [_listViewController.view setTag:ALL_CONTACTS_LIST];
    
    // add contact button
    _addContactButton = [UIBarButtonItem addButtonWithTarget:self action:@selector(addNewContact:)];
    
    // set up the collection view controller
    _collectionViewController = [[CollectionViewController alloc] init];
    [self setViewControllers:@[_collectionViewController]];
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateListViewNavigationButtons)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateListViewNavigationButtons)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)needsRefresh
{
    [self setShouldRefresh:YES];
}

- (void)refreshContactsList
{
    if (_shouldRefresh) {
        SEL selector = NSSelectorFromString(@"personWasDeleted");
        for (UIViewController *vc in self.viewControllers) {
            if ([vc respondsToSelector:selector]) {
                IMP imp = [vc methodForSelector:selector];
                void (*func)(id, SEL) = (void *)imp;
                func(vc, selector);
                
                [self setShouldRefresh:NO];
            }
        }
    }
}

- (void)updateListViewNavigationButtons
{
    [_listViewController.navigationItem setRightBarButtonItem:_addContactButton];
    [_listViewController.navigationItem setLeftBarButtonItem:nil];
    [_listViewController.navigationItem setHidesBackButton:NO];
}

- (void)loadTheAddressBook
{
    // load the address book once to prevent any sluggishness
    dispatch_queue_t loadingQueue = dispatch_queue_create("Load Address Book", NULL);
    dispatch_async(loadingQueue, ^{
        ABPersonViewController *temporary = [[ABPersonViewController alloc] init];
        [temporary setAddressBook:self.addressBook];
        temporary = nil;
    });
}

#pragma mark - Collection View Actions

- (void)showContactsList:(id)sender
{
    NSLog(@"%@", self.viewControllers);
    
    [self pushViewController:_listViewController animated:YES];
}

- (void)addNewShortcut:(id)sender
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    [peoplePicker.topViewController setTitle:NSLocalizedString(@"New Shortcut", nil)];
    [peoplePicker.topViewController.navigationItem setBackBarButtonItem:[UIBarButtonItem backButton]];
    [peoplePicker setPeoplePickerDelegate:self];
    [peoplePicker setAddressBook:self.addressBook];
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

#pragma mark - Contacts List Actions

- (void)pushPersonViewControllerWithPerson:(ABRecordRef)person
{
    [self setPersonViewController:nil];
    _personViewController = [[ABPersonViewController alloc] init];
    [_personViewController setPersonViewDelegate:self];
    [_personViewController setAddressBook:self.addressBook];
    [_personViewController setDisplayedPerson:person];
    [_personViewController setAllowsEditing:YES];
    [_personViewController setAllowsActions:YES];
    [self pushViewController:_personViewController animated:YES];
}

- (void)addNewContact:(id)sender
{
    ABNewPersonViewController *newPersonVC = [[ABNewPersonViewController alloc] init];
    [newPersonVC setAddressBook:self.addressBook];
    [newPersonVC setNewPersonViewDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:newPersonVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UINavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // all contacts list
    if (viewController.view.tag == ALL_CONTACTS_LIST) {
        [self refreshContactsList];
        [self updateListViewNavigationButtons];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    return;
}

#pragma mark - ABPersonViewController Delegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

#pragma mark - ABPeoplePickerNavigationController Delegate (Add Shortcut)

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    CollectionViewController *collectionVC = (CollectionViewController *)[self.viewControllers objectAtIndex:0];
    OptionsViewController *optionsVC = [[OptionsViewController alloc] initWithDelegate:collectionVC];
    
    NSString *title = CFBridgingRelease(ABRecordCopyCompositeName(person));
    NSInteger page = [[CoreDataManager sharedManager] getFirstAvailablePage];
    NSInteger row = [[CoreDataManager sharedManager] getFirstAvailableRowOnPage:page];
    
    [optionsVC.navigationItem setTitle:title];
    [optionsVC setSelectedPerson:person];
    [optionsVC setPage:page];
    [optionsVC setRow:row];
    
    [peoplePicker pushViewController:optionsVC animated:YES];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ABNewPersonViewController Delegate (Add Contact)

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [self setShouldRefresh:YES];
    [self refreshContactsList];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//// ABPersonViewController - Force refresh of tableView after editing
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//    [super setEditing:editing animated:animated];
//    if (editing == NO) {
//        //BasePeoplePickerNavigationController *nav = (BasePeoplePickerNavigationController *)self.navigationController;
//        //[nav setShouldRefresh:YES];
//        //[[NSNotificationCenter defaultCenter] postNotificationName:@"needsRefresh" object:nil];
//        NSLog(@"Done editing");
//    }
//}

@end
