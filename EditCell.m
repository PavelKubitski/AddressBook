//
//  EditEmailsCell.m
//  addressBook
//
//  Created by Pavel Kubitski on 22.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "EditCell.h"


NSString* const DragingScrollViewBeganNotification = @"DragingScrollViewBeganNotification";
NSString* const EditCellKeyboardWasShownNotification = @"EditCellKeyboardWasShownNotification";
NSString* const EditCellKeyboardWillDisappearNotification = @"EditCellKeyboardWillDisappearNotification";
NSString* const TypeLabelTouchedNotification = @"TypeLabelTouchedNotification";
NSString* const TextFieldDidEndEditingNotification = @"TextFieldDidEndEditingNotification";

NSString* const SizeOfKeyboardWasShownInfoKey = @"SizeOfEditCellKeyboardWasShownInfoKey";
NSString* const FrameOfEditCellKeyboardWasShownInfoKey = @"FrameOfEditCellKeyboardWasShownInfoKey";
NSString* const TypeLabelTouchedAtIndexPathInfoKey = @"TypeLabelTouchedAtIndexPathInfoKey";
NSString* const InfoTextInfoKey = @"InfoTextInfoKey";
NSString* const OldInfoTextInfoKey = @"OldInfoTextInfoKey";
NSString* const TypeLabelInfoKey = @"TypeLabelInfoKey";
NSString* const IndexPathInfoKey = @"IndexPathInfoKey";


@implementation EditCell

- (void)awakeFromNib {
    // Initialization code
    
    
    self.infoTextField.delegate = self;
    
    self.indexpath = nil;
    
    [self addObservers];
    
    [self.typeLabel setUserInteractionEnabled:YES];
    [self.typeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchedTypeLabel:)]];
}




- (void)dealloc
{
    [self removeObservers];
}



#pragma mark - touches

- (void)touchedTypeLabel:(UIGestureRecognizer *)gesture {
    [self initIndexpathOfSelectCell];
//    NSLog(@"sect = %ld, row = %ld", self.indexpath.section, self.indexpath.row);
    NSDictionary* dc = [[NSDictionary alloc] initWithObjectsAndKeys:self.indexpath, TypeLabelTouchedAtIndexPathInfoKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TypeLabelTouchedNotification
                                                        object:nil
                                                      userInfo:dc];
}




#pragma mark - keyboard

- (void)keyboardWasShown:(NSNotification*)notification {
    if (self.indexpath) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSDictionary* info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

        CGRect cellFrame = [self convertRect:self.bounds toView:nil];
        
        NSValue* valueSize = [NSValue valueWithCGSize:kbSize];
        [dictionary setObject:valueSize forKey:SizeOfKeyboardWasShownInfoKey];
        NSValue* valueFrame = [NSValue valueWithCGRect:cellFrame];
        [dictionary setObject:valueFrame forKey:FrameOfEditCellKeyboardWasShownInfoKey];

        [[NSNotificationCenter defaultCenter] postNotificationName:EditCellKeyboardWasShownNotification
                                                            object:nil
                                                          userInfo:dictionary];
        self.indexpath = nil;
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if ([self.infoTextField isFirstResponder]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EditCellKeyboardWillDisappearNotification
                                                            object:nil
                                                          userInfo:nil];
    }
}



- (void)dragingScrollViewBegan:(NSNotification*)notification {

    [self initIndexpathOfSelectCell];
    if (self.indexpath.section == 0) {
        if ([self.infoTextField isFirstResponder]) {
            [self.infoTextField resignFirstResponder];
        }
    }
}



