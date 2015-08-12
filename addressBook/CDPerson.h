//
//  CDPerson.h
//  addressBook
//
//  Created by Pavel Kubitski on 09.08.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDObject.h"

@class CDCoordinate, CDEmail, CDPhoneNumber;

@interface CDPerson : CDObject

@property (nonatomic, retain) NSData * avatarImage;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) CDCoordinate *coordinate;
@property (nonatomic, retain) NSSet *email;
@property (nonatomic, retain) NSSet *phoneNumber;
@end

@interface CDPerson (CoreDataGeneratedAccessors)

- (void)addEmailObject:(CDEmail *)value;
- (void)removeEmailObject:(CDEmail *)value;
- (void)addEmail:(NSSet *)values;
- (void)removeEmail:(NSSet *)values;

- (void)addPhoneNumberObject:(CDPhoneNumber *)value;
- (void)removePhoneNumberObject:(CDPhoneNumber *)value;
- (void)addPhoneNumber:(NSSet *)values;
- (void)removePhoneNumber:(NSSet *)values;

@end
