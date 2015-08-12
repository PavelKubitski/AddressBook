//
//  AccessToken.h
//  addressBook
//
//  Created by Pavel Kubitski on 12.08.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject

@property (strong, nonatomic) NSString* token;
@property (strong, nonatomic) NSDate* expirationDate;
@property (strong, nonatomic) NSString* userID;

@end