#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self initIndexpathOfSelectCell];
    self.infoTextField.keyboardAppearance = UIKeyboardAppearanceLight;

    if (self.indexpath.section == 0) {
        if (range.length == 1) {
            
        }
        
        self.infoTextField.keyboardType = UIKeyboardTypePhonePad;

        NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
        
        if ([components count] > 1) {
            return NO;
        }

        NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

        NSArray* validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
        
        newString = [validComponents componentsJoinedByString:@""];
        

        
        static const int localNumberMaxLength = 7;
        static const int areaCodeMaxLength = 2;
        static const int countryCodeMaxLength = 3;
        
        if ([newString length] > localNumberMaxLength + areaCodeMaxLength + countryCodeMaxLength) {
            return NO;
        }
        
        NSMutableString* resultString = [NSMutableString string];
        
        NSInteger localNumberLength = MIN([newString length], localNumberMaxLength);
        
        if (localNumberLength > 0) {
            
            NSString* number = [newString substringFromIndex:(int)[newString length] - localNumberLength];

            [resultString appendString:number];
            
            if ([resultString length] > 3) {
                [resultString insertString:@"-" atIndex:3];
            }
            if ([resultString length] > 6) {
                [resultString insertString:@"-" atIndex:6];
            }
            
        }
        
        if ([newString length] > localNumberMaxLength) {
            
            NSInteger areaCodeLength = MIN((int)[newString length] - localNumberMaxLength, areaCodeMaxLength);
            
            NSRange areaRange = NSMakeRange((int)[newString length] - localNumberMaxLength - areaCodeLength, areaCodeLength);
            
            NSString* area = [newString substringWithRange:areaRange];
            
            area = [NSString stringWithFormat:@"(%@) ", area];
            
            [resultString insertString:area atIndex:0];
        }
        
        if ([newString length] > localNumberMaxLength + areaCodeMaxLength) {
            
            NSInteger countryCodeLength = MIN((int)[newString length] - localNumberMaxLength - areaCodeMaxLength, countryCodeMaxLength);
            
            NSRange countryCodeRange = NSMakeRange(0, countryCodeLength);
            
            NSString* countryCode = [newString substringWithRange:countryCodeRange];
            
            countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
            
            [resultString insertString:countryCode atIndex:0];
        }
        
        
        textField.text = resultString;
        return NO;

        
        
    } else if (self.indexpath.section == 1) {
        
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        return YES;
    }
    return nil;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {

    [self initIndexpathOfSelectCell];

    if (self.indexpath.row != 0) {
        if (![textField isFirstResponder]) {
            [textField becomeFirstResponder];
        }
        [textField becomeFirstResponder];
        if (self.indexpath.section == 0) {
            
            textField.keyboardType = UIKeyboardTypePhonePad;
        } else if (self.indexpath.section == 1) {
            textField.keyboardType = UIKeyboardTypeEmailAddress;
        }
        self.oldInfoInTextField = textField.text;

    } else {
        textField.enabled = NO;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}



- (void)textFieldDidEndEditing:(UITextField *)textField {
//    NSLog(@"textFieldDidEndEditing");


    [self initIndexpathOfSelectCell];
    NSDictionary* dc = @{InfoTextInfoKey: textField.text, IndexPathInfoKey: self.indexpath, OldInfoTextInfoKey: self.oldInfoInTextField};
    
        [[NSNotificationCenter defaultCenter] postNotificationName:TextFieldDidEndEditingNotification
                                                            object:nil
                                                          userInfo:dc];
        


    
}





#pragma mark - init indexPath
- (void) initIndexpathOfSelectCell {
    UITableView* tv = (UITableView *)self.superview.superview ;
    self.indexpath = nil;
    self.indexpath = [tv indexPathForCell:self];
}

#pragma mark - manage notifications

- (void) addObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(keyboardWasShown:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(keyboardWillBeHidden:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(dragingScrollViewBegan:)
               name:DragingScrollViewBeganNotification
             object:nil];
}

- (void) removeObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:UIKeyboardWillShowNotification
                object:nil];
    
    [nc removeObserver:self
                  name:UIKeyboardWillHideNotification
                object:nil];
    
    [nc removeObserver:self
                  name:DragingScrollViewBeganNotification
                object:nil];
}


@end
