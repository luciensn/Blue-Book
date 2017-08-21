//
//  HelpViewController.m
//
//  Created by Scott Lucien on 9/15/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import MessageUI;

#import "HelpViewController.h"
#import "AboutViewController.h"
#import "UIBarButtonItem+ButtonItems.h"
#import "UIAlertView+AlertViews.h"
#import "UIColor+Theme.h"

@interface HelpViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Properties
@property (strong, nonatomic) NSDictionary *infoDictionary;

@end

#pragma mark -

@implementation HelpViewController

- (id)initWithDelegate:(id<HelpViewControllerDelegate>)delegate
{
    NSString *nibName = @"GroupedTableViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        [self setDelegate:delegate];
    }
    return self;
}

#pragma mark - View Cycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    // set up the navigation items
    [self.navigationItem setTitle:NSLocalizedString(@"Options", nil)];
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem doneButtonWithTarget:self action:@selector(dismiss:)]];
    
    // set up the table view
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [_tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    // get the info from application bundle
    NSString *infoFilePath = [[NSBundle mainBundle] pathForResource:@"About" ofType:@"plist"];
    _infoDictionary = [NSDictionary dictionaryWithContentsOfFile:infoFilePath];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self deselectTableViewRow:YES];
}

#pragma mark - UITableView Data Source

static NSString *CellIdentifier = @"Cell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return UITableViewAutomaticDimension;
    }
    return 24;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return NSLocalizedString(@"This app cannot delete your contacts or modify your Favorites. Removing a shortcut will not delete that contact or remove it from the Favorites list on your device.", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) {
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        cell.textLabel.text = NSLocalizedString(@"About", nil);
    }
    
    else if (indexPath.section == 1) {
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.textLabel setTextColor:self.navigationController.navigationBar.tintColor];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Share This App", nil);
        }
        
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"View On The App Store", nil);
        }
    }
    
    else if (indexPath.section == 2) {
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setTextColor:[UIColor redColor]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        cell.textLabel.text = NSLocalizedString(@"Remove All Shortcuts", nil);
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self viewAboutScreen];
    }
    
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self shareThisApp];
        }
        
        else if (indexPath.row == 1) {
            [self writeAReview];
        }
    }
    
    else if (indexPath.section == 2) {
        [self removeAllContacts];
    }
}

- (void)deselectTableViewRow:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
}

#pragma mark - Actions

- (void)dismiss:(id)sender
{
    [self.delegate helpViewControllerDidDismiss:self];
}

- (void)viewAboutScreen
{
    AboutViewController *about = [[AboutViewController alloc] initWithInfo:_infoDictionary];
    [self.navigationController pushViewController:about animated:YES];
}

/*
- (void)sendFeedback
{
    NSString *email = [_infoDictionary objectForKey:@"EMAIL"];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *newMail = [[MFMailComposeViewController alloc] init];
        [newMail setToRecipients:@[email]];
        NSString *appName = [_infoDictionary objectForKey:@"APPSTORE_NAME"];
        NSString *subject = [NSString stringWithFormat:@"Feedback : %@", appName];
        [newMail setSubject:subject];
        [newMail setMailComposeDelegate:self];
        [self presentViewController:newMail animated:YES completion:nil];
    }
    else {
        UIAlertView *message = [UIAlertView sendFeedbackToAddress:email delegate:self];
        [message show];
    }
}
*/

- (void)shareThisApp
{
    NSString *message = [self getShareMessage];
    NSArray *items = @[message];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [activity setExcludedActivityTypes:@[UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]];
    NSString *mailSubject = NSLocalizedString(@"Check out this app!", nil);
    [activity setValue:mailSubject forKey:@"subject"];
    [self presentViewController:activity animated:YES completion:nil];
    [self deselectTableViewRow:YES];
}
    
- (void)writeAReview
{
    NSString *url = [_infoDictionary objectForKey:@"APPSTORE_URL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    [self deselectTableViewRow:YES];
}

- (void)removeAllContacts
{
    UIActionSheet *confirm = [UIAlertView removeAllShortcutsPromptWithDelegate:self];
    [confirm showInView:self.view];
}

#pragma mark - MailComposeViewController Delegate

- (NSString *)getShareMessage
{
    NSString *appName = [_infoDictionary objectForKey:@"APPSTORE_NAME"];
    NSString *url = [_infoDictionary objectForKey:@"SHORT_URL"];
    return [NSString stringWithFormat:@"%@ : %@", appName, url];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self deselectTableViewRow:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self deselectTableViewRow:YES];
    if (buttonIndex == 0) {
        [self.delegate helpViewControllerDidDeleteAllContacts:self];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self deselectTableViewRow:YES];
}

@end
