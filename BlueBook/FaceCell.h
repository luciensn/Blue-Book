//
//  FaceCell.h
//
//  Created by Scott Lucien on 5/31/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

#import "Person.h"

@interface FaceCell : UICollectionViewCell

// IBOutlets
@property (weak, nonatomic) IBOutlet UIImageView *faceImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

// Properties
@property (strong, nonatomic) UILongPressGestureRecognizer *longfellowDeeds;
@property (strong, nonatomic) Person *person;

// Public Methods
- (void)setUpLongPressWithTarget:(id)target action:(SEL)action;
- (void)hideEverything;
- (void)showEverything;
- (void)setEditingMode:(BOOL)mode;
- (void)startShaking;
- (void)stopShaking;

@end
