//
//  OptionsViewController.m
//
//  Created by Scott Lucien on 3/30/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "OptionsViewController.h"
#import "BasePeoplePickerNavigationController.h"
#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "TwitterManager.h"
#import "UIImage+Mask.h"
#import "UIAlertView+AlertViews.h"
#import "UIBarButtonItem+ButtonItems.h"
#import "UIColor+Theme.h"
#import "CircleImagePickerController.h"

@interface OptionsViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *theImageButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

// Properties
@property (strong, nonatomic) UIImage *coreDataImage;
@property (nonatomic) CGSize buttonSize;
@property (nonatomic) CGRect buttonRect;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic) CGRect thumbnailRect;
@property (nonatomic) BOOL focus;
@property (nonatomic) BOOL stillCares;
@property (nonatomic) BOOL saveWasPressed;
@property (nonatomic) BOOL editingPerson;
@property (nonatomic) BOOL imageHasBeenChanged;

// IBActions
- (IBAction)imageTapped:(id)sender;

@end

#pragma mark -

@implementation OptionsViewController

- (id)initWithDelegate:(id<OptionsViewControllerDelegate>)delegate
{
    NSString *nibName = @"OptionsViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        [self setDelegate:delegate];
    }
    return self;
}

- (id)initWithEditingModeAndDelegate:(id<OptionsViewControllerDelegate>)delegate
{
    self = [self initWithDelegate:delegate];
    if (self) {
        [self setEditingPerson:YES];
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
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    // create the save button
    if (_editingPerson) {
        [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem cancelButtonWithTarget:self action:@selector(cancelTapped:)]];
    }
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem doneButtonWithTarget:self action:@selector(savePressed:)]];
    
    // set up the image options
    _thumbnailSize = CGSizeMake(60, 60);
    _buttonSize = CGSizeMake(120, 120);
    _thumbnailRect = CGRectMake(0, 0, _thumbnailSize.width, _thumbnailSize.height);
    _buttonRect = CGRectMake(0, 0, _buttonSize.width, _buttonSize.height);
    
    // get and display the default image
    [self loadInitialImage];
    
    // set the display name
    [_nameTextBox setText:self.navigationItem.title];
    [_nameTextBox setDelegate:self];
    [self setFocus:YES];
    [self textChanged];
    
    // register for text changing notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged) name:UITextFieldTextDidChangeNotification object:_nameTextBox];
    
    // tap to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tap];
    
    // check for first time opening this view controller
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"optionsFirstTime"] == NULL) {
        [defaults setBool:YES forKey:@"optionsFirstTime"];
        [defaults synchronize];
    }
    
    if ([defaults boolForKey:@"optionsFirstTime"]) {
        [self configureTutorialButton];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_focus) {
        [_nameTextBox becomeFirstResponder];
        [self setFocus:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!_saveWasPressed) {
        [_nameTextBox resignFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopCaringAboutBackgroundThreads];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)backgroundTapped:(id)sender
{    
    [_nameTextBox resignFirstResponder];
}

- (void)textChanged
{
    [self.navigationItem setTitle:_nameTextBox.text];
    [self.navigationItem.rightBarButtonItem setEnabled:(_nameTextBox.text.length > 0)];
}

- (IBAction)imageTapped:(id)sender
{
    [_nameTextBox resignFirstResponder];
    
    /* PHOTO OPTIONS
     1. remove image (if there is one)
     2. address book photo (if it exists)
     3. choose existing photo
     4. take new photo (if there is a camera)
     5. download twitter photo
     6. cancel
    */
    
    BOOL camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL hasAdressBookImage = ABPersonHasImageData(_selectedPerson);
    BOOL showClearOption = ((_currentImage != nil) || (_coreDataImage != nil));
    
    NSInteger tag;
    if (showClearOption) {
        if (hasAdressBookImage && camera) { // all options
            tag = 101;
        } else if (hasAdressBookImage) { // no camera
            tag = 102;
        } else if (camera) { // no address book
            tag = 103;
        } else { // no address book or camera
            tag = 104;
        }
    } else {
        if (hasAdressBookImage && camera) { // all options
            tag = 105;
        } else if (hasAdressBookImage) { // no camera
            tag = 106;
        } else if (camera) { // no address book
            tag = 107;
        } else { // no address book or camera
            tag = 108;
        }
    }
    
    UIActionSheet *actions = [UIAlertView optionsForTag:tag delegate:self];
    [actions showInView:self.view];
}

- (void)savePressed:(id)sender
{
    // flag first run complete
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"optionsFirstTime"]) {
        [defaults setBool:NO forKey:@"optionsFirstTime"];
        [defaults synchronize];
    }
    
    [self setSaveWasPressed:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self stopCaringAboutBackgroundThreads];
    [self lockUI];
    
