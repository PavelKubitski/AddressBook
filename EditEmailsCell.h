//
//  EditEmailsCell.h
//  addressBook
//
//  Created by Pavel Kubitski on 22.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const EditCellKeyboardWasShownNotification;

extern NSString* const SizeOfEditCellKeyboardWasShownInfoKey;
extern NSString* const FrameOfEditCellKeyboardWasShownInfoKey;



@interface EditEmailsCell : UITableViewCell <UITextFieldDelegate> 
    

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) NSIndexPath* indexpath;

@end
