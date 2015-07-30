//
//  LabelAndInfo.m
//  addressBook
//
//  Created by Pavel Kubitski on 06.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "LabelAndInfo.h"
#import "CDEmail.h"
#import "CDPhoneNumber.h"
#import "CDManager.h"

@implementation LabelAndInfo


- (LabelAndInfo*) initWithCDObject:(id) cdObject {
    LabelAndInfo* info = [[LabelAndInfo alloc] init];
    if ([cdObject isKindOfClass:[CDEmail class]]) {
        info.label = [NSString stringWithString:[cdObject typeLabel]];
        info.info = [NSString stringWithString:[cdObject email]];
    } else if ([cdObject isKindOfClass:[CDPhoneNumber class]]) {
        info.label = [NSString stringWithString:[cdObject typeLabel]];
        info.info = [NSString stringWithString:[cdObject number]];
    }


    return info;
}

- (CDEmail*) convertLaIToCDEmail {
    CDEmail* cdEmail = [NSEntityDescription insertNewObjectForEntityForName:@"CDEmail"
                                                     inManagedObjectContext:[[CDManager sharedManager]managedObjectContext]];
    cdEmail.typeLabel = self.label;
    cdEmail.email = self.info;
    return cdEmail;
}

- (CDPhoneNumber*) convertLaIToCDPhoneNumber {
    CDPhoneNumber* cdPhoneNumber = [NSEntityDescription insertNewObjectForEntityForName:@"CDPhoneNumber"
                                                     inManagedObjectContext:[[CDManager sharedManager]managedObjectContext]];
    cdPhoneNumber.typeLabel = self.label;
    cdPhoneNumber.number = self.info;
    return cdPhoneNumber;
}
@end
