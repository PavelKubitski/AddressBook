//
//  EditContactTableView.h
//  addressBook
//
//  Created by Pavel Kubitski on 17.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "ViewContactTableView.h"

extern NSString* const SizeOfTableViewChangedNotification;

extern NSString* const OperationInfoKey;



@interface EditContactTableView : ViewContactTableView 



@property (strong, nonatomic) NSIndexPath* indexpath;

- (void) changeTypeLabelWithLabel:(NSString*) newLabel atIndexPath:(NSIndexPath*) indexPath;

@end
