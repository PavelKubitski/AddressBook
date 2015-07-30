//
//  CDManager.h
//  addressBook
//
//  Created by Pavel Kubitski on 14.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CDManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CDManager*) sharedManager;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

@end
