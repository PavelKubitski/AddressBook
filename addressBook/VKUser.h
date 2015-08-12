//
//  VKUser.h
//  addressBook
//
//  Created by Pavel Kubitski on 08.08.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKUser : NSObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSURL* imageURL;

- (id) initWithServerResponse:(NSDictionary*) responseObject;

@end
