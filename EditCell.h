//
//  EditEmailsCell.h
//  addressBook
//
//  Created by Pavel Kubitski on 22.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const EditCellKeyboardWasShownNotification;
extern NSString* const EditCellKeyboardWillDisappearNotification;
extern NSString* const DragingScrollViewBeganNotification;
extern NSString* const TypeLabelTouchedNotification;
extern NSString* const TextFieldDidEndEditingNotification;

extern NSString* const SizeOfKeyboardWasShownInfoKey;
extern NSString* const FrameOfEditCellKeyboardWasShownInfoKey;
extern NSString* const TypeLabelTouchedAtIndexPathInfoKey;
extern NSString* const InfoTextInfoKey;
extern NSString* const OldInfoTextInfoKey;
extern NSString* const TypeLabelInfoKey;
extern NSString* const IndexPathInfoKey;

@interface EditCell : UITableViewCell <UITextFieldDelegate> 
    

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *infoTextField;
@property (strong, nonatomic) NSIndexPath* indexpath;
@property (strong, nonatomic) NSString* oldInfoInTextField;




@end
