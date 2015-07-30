//
//  EditCell.m
//  addressBook
//
//  Created by Pavel Kubitski on 22.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "EditNumberCell.h"

@implementation EditNumberCell

- (void)awakeFromNib {
    // Initialization code
    self.infoTextField.delegate = self;
//    NSLog(@"awakeFromNib");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//NSLog(@"setSelected");
    // Configure the view for the selected state
}

#pragma mark - setters 

- (void) setTextInTextField:(NSString*) string {

    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    NSString* resultString = [components componentsJoinedByString:@""];
    NSRange range = NSMakeRange(0, 0);
    [self textField:self.infoTextField shouldChangeCharactersInRange:range replacementString:resultString];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
//    NSLog(@"textField text = %@", textField.text);
//    NSLog(@"string = %@", string);
    
    
    
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        
        return NO;
    }
    
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    //+XX (XXX) XXX-XXXX

//    NSLog(@"new string = %@", newString);

    NSArray* validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];

    newString = [validComponents componentsJoinedByString:@""];
    
        // XXXXXXXXXXXX

//    NSLog(@"new string fixed = %@", newString);

    static const int localNumberMaxLength = 7;
    static const int areaCodeMaxLength = 2;
    static const int countryCodeMaxLength = 3;
    
        if ([newString length] > localNumberMaxLength + areaCodeMaxLength + countryCodeMaxLength) {
            return NO;
        }
    
    
        NSMutableString* resultString = [NSMutableString string];
    
        /*
         XXXXXXXXXXXX
         +XX (XXX) XXX-XXXX
         */
    
        NSInteger localNumberLength = MIN([newString length], localNumberMaxLength);
//    NSLog(@"localNumberLength = %ld", (long)localNumberLength);
    
        if (localNumberLength > 0) {
    
            NSString* number = [newString substringFromIndex:(int)[newString length] - localNumberLength];
            NSLog(@"number = %@", number);
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
    
//    NSLog(@"resultString = %@", resultString);
        textField.text = resultString;
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (![textField isFirstResponder]) {
        [textField becomeFirstResponder];
    }

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}




@end
