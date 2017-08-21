//
//  FaceCollectionViewLayout.h
//
//  Created by Scott Lucien on 6/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface FaceCollectionViewLayout : UICollectionViewLayout

// Properties
@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingX;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numberOfColumns;

@end