//    dispatch_queue_t saveQ = dispatch_queue_create("saveQueue", NULL);
//    dispatch_async(saveQ, ^{
    
        /* NEW PERSON MODE */
        if (!_editingPerson) {
            
            CoreDataManager *dataManager = [CoreDataManager sharedManager];
            Person *newPerson = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                                        inManagedObjectContext:dataManager.managedObjectContext];
            
            newPerson.displayName = [self trimmedString:_nameTextBox.text];
            if (_coreDataImage) {
                newPerson.displayImage = [NSData dataWithData:UIImageJPEGRepresentation(_coreDataImage, 0.9)];
            }
            newPerson.pageNumber = [NSNumber numberWithInteger:_page];
            newPerson.pageRow = [NSNumber numberWithInteger:_row];
            newPerson.personID = [NSNumber numberWithInt:ABRecordGetRecordID(_selectedPerson)];
            
            NSString *date = [NSString stringWithFormat:@"%@", [NSDate date]];
            NSString *uid = [date stringByReplacingOccurrencesOfString:@" " withString:@""];
            newPerson.uniqueID = uid;
            
            // insert the object into the data source
            if ([dataManager.coreDataObjects count] < 1) {
                for (NSInteger i = 0; i < (_page + 1); i++) {
                    NSMutableArray *newPage = [[NSMutableArray alloc] init];
                    [dataManager.coreDataObjects addObject:newPage];
                }
            }
            NSMutableArray *dataSource = [dataManager.coreDataObjects objectAtIndex:_page];
            [dataSource insertObject:newPerson atIndex:_row];
            
            NSDictionary *info = nil;
            if (_coreDataImage) {
                info = [NSDictionary dictionaryWithObjects:@[_coreDataImage, newPerson.uniqueID] forKeys:@[@"img", @"uid"]];
            }
            
//            dispatch_async(dispatch_get_main_queue(), ^{
                [self unlockUI];
                [_delegate optionsViewController:self didFinishWithInfo:info scrollTo:_page];
//            });
        }
        
        /* EDITING MODE */
        else {
            
            BOOL textHasChanged = ![_nameTextBox.text isEqualToString:_personObject.displayName];
            
            // nothing changed
            if ((!textHasChanged) && (!_imageHasBeenChanged)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self unlockUI];
                    [_delegate optionsViewControllerDidCancel:self];
                });
            }
            
            // save the changes
            else {
                if (textHasChanged) {
                    _personObject.displayName = [self trimmedString:_nameTextBox.text];
                }
                
                if (_imageHasBeenChanged) {
                    if (_coreDataImage) {
                        _personObject.displayImage = [NSData dataWithData:UIImageJPEGRepresentation(_coreDataImage, 0.9)];
                    } else {
                        _personObject.displayImage = nil;
                    }
                }
                
                NSDictionary *info;
                if (_coreDataImage) {
                    info = [NSDictionary dictionaryWithObjects:@[_coreDataImage, _personObject.uniqueID] forKeys:@[@"img", @"uid"]];
                } else {
                    info = [NSDictionary dictionaryWithObjects:@[_personObject.uniqueID] forKeys:@[@"uid"]];
                }
                
//                dispatch_async(dispatch_get_main_queue(), ^{
                    [self unlockUI];
                    [_delegate optionsViewController:self didEndEditingWithInfo:info];
//                });
            }
        }
//    });
}

- (void)cancelTapped:(id)sender
{
    [self.delegate optionsViewControllerDidCancel:self];
}

#pragma mark - Methods

- (void)loadInitialImage
{
    /* EDITING MODE */
    if (_editingPerson) {
        if (_currentImage) {
            [self updateImagesWithImage:_currentImage];
        } else {
            [self clearSelectedImage];
        }
        [self setCoreDataImage:nil];
        [self setImageHasBeenChanged:NO];
    }
    
    /* NEW PERSON MODE */
    else {
        if (ABPersonHasImageData(_selectedPerson)) {
            [self loadAddressBookImage];
        } else {
            [self clearSelectedImage];
        }
    }
}

