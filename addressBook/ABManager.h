//
//  ABManager.h
//  addressBook
//
//  Created by Pavel Kubitski on 15.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Person.h"
#import <AddressBook/AddressBook.h>
#import "CDPerson.h"

extern NSString* const ABManagerDidChangeAddressBookNotification;
extern NSString* const ABManagerCanReadAfterPermisionAddressBookNotification;

extern NSString* const ABManagerDidChangeAddressBookInfoKey;
extern NSString* const ABManagerKindOfChangeInfoKey;
extern NSString* const ABManagerCanReadAfterPermisionAddressBookInfoKey;

@interface ABManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrayOfPersons;
@property (assign, nonatomic) ABAddressBookRef addressBook;



- (NSMutableArray *) allPersonsAddPerson:(BOOL) addPerson;
- (void) deletePerson:(CDPerson*) personToRemove;
- (void) fillPersonsArray;
- (void) updateAdressBookPerson:(CDPerson*) person withPerson:(CDPerson*) newPers;
+ (ABManager*) sharedBook;

@end
