//
//  CircleImagePickerController.h
//
//  Created by Scott Lucien on 4/3/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface CircleImagePickerController : UIImagePickerController

- (id)initWithDelegate:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate
            sourceType:(UIImagePickerControllerSourceType)sourceType;

@end
