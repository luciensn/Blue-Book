//
//  CoreDataManager.m
//
//  Created by Scott Lucien on 9/14/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "UIAlertView+AlertViews.h"
#import "UIImage+Mask.h"

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark -

+ (CoreDataManager *)sharedManager
{
    static CoreDataManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CoreDataManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _managedObjectContext = [self managedObjectContext];
        _circleMask = [UIImage imageNamed:@"circle-small"];
        [self clearTheImagesDictionary];
    }
    return self;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BlueBook" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSURL *storeURL = [[appDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:@"BlueBook"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error : -[CoreDataManager persistentStoreCoordinator] : %@, %@", error, [error userInfo]);
        //abort();
        
        // show the core data error
        //[[UIAlertView coreDataError] show];
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) {
            if  (![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error : -[CoreDataManager saveContext] : %@, %@", error, [error userInfo]);
                
                // show the core data error
                //[[UIAlertView coreDataError] show];
            }
            //else {
            //    NSLog(@"Context saved.");
            //}
        }
    }
}

#pragma mark - Public Actions

- (void)reloadCoreDataWithCompletion:(void(^)(void))completion
{
    _coreDataObjects = [self fetchCoreDataObjectsIntoArray];
    [self loadTheImagesInBackground];
    
    // completion handler
    if (completion) {
        completion();
    }
}

- (void)deletePersonObject:(Person *)person atIndexPath:(NSIndexPath *)indexPath completion:(void(^)(void))completion
{
    NSString *uniqueID = person.uniqueID;
    
    // remove the item from data
    [[_coreDataObjects objectAtIndex:indexPath.section] removeObject:person];
    [_managedObjectContext deleteObject:person];
    
    // remove the image from in-memory dictionary
    [_imageDictionary removeObjectForKey:uniqueID];
    
    // update the index paths
    [self saveObjectIndexPaths];

    // completion handler
    if (completion) {
        completion();
    }
}

- (void)deleteAllPersonObjectsWithCompletion:(void(^)(void))completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Error Executing Fetch Request : %@", error);
    }
    
    for (NSManagedObject *object in items) {
        [_managedObjectContext deleteObject:object];
    }
    
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Error Deleting All Objects : Error:%@", error);
    }
    
    [self setCoreDataObjects:[[NSMutableArray alloc] init]];
    [self clearTheImagesDictionary];
    
    // completion handler
    if (completion) {
        completion();
    }
}

- (void)addImage:(UIImage *)image forID:(NSString *)uniqueID
{
    UIImage *maskedImage = [UIImage image:image maskedByImage:_circleMask];
    [_imageDictionary setObject:maskedImage forKey:uniqueID];
}

- (void)removeImageForId:(NSString *)uniqueID
{
    [_imageDictionary removeObjectForKey:uniqueID];
}

- (void)loadTheImagesInBackground
{
    dispatch_queue_t newQ = dispatch_queue_create("Load Images Into Memory", NULL);
    dispatch_async(newQ, ^{
        for (NSMutableArray *section in _coreDataObjects) {
            for (Person *object in section) {
                if (![_imageDictionary objectForKey:object.uniqueID]) {
                    if (object.displayImage) {
                        UIImage *image = [UIImage imageWithData:object.displayImage];
                        [self addImage:image forID:object.uniqueID];
                    }
                }
            }
        }
    });
}

- (void)clearTheImagesDictionary
{
    _imageDictionary = [[NSMutableDictionary alloc] init];
    
    // add the default image to the dictionary
    UIImage *image = [UIImage imageNamed:@"avatar-small"];
    image = [UIImage image:image maskedByImage:_circleMask];
    [_imageDictionary setObject:image forKey:@"default"];
}

#pragma mark - Public Data Source Methods

