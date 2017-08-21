//
//  UIView+FindSubviews.h
//
//  Created by Scott Lucien on 4/3/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UIView (FindSubviews)

// Methods
- (void)printAllSubviews;
- (UIView *)findFirstSubviewOfClass:(NSString *)className;

@end
