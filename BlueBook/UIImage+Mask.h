//
//  UIImage+Mask.h
//
//  Created by Scott Lucien on 9/12/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UIImage (Mask)

+ (UIImage *)imageNamed:(NSString *)imageName withMaskImageNamed:(NSString *)maskImageName;

+ (UIImage *)image:(UIImage *)image maskedByImage:(UIImage *)maskImage;

#pragma mark -

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end
