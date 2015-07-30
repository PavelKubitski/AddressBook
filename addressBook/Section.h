//
//  Section.h
//  addressBook
//
//  Created by Pavel Kubitski on 05.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Section : NSObject

@property (strong, nonatomic) NSString* sectionName;
@property (strong, nonatomic) NSMutableArray* itemsArray;

@end
