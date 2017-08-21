//
//  CoreDataManager.h
//
//  Created by Scott Lucien on 9/14/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import Foundation;

#import "Person.h"

@interface CoreDataManager : NSObject

// Class Methods
+ (CoreDataManager *)sharedManager;

// Properties
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSMutableArray *coreDataObjects;
@property (strong, nonatomic) NSMutableDictionary *imageDictionary;
@property (strong, nonatomic) UIImage *circleMask;

// Actions
- (void)saveContext;
- (void)saveObjectIndexPaths;
- (void)reloadCoreDataWithCompletion:(void(^)(void))completion;
- (void)movePersonOnSamePageFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to completion:(void(^)(void))completion;
- (void)deletePersonObject:(Person *)person atIndexPath:(NSIndexPath *)indexPath completion:(void(^)(void))completion;
- (void)deleteAllPersonObjectsWithCompletion:(void(^)(void))completion;
- (void)addImage:(UIImage *)image forID:(NSString *)uniqueID;
- (void)removeImageForId:(NSString *)uniqueID;
- (void)loadTheImagesInBackground;
- (void)clearTheImagesDictionary;

// Data Source Methods
- (Person *)personObjectAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)imageForPerson:(Person *)person;
- (NSInteger)numberOfPages;
- (NSInteger)numberOfItemsOnPage:(NSInteger)page;
- (NSInteger)getFirstAvailablePage;
- (NSInteger)getFirstAvailableRowOnPage:(NSInteger)page;
- (NSInteger)getMaxPerPage;

@end