- (void)configureTutorialButton {
    NSString *text = NSLocalizedString(@"Tap Here\nTo Choose\na Photo", nil);
    [_theImageButton setTitle:text forState:UIControlStateNormal];
    [_theImageButton.titleLabel setNumberOfLines:0];
    [_theImageButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    UIColor *tintColor = self.navigationController.navigationBar.tintColor;
    UIImage *background = [UIImage imageWithColor:tintColor andSize:_buttonSize];
    background = [UIImage image:background maskedByImage:[UIImage imageNamed:@"circle-big"]];
    [_theImageButton setBackgroundImage:background forState:UIControlStateNormal];
}

- (void)clearTutorialButton {
    [_theImageButton setTitle:nil forState:UIControlStateNormal];
    [_theImageButton setBackgroundImage:nil forState:UIControlStateNormal];
}

- (void)lockUI
{
    [self.navigationController.view setUserInteractionEnabled:NO];
}

- (void)unlockUI
{
    [self.navigationController.view setUserInteractionEnabled:NO];
}

- (void)stopCaringAboutBackgroundThreads
{
    [self setStillCares:NO];
    [self toggleSpinners:NO];
}

- (NSString *)trimmedString:(NSString *)string
{
    if (string.length > 18) {
        NSString *trim = [string substringToIndex:15];
        return [NSString stringWithFormat:@"%@...", trim];
    }
    return string;
}

#pragma mark - Choose Image Options

- (void)clearSelectedImage
{
    UIImage *defaultImage = [UIImage imageNamed:@"avatar-big"];
    [self updateImagesWithImage:defaultImage];
    [self setCoreDataImage:nil];
    [self setCurrentImage:nil];
}

- (void)loadAddressBookImage
{
    NSData *imgData = CFBridgingRelease(ABPersonCopyImageData(_selectedPerson));
    UIImage *cropped = [self cropToSquare:[UIImage imageWithData:imgData]];
    [self updateImagesWithImage:cropped];
}

- (void)promptToChooseImage
{
    UIImagePickerControllerSourceType photos = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    CircleImagePickerController *imgPicker = [[CircleImagePickerController alloc] initWithDelegate:self sourceType:photos];
    [self presentViewController:imgPicker animated:YES completion:nil];
}

- (void)promptToTakeImage
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerControllerSourceType camera = UIImagePickerControllerSourceTypeCamera;
        CircleImagePickerController *imgTaker = [[CircleImagePickerController alloc] initWithDelegate:self sourceType:camera];
        [self presentViewController:imgTaker animated:YES completion:nil];
    }
}

- (void)getTwitterPhoto
{
    NSString *username = [self getTwitterUsernameFromRecord:_selectedPerson];
    if (username) {
        [self downloadTwitterPhotoForUsername:username];
    } else {
        [self promptForUserName];
    }
}

#pragma mark - Image Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self updateImagesWithImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)smallImageScaled:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(_thumbnailSize, NO, 0.0);
    [image drawInRect:_thumbnailRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)bigImageScaled:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(_buttonSize, NO, 0.0);
    [image drawInRect:_buttonRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)cropToSquare:(UIImage *)image
{
    // calculate the crop area
    CGFloat originalWidth  = image.size.width;
    CGFloat originalHeight = image.size.height;
    if (originalWidth == originalHeight) {
        return image;
    }
    
    // zoom in slightly
    CGFloat edge = fminf(originalWidth, originalHeight);
    edge = edge - (edge/6);
    
    // calculate the starting x and y positions
    CGFloat posX = (originalWidth - edge) / 2.0f;
    CGFloat posY = (originalHeight - edge) / 2.0f;
    
    // calculate the crop area based on image orientation
    CGRect cropArea;
    if((image.imageOrientation == UIImageOrientationLeft) ||
       (image.imageOrientation == UIImageOrientationRight))
    {
        cropArea = CGRectMake(posY, posX, edge, edge);
    } else {
        cropArea = CGRectMake(posX, posY, edge, edge);
    }
    
    // crop the image
    UIImage *cropped = nil;
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropArea);
    cropped = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return cropped;
}

- (void)updateImagesWithImage:(UIImage *)image;
{
    [self clearTutorialButton];
    UIImage *smallImage = [self smallImageScaled:image];
    UIImage *bigImage = [self bigImageScaled:image];
    bigImage = [UIImage image:bigImage maskedByImage:[UIImage imageNamed:@"circle-big"]];
    [self setCoreDataImage:smallImage];
    [_theImageButton setBackgroundImage:bigImage forState:UIControlStateNormal];
    [self setImageHasBeenChanged:YES];
}

#pragma mark - Download Twitter Image

