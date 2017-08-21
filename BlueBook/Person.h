//
//  Person.h
//
//  Created by Scott Lucien on 12/12/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSData *displayImage;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSNumber *personID;
@property (nonatomic, retain) NSNumber *pageNumber;
@property (nonatomic, retain) NSNumber *pageRow;

@end
