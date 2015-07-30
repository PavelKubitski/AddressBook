//
//  CDPhoneNumber.h
//  addressBook
//
//  Created by Pavel Kubitski on 25.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDObject.h"

@class CDPerson;

@interface CDPhoneNumber : CDObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * typeLabel;
@property (nonatomic, retain) CDPerson *person;

@end
