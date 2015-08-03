//
//  LabelAndInfo.h
//  addressBook
//
//  Created by Pavel Kubitski on 06.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CDPhoneNumber;
@class CDEmail;

@interface LabelAndInfo : NSObject

@property (strong, nonatomic) NSString* label;
@property (strong, nonatomic) NSString* info;

- (LabelAndInfo*) initWithCDObject:(CDEmail*) cdObject;
- (CDEmail*) convertLaIToCDEmail;
- (CDPhoneNumber*) convertLaIToCDPhoneNumber;

@end