- (Person *)personObjectAtIndexPath:(NSIndexPath *)indexPath
{
    return (Person *)[[_coreDataObjects objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (UIImage *)imageForPerson:(Person *)person
{
    UIImage *image = (UIImage *)[_imageDictionary objectForKey:person.uniqueID];
    if (!image) {
        if (person.displayImage) {
            image = [UIImage imageWithData:person.displayImage];
            [self addImage:image forID:person.uniqueID];
            return (UIImage *)[_imageDictionary objectForKey:person.uniqueID];
        } else {
            return (UIImage *)[_imageDictionary objectForKey:@"default"];
        }
    }
    return image;
}

- (NSInteger)numberOfPages
{
    return [_coreDataObjects count];
}

- (NSInteger)numberOfItemsOnPage:(NSInteger)page
{
    return [[_coreDataObjects objectAtIndex:page] count];
}

- (NSInteger)getFirstAvailablePage
{
    NSInteger max = [self getMaxPerPage];
    NSInteger numPages = [self numberOfPages];
    NSInteger firstPage = 0;
    for (NSInteger i = 0; i < numPages; i++) {
        if ([_coreDataObjects count] > 0) {
            if ([[_coreDataObjects objectAtIndex:i] count] < max) {
                firstPage = i;
                break;
            }
            else if ((i == (numPages - 1)) && ([[_coreDataObjects objectAtIndex:i] count] >= max)) {
                firstPage = numPages;
                break;
            }
        }
    }
    return firstPage;
}

- (NSInteger)getFirstAvailableRowOnPage:(NSInteger)page
{
    NSInteger firstRow = 0;
    if ([_coreDataObjects count] != 0) {
        if (page < [self numberOfPages]) {
            firstRow =  [[_coreDataObjects objectAtIndex:page] count];
        }
    }
    return firstRow;
}

#pragma mark - Private Methods

- (NSMutableArray *)fetchCoreDataObjectsIntoArray
{
    // create an array of arrays from the core data objects
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    // fetch all objects
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortByPage = [[NSSortDescriptor alloc] initWithKey:@"pageNumber" ascending:YES];
    NSSortDescriptor *sortByRow = [[NSSortDescriptor alloc] initWithKey:@"pageRow" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByPage, sortByRow, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *allObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    // find the number of pages
    NSInteger pages = 1;
    NSInteger z = 0;
    for (NSInteger i = 0; i < [allObjects count]; i++) {
        Person *p = [allObjects objectAtIndex:i];
        if ([p.pageNumber integerValue] != z) {
            pages++;
            z = [p.pageNumber integerValue];
        }
    }
    
    // add to arrays based on page number
    for (NSInteger r = 0; r < pages; r++) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [allObjects count]; i++) {
            Person *p = [allObjects objectAtIndex:i];
            if ([p.pageNumber integerValue] == r) {
                [temp addObject:p];
            }
        }
        
        if ([temp count] > 0) {
            [array addObject:temp];
        }
    }
    
    return array;
}

- (void)saveObjectIndexPaths
{
    for (NSMutableArray *section in _coreDataObjects) {
        NSInteger sec = [_coreDataObjects indexOfObject:section];
        for (Person *person in section) {
            NSInteger row = [section indexOfObject:person];
            person.pageNumber = [NSNumber numberWithInteger:sec];
            person.pageRow = [NSNumber numberWithInteger:row];
        }
    }
}

- (NSInteger)getMaxPerPage
{
    return ([[UIScreen mainScreen] bounds].size.height > 480) ? 20 : 16;
}

#pragma mark - Rearranging People

- (void)movePersonOnSamePageFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to completion:(void(^)(void))completion
{
    NSMutableArray *section = [_coreDataObjects objectAtIndex:from.section];
    
    // grab the object we're going to move
    Person *person = [section objectAtIndex:from.row];
    person.pageRow = [NSNumber numberWithInteger:to.row];
    
    // mutate the data source array
    [section removeObject:person];
    [section insertObject:person atIndex:to.row];
    
    // completion handler
    if (completion) {
        completion();
    }
}

@end
