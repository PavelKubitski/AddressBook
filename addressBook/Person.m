//
//  Person.m
//  addressBook
//
//  Created by Pavel Kubitski on 15.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "Person.h"
#import "CDPerson.h"
#import "LabelAndInfo.h"

@implementation Person

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.firstName = @"";
        self.lastName = @"";
        self.companyName = @"";
        self.address = @"";
//        self.image = [[UIImage alloc] init];
        self.emails = [[NSMutableArray alloc] init];
        self.numbers = [[NSMutableArray alloc] init];
        self.annotations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)description {
    NSString *descriptionString = [NSString stringWithFormat:@"Name: %@  lastname: %@ ", self.firstName, self.lastName];
    return descriptionString;
    
}





@end
