//
//  ServerManager.h
//  addressBook
//
//  Created by Pavel Kubitski on 08.08.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VKUser;

@interface ServerManager : NSObject


+ (ServerManager*) sharedManager;

- (void) authorizeUser:(void(^)(VKUser* user)) completion;

- (void) getFriendsWithOffset:(NSInteger) offset
                        count:(NSInteger) count
                    onSuccess:(void(^)(NSArray* friends)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getUser:(NSString*) userID
       onSuccess:(void(^)(VKUser* user)) success
       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;
@end
