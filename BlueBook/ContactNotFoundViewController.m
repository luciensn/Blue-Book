//
//  ContactNotFoundViewController.m
//
//  Created by Scott Lucien on 4/3/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "ContactNotFoundViewController.h"
#import "UIColor+Theme.h"

@interface ContactNotFoundViewController ()

// IBOutlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

@end

#pragma mark -

@implementation ContactNotFoundViewController

- (id)initWithNib
{
    NSString *nib = @"ContactNotFoundViewController";
    self = [super initWithNibName:nib bundle:nil];
    if (self) {
        // initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Info", nil)];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    // message label
    [_noDataLabel setTextColor:[UIColor noDataLabelTextColor]];
    [_noDataLabel setText:NSLocalizedString(@"Contact Not Found", nil)];
}


@end
