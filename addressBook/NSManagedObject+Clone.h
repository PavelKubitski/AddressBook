//
//  NSManagedObject+Clone.h
//  addressBook
//
//  Created by Pavel Kubitski on 22.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Clone)


-(NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context withCopiedCache:(NSMutableDictionary *)alreadyCopied exludeEntities:(NSArray *)namesOfEntitiesToExclude;
-(NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context exludeEntities:(NSArray *)namesOfEntitiesToExclude;
-(NSManagedObject *) clone;


@end
