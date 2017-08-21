//
//  DraggableView.h
//
//  Created by Scott Lucien on 9/14/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface DraggableView : UIView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image name:(NSString *)name;

// Properties
@property (strong, nonatomic) UIImageView *faceImage;
@property (strong, nonatomic) UILabel *nameLabel;

@end
