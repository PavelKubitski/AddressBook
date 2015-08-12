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
#import "CDPhoneNumber.h"
#import "NSString+PhoneNumber.h"
#import "CDCoordinate.h"
#import "UIImageView+AFNetworking.h"
#import "ServerManager.h"
#import "VKUser.h"


static NSInteger friendsInRequest = 100;

@interface CDWriter ()

@property (strong, nonatomic) NSMutableArray* friendsFromVK;

@end


@implementation CDWriter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.friendsFromVK = [NSMutableArray array];
    }
    return self;
}

+ (CDWriter*) sharedWriter {
    
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
    [self getFriendsFromServer];
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




#pragma mark - API

- (void) getFriendsFromServer {
    

    [[ServerManager sharedManager]
     getFriendsWithOffset:0
     count:friendsInRequest
     onSuccess:^(NSArray *friends) {
         
         [self.friendsFromVK addObjectsFromArray:friends];
         
         [self addPhotoToUser];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
}

- (void) addPhotoToUser {
    for (VKUser* user in self.friendsFromVK ) {
        CDPerson* person = [self findPersonWithFirstName:user.firstName andLastName:user.lastName];
        if (person) {
            [self addPhoto:user.imageURL toPerson:person];
        }
    }
}


- (CDPerson*) findPersonWithFirstName:(NSString*) firstName andLastName:(NSString*) lastName {
    
    NSManagedObjectContext* context = [[CDManager sharedManager] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest new];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"CDPerson" inManagedObjectContext:context];
    [request setEntity:description];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName == %@ AND lastName == %@", firstName, lastName];
    [request setPredicate:predicate];
    NSArray *friends = [context executeFetchRequest:request error:nil];
    return [friends firstObject];
}

- (void) addPhoto:(NSURL*) imageURL toPerson:(CDPerson*) person {
    NSURLRequest* request = [NSURLRequest requestWithURL:imageURL];
    UIImageView* imageView = [[UIImageView alloc] init];

    [imageView setImageWithURLRequest:request
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {

                                  if (image) {
                                      person.avatarImage = UIImageJPEGRepresentation(image, 1);
                                  }
                                  [[CDManager sharedManager] saveContext];
                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  NSLog(@"Failure! error : %@", [error localizedDescription]);
                              }];
}



#pragma mark - deleting


- (void) deleteAllObjects {
    
    NSArray* allObjects = [self allObjects];
    
    for (id object in allObjects) {

        [[[CDManager sharedManager] managedObjectContext] deleteObject:object];
    }
    [[CDManager sharedManager] saveContext];
}




@end
