//
//  NSString+PhoneNumber_.m
//  addressBook
//
//  Created by Pavel Kubitski on 19.07.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "NSString+PhoneNumber.h"

@implementation NSString (PhoneNumber)

- (NSString*) makeNumberFromString{
    NSString* string = self;
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    NSString* newString = [components componentsJoinedByString:@""];
    
    static const int localNumberMaxLength = 7;
    static const int areaCodeMaxLength = 2;
    static const int countryCodeMaxLength = 3;
    
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
    
    return resultString;
}




-(NSString*) makeValidAddressFromString {
    NSString* string = self;
    NSArray* locationAndDescription;
    NSMutableString* validAddress = [[NSMutableString alloc] init];
    NSArray* componentsOfLocations = [string makeArrayOfLocationsAndDescriptions];
    for (NSString* component in componentsOfLocations) {
        locationAndDescription = [component componentsSeparatedByString:@"-"];
        [validAddress appendString:[locationAndDescription lastObject]];
        [validAddress appendString:@" "];
    }
    return validAddress;
}

- (NSArray*) makeArrayOfLocationsAndDescriptions {
    NSString* string = self;
    NSArray* componentsOfLocations = [string componentsSeparatedByString:@"_"];
    return componentsOfLocations;
}


@end
