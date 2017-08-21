//
//  OptionsViewController.h
//
//  Created by Scott Lucien on 3/30/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import AddressBook;

#import "Person.h"
#import "FaceCell.h"

@class OptionsViewController;

@protocol OptionsViewControllerDelegate
- (void)optionsViewController:(OptionsViewController *)controller didFinishWithInfo:(NSDictionary *)info scrollTo:(NSInteger)page;
- (void)optionsViewController:(OptionsViewController *)controller didEndEditingWithInfo:(NSDictionary *)info;
- (void)optionsViewControllerDidCancel:(OptionsViewController *)controller;
@end

@interface OptionsViewController : UIViewController

- (id)initWithDelegate:(id<OptionsViewControllerDelegate>)delegate;
- (id)initWithEditingModeAndDelegate:(id<OptionsViewControllerDelegate>)delegate;

// Properties
@property (weak, nonatomic) id<OptionsViewControllerDelegate> delegate;
@property (nonatomic) ABRecordRef selectedPerson;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger row;

// Editing Mode
@property (strong, nonatomic) Person *personObject;
@property (strong, nonatomic) UIImage *currentImage;

@end
