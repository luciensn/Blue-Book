//
//  UIImage+Mask.m
//
//  Created by Scott Lucien on 9/12/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "UIImage+Mask.h"

@implementation UIImage (Mask)

+ (UIImage *)imageNamed:(NSString *)imageName withMaskImageNamed:(NSString *)maskImageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *maskImage = [UIImage imageNamed:maskImageName];
    return [UIImage image:image maskedByImage:maskImage];
}

+ (UIImage *)image:(UIImage *)image maskedByImage:(UIImage *)maskImage
{
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    UIImage *returnImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    CGImageRelease(mask);
    return returnImage;
}

#pragma mark -

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