- (NSString *)getTwitterUsernameFromRecord:(ABRecordRef)record
{
    NSString *twitterUsername = nil;
    ABMultiValueRef socials = ABRecordCopyValue(record, kABPersonSocialProfileProperty);
    if (socials) {
        CFIndex socialsCount = ABMultiValueGetCount(socials);
        for (NSInteger k = 0 ; k < socialsCount ; k++) {
            CFDictionaryRef socialValue = ABMultiValueCopyValueAtIndex(socials, k);
            if (CFStringCompare(CFDictionaryGetValue(socialValue, kABPersonSocialProfileServiceKey),
                                kABPersonSocialProfileServiceTwitter, 0) == kCFCompareEqualTo) {
                twitterUsername = (NSString *)CFDictionaryGetValue(socialValue, kABPersonSocialProfileUsernameKey);
            }
            CFRelease(socialValue);
            if (twitterUsername) {
                break;
            }
        }
        CFRelease(socials);
        return twitterUsername;
    }
    else {
        return nil;
    }
}

- (void)promptForUserName
{
    [[UIAlertView usernamePromptWithDelegate:self] show];
}

- (void)downloadTwitterPhotoForUsername:(NSString *)username
{
    __weak typeof(self) weakSelf = self;
    
    [self toggleSpinners:YES];
    [self setStillCares:YES];
    
    NSString *twitterName = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
    [TwitterManager getTwitterPhotoForUsername:twitterName completion:^(UIImage *image, ErrorCode errorCode){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.stillCares) {
                [weakSelf toggleSpinners:NO];
                if (image) {
                    [weakSelf updateImagesWithImage:image];
                }
                else {
                    // TODO: handle twitter errors
                    [[UIAlertView twitterErrorForUserName:username] show];
                }
            }
        });
    }];
}

- (void)toggleSpinners:(BOOL)spin
{
    if (spin) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [_spinner startAnimating];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [_spinner stopAnimating];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self savePressed:nil];
    return NO;
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex != (actionSheet.numberOfButtons - 1)) && _stillCares) {
        [self stopCaringAboutBackgroundThreads];
    }
    
    // remove photo enabled
    if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
            [self clearSelectedImage];
        } else if (buttonIndex == 1) {
            [self loadAddressBookImage];
        } else if (buttonIndex == 2) {
            [self promptToChooseImage];
        } else if (buttonIndex == 3) {
            [self promptToTakeImage];
        } else if (buttonIndex == 4) {
            [self getTwitterPhoto];
        }
    }
    else if (actionSheet.tag == 102) {
        if (buttonIndex == 0) {
            [self clearSelectedImage];
        } else if (buttonIndex == 1) {
            [self loadAddressBookImage];
        } else if (buttonIndex == 2) {
            [self promptToChooseImage];
        } else if (buttonIndex == 3) {
            [self getTwitterPhoto];
        }
    }
    else if (actionSheet.tag == 103) {
        if (buttonIndex == 0) {
            [self clearSelectedImage];
        } else if (buttonIndex == 1) {
            [self promptToChooseImage];
        } else if (buttonIndex == 2) {
            [self promptToTakeImage];
        } else if (buttonIndex == 3) {
            [self getTwitterPhoto];
        }
    }
    else if (actionSheet.tag == 104) {
        if (buttonIndex == 0) {
            [self clearSelectedImage];
        } else if (buttonIndex == 1) {
            [self promptToChooseImage];
        } else if (buttonIndex == 2) {
            [self getTwitterPhoto];
        }
    }
    
    // remove photo disabled
    else if (actionSheet.tag == 105) {
        if (buttonIndex == 0) {
            [self loadAddressBookImage];
        } else if (buttonIndex == 1) {
            [self promptToChooseImage];
        } else if (buttonIndex == 2) {
            [self promptToTakeImage];
        } else if (buttonIndex == 3) {
            [self getTwitterPhoto];
        }
    }
    else if (actionSheet.tag == 106) {
        if (buttonIndex == 0) {
            [self loadAddressBookImage];
        } else if (buttonIndex == 1) {
            [self promptToChooseImage];
        } else if (buttonIndex == 2) {
            [self getTwitterPhoto];
        }
    }
    else if (actionSheet.tag == 107) {
        if (buttonIndex == 0) {
            [self promptToChooseImage];
        } else if (buttonIndex == 1) {
            [self promptToTakeImage];
        } else if (buttonIndex == 2) {
            [self getTwitterPhoto];
        }
    }
    else if (actionSheet.tag == 108) {
        if (buttonIndex == 0) {
            [self promptToChooseImage];
        } else if (buttonIndex == 1) {
            [self getTwitterPhoto];
        }
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        NSString *text = [[alertView textFieldAtIndex:0] text];
        [self downloadTwitterPhotoForUsername:text];
    }
}

@end
