//
//  CDWriter.m
//  addressBook
//
//  Created by Pavel Kubitski on 14.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "CDWriter.h"
#import "CDPerson.h"
#import "Person.h"
#import "LabelAndInfo.h"
#import "CDEmail.h"
#import "CDObject.h"
#include "CDPhoneNumber.h"
#include "NSString+PhoneNumber.h"
#include "CDCoordinate.h"

@implementation CDWriter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cdManager = [CDManager sharedManager];
    }
    return self;
}

+ (CDWriter*) sharedManager {
    
    static CDWriter* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CDWriter alloc] init];
    });
    
    return manager;
}



- (NSArray*) allObjects {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"CDObject"
                inManagedObjectContext:[[CDManager sharedManager] managedObjectContext]];
    
    [request setEntity:description];
    [request setFetchBatchSize:15];
    NSError* requestError = nil;
    NSArray* objects = [[[CDManager sharedManager] managedObjectContext] executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    for (id object in objects) {
        
        if ([object isKindOfClass:[CDPerson class]]) {

            CDPerson* cdPerson = (CDPerson*) object;

            [result addObject:cdPerson];
        }
    }

    return result;
}



- (void) addPersonsToCDBase:(NSArray*) persons {
    for (Person* pers in persons) {
        CDPerson* person = [NSEntityDescription insertNewObjectForEntityForName:@"CDPerson"
                                                         inManagedObjectContext:[[CDManager sharedManager]managedObjectContext]];
        person.firstName = pers.firstName;
        person.lastName = pers.lastName;
        person.companyName = pers.companyName;
        if (pers.image) {
            person.avatarImage = UIImageJPEGRepresentation(pers.image, 1);
        } else {
            UIImage *image = [UIImage imageNamed:@"noname.png"];
            person.avatarImage = [NSData dataWithData:UIImagePNGRepresentation(image)];
        }
        

        for (LabelAndInfo* lab in pers.emails) {
            CDEmail* email = [NSEntityDescription insertNewObjectForEntityForName:@"CDEmail"
                                                           inManagedObjectContext:[[CDManager sharedManager]managedObjectContext]];
            email.typeLabel = lab.label;
            email.email = lab.info;
            email.person = person;
        }
        for (LabelAndInfo* lab in pers.numbers) {
            CDPhoneNumber* number = [NSEntityDescription insertNewObjectForEntityForName:@"CDPhoneNumber"
                                                           inManagedObjectContext:[[CDManager sharedManager]managedObjectContext]];
            number.typeLabel = lab.label;
            number.number = [lab.info makeNumberFromString];
            number.person = person;
        }
        CDCoordinate* coordinate = [NSEntityDescription insertNewObjectForEntityForName:@"CDCoordinate"
                                                              inManagedObjectContext:[[CDManager sharedManager]managedObjectContext]];
        coordinate.nameOfLocation = @"Home";
        coordinate.fullAddress = pers.address;
        coordinate.latitude = NULL;
        coordinate.longitude = NULL;
        coordinate.person = person;
    }

    [[CDManager sharedManager] saveContext];
}


- (void) deleteAllObjects {
    
    NSArray* allObjects = [self allObjects];
    
    for (id object in allObjects) {

        [[[CDManager sharedManager] managedObjectContext] deleteObject:object];
    }
    [[CDManager sharedManager] saveContext];
}




@end
