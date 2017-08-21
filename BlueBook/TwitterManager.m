//
//  TwitterManager.m
//
//  Created by Scott Lucien on 10/3/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "TwitterManager.h"
#import "KeychainItemWrapper.h"

#define TIMEOUT 10.0

typedef void (^NSURLSessionCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);

@implementation TwitterManager

#pragma mark - Public Methods

+ (void)checkForAuthentication
{
    // get a new access token if we need one
    [self getAccessTokenWithCompletion:nil];
}

+ (void)getTwitterPhotoForUsername:(NSString *)username completion:(void(^)(UIImage *image, ErrorCode errorCode))completion
{
    /* 1. ACCESS TOKEN */
    [self getAccessTokenWithCompletion:^(NSString *accessToken){
        if (accessToken) {
            
            /* 1. USER INFO */
            [self getURLForUsername:username withToken:accessToken completion:^(NSString *urlString) {
                if (urlString) {
                    
                    /* 1. IMAGE DATA */
                    [self getImageFromURLString:urlString withCompletion:^(UIImage *image) {
                        if (image) {
                            
                            // success! return the downloaded image
                            completion(image, SUCCESS);
                        }
                        else {
                            
                            // error getting the image
                            completion(nil, IMAGE_ERROR);
                        }
                    }];
                }
                else {
                
                    // error getting the user info, clear the token
                    [self clearKeychain];
                    completion(nil, USER_INFO_ERROR);
                }
            }];
        }
        else {
            
            // error getting the access token
            completion(nil, AUTHENTICATION_ERROR);
        }
    }];
}

#pragma mark - Keychain Items

static NSString *const ContactsTwitterAuth = @"ContactsTwitterAuth";

+ (void)saveAccessToken:(NSString *)accessToken
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:ContactsTwitterAuth accessGroup:nil];
    [keychain setObject:accessToken forKey:(__bridge id)kSecAttrAccount];
}

+ (NSString *)getAccessToken
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:ContactsTwitterAuth accessGroup:nil];
    return [keychain objectForKey:(__bridge id)kSecAttrAccount];
}

+ (void)clearKeychain
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:ContactsTwitterAuth accessGroup:nil];
    [keychain resetKeychainItem];
}

#pragma mark - Authentication Data

+ (void)getAccessTokenWithCompletion:(void(^)(NSString *accessToken))completion
{
    NSString *accessToken = [self getAccessToken];
    if ((accessToken == nil) || ([accessToken isEqualToString:@""])) {
        
        // compile the base64-encoded bearer token
        NSString *key = @"3xUTaZAoEV7K3Y2ZxKyhA";
        NSString *secret = @"JMjO0irP8DKaOAUqTfYxtoT2cHYPL8glrw75ZNWl2Q8";
        //NSString *encodedKey = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //NSString *encodedSecret = [secret stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *bearerToken = [NSString stringWithFormat:@"%@:%@", key, secret];
        NSData *bearerTokenData = [bearerToken dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64EncodedToken = [bearerTokenData base64EncodedStringWithOptions:0];
        
        // build the authentication request
        NSURL *authURL = [NSURL URLWithString:@"https://api.twitter.com/oauth2/token"];
        NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:authURL
                                                                        cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                    timeoutInterval:TIMEOUT];
        [authRequest setHTTPMethod:@"POST"];
        NSString *headerAuthorization = [NSString stringWithFormat:@"Basic %@", base64EncodedToken];
        [authRequest setValue:headerAuthorization forHTTPHeaderField:@"Authorization"];
        [authRequest setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        NSString *httpBody = @"grant_type=client_credentials";
        [authRequest setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
        
        // submit the request
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:authRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if (error && completion) {
                completion(nil);
            }
            
            // get the token from the JSON
            NSString *token = [self getTokenFromJSONData:data];
            
            // save the new token
            if (token) {
                [self saveAccessToken:token];
                NSLog(@"new token saved");
            }
            
            // return the new token
            if (completion) {
                completion(token);
            }
        }] resume];
        
    }
    else {
        
        // return the existing token
        if (completion) {
            completion(accessToken);
        }
    }
}

+ (NSString *)getTokenFromJSONData:(NSData *)data
{
    if (data) {
        
        // convert the data into a json object
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        // error parsing json
        if (error) {
            NSLog(@"Error parsing JSON token response data.");
            return nil;
        }
        
        // errors were received
        if ([json objectForKey:@"errors"]) {
            return nil;
        }
        
        // the token is not the bearer
        NSString *tokenType = [json objectForKey:@"token_type"];
        if (![tokenType isEqualToString:@"bearer"]) {
            return nil;
        }
        
        // access token was obtained successfully
        return (NSString *)[json objectForKey:@"access_token"];
    }
    
    return nil;
}

#pragma mark - User Info Data

+ (void)getURLForUsername:(NSString *)username withToken:(NSString *)token completion:(void(^)(NSString *urlString))completion
{
    // request the user info for the given username
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", username];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:TIMEOUT];
    [request setHTTPMethod:@"GET"];
    NSString *headerAuthorization = [NSString stringWithFormat:@"Bearer %@", token];
    [request setValue:headerAuthorization forHTTPHeaderField:@"Authorization"];
    
    // submit the request
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error && completion) {
            completion(nil);
        }
        
        // get the string from the JSON
        NSString *imageURL = [self getURLFromJSONData:data];
        
        // return the url string
        if (completion) {
            completion(imageURL);
        }
    }] resume];
}

+ (NSString *)getURLFromJSONData:(NSData *)data
{
    if (data) {
        
        // convert the data into a json object
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        // error parsing json
        if (error) {
            NSLog(@"Error parsing JSON user info data.");
            return nil;
        }
        
        // errors were received
        if ([json objectForKey:@"errors"]) {
            return nil;
        }
        
        // image url was obtained successfully
        NSString *urlString = [json objectForKey:@"profile_image_url_https"];
        NSString *bigger = [urlString stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
        return bigger;
    }
    
    return nil;
}

#pragma mark - Image Data

+ (void)getImageFromURLString:(NSString *)urlString withCompletion:(void(^)(UIImage *image))completion {
    
    // create the request for the profile photo
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:TIMEOUT];
    [request setHTTPMethod:@"GET"];
    
    // submit the request
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error && completion) {
            completion(nil);
        }
        
        // return the image
        UIImage *image = [UIImage imageWithData:data];
        if (completion) {
            completion(image);
        }
    }] resume];
}


@end
