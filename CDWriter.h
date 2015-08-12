//
//  CDWriter.h
//  addressBook
//
//  Created by Pavel Kubitski on 14.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDManager.h"
@class CDPerson;

@interface CDWriter : NSObject

@property (strong, nonatomic) CDManager* cdManager;

+ (CDWriter*) sharedWriter;

- (void) addPersonsToCDBase:(NSArray*) persons;
- (NSArray*) allObjects;
- (void) deleteAllObjects;
- (void) addPhotoToUser;

@end
