//
//  VKUser.m
//  addressBook
//
//  Created by Pavel Kubitski on 08.08.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "VKUser.h"

@implementation VKUser

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super init];
    if (self) {
        
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        
        NSString* urlString = [responseObject objectForKey:@"photo_200_orig"];
        
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}

@end
