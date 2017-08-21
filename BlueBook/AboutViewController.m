//
//  AboutViewController.m
//
//  Created by Scott Lucien on 10/10/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "AboutViewController.h"
#import "HelpViewController.h"
#import "UIBarButtonItem+ButtonItems.h"
#import "UIColor+Theme.h"

@interface AboutViewController () <UITableViewDataSource, UITableViewDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Properties
@property (strong, nonatomic) NSDictionary *infoDictionary;

@end

#pragma mark -

@implementation AboutViewController

- (id)initWithInfo:(NSDictionary *)dictionary
{
    NSString *nibName = @"GroupedTableViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        [self setInfoDictionary:dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"About", nil)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem doneButtonWithTarget:self action:@selector(donePressed:)];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

#pragma mark - UITableView Data Source

static NSString *CellIdentifier = @"AboutCell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 24;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // app name cell
    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // app icon
        CGRect frame = CGRectMake(15, 14, 60, 60);
        UIButton *icon = [UIButton buttonWithType:UIButtonTypeSystem];
        [icon setBackgroundColor:[UIColor clearColor]];
        [icon setBackgroundImage:[UIImage imageNamed:@"app-icon-about"] forState:UIControlStateNormal];
        [icon setFrame:frame];
        [icon setUserInteractionEnabled:NO];
        [cell addSubview:icon];
        
        // app name label
        CGRect nameLabelFrame = CGRectMake(90, 24, 215, 22);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
        [nameLabel setFont:[UIFont systemFontOfSize:17.f]];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setText:[_infoDictionary objectForKey:@"APPSTORE_NAME"]];
        [cell addSubview:nameLabel];
        
        // version label
        CGRect versionLabelFrame = CGRectMake(91, 46, 215, 22);
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:versionLabelFrame];
        [versionLabel setFont:[UIFont systemFontOfSize:13.f]];
        [versionLabel setTextColor:[UIColor lightGrayColor]];
        [versionLabel setBackgroundColor:[UIColor clearColor]];
        NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *versionString = [NSString stringWithFormat:@"Version %@", versionNumber];
        [versionLabel setText:versionString];
        [cell addSubview:versionLabel];
    }
    
//    // company information
//    else if (indexPath.section == 1) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
//        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
//        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
//        if (indexPath.row == 0) {
//            cell.textLabel.text = NSLocalizedString(@"Copyright", nil);
//            cell.detailTextLabel.text = [_infoDictionary objectForKey:@"COPYRIGHT"];
//        }
//        else if (indexPath.row == 1) {
//            cell.textLabel.text = NSLocalizedString(@"Website", nil);
//            cell.detailTextLabel.text = [_infoDictionary objectForKey:@"WEBSITE"];
//            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//        }
//        else {
//            cell.textLabel.text = NSLocalizedString(@"Twitter", nil);
//            cell.detailTextLabel.text = [_infoDictionary objectForKey:@"TWITTER"];
//            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//        }
//    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self shouldHighlightAndSelectRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self shouldHighlightAndSelectRowAtIndexPath:indexPath];
}

- (BOOL)shouldHighlightAndSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
//    return ((indexPath.section == 1) && ((indexPath.row == 1) || (indexPath.row == 2)));
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 1) {
//        if (indexPath.row == 1) {
//            [self goToTwitter];
//            [self goToWebsite];
//        }
//        else if (indexPath.row == 2) {
//            [self goToTwitter];
//        }
//    }
//}

#pragma mark - Actions

//- (void)goToWebsite
//{
//    NSString *url = [_infoDictionary objectForKey:@"WEBSITE_URL"];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//    [self deselectTableViewRow:YES];
//}
//
//- (void)goToTwitter
//{
//    NSString *url = [_infoDictionary objectForKey:@"TWITTER_URL"];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//    [self deselectTableViewRow:YES];
//}

- (void)donePressed:(id)sender
{
    HelpViewController *helpVC = (HelpViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    [helpVC.delegate helpViewControllerDidDismiss:helpVC];
}

#pragma mark - Methods

- (void)deselectTableViewRow:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
}

@end
