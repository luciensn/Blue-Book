//
//  HelpViewController.h
//
//  Created by Scott Lucien on 9/15/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

@class HelpViewController;

@protocol HelpViewControllerDelegate <NSObject>
- (void)helpViewControllerDidDeleteAllContacts:(HelpViewController *)controller;
- (void)helpViewControllerDidDismiss:(HelpViewController *)controller;
@end

@interface HelpViewController : UIViewController

- (id)initWithDelegate:(id<HelpViewControllerDelegate>)delegate;

// Properties
@property (weak, nonatomic) id<HelpViewControllerDelegate> delegate;

@end
