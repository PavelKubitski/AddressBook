//
//  CDPhoneNumber.m
//  addressBook
//
//  Created by Pavel Kubitski on 15.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "CDPhoneNumber.h"
#import "CDPerson.h"


@implementation CDPhoneNumber

@dynamic number;
@dynamic typeLabel;
@dynamic person;

- (NSString *)description {
    NSString *descriptionString = [NSString stringWithFormat:@"Type: %@  number: %@ ", self.typeLabel, self.number];

    return descriptionString;
}


@end
