//
//  Person.h
//  addressBook
//
//  Created by Pavel Kubitski on 15.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CDPerson;

@interface Person : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *birthdayDate;
@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) NSMutableArray *emails;
@property (nonatomic, strong) NSMutableArray *numbers;
@property (nonatomic, strong) NSMutableArray *annotations;


@property (nonatomic, strong) UIImage *image;


@end
