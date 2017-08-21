//
//  TwitterManager.h
//
//  Created by Scott Lucien on 10/3/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, ErrorCode) {
    SUCCESS,
    AUTHENTICATION_ERROR,
    USER_INFO_ERROR,
    IMAGE_ERROR
};

@interface TwitterManager : NSObject

// Public Methods
+ (void)checkForAuthentication;
+ (void)getTwitterPhotoForUsername:(NSString *)username completion:(void(^)(UIImage *image, ErrorCode errorCode))completion;

@end
