//
//  ABManager.m
//  addressBook
//
//  Created by Pavel Kubitski on 15.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "ABManager.h"
#import "Person.h"
#import "LabelAndInfo.h"
#import "CDPerson.h"
#import "CDPhoneNumber.h"
#import "CDEmail.h"
#import "CDCoordinate.h"
#import "NSString+PhoneNumber.h"






NSString* const ABManagerDidChangeAddressBookNotification = @"ABManagerDidChangeAddressBookNotification";
NSString* const ABManagerCanReadAfterPermisionAddressBookNotification = @"ABManagerCanReadAfterPermisionAddressBookNotification";

NSString* const ABManagerDidChangeAddressBookInfoKey = @"AABManagerDidChangeAddressBookInfoKey";
NSString* const ABManagerKindOfChangeInfoKey = @"ABManagerKindOfChangeInfoKey";
NSString* const ABManagerCanReadAfterPermisionAddressBookInfoKey = @"ABManagerCanReadAfterPermisionAddressBookInfoKey";




@implementation ABManager



- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.arrayOfPersons = [[NSMutableArray alloc] init];
        CFErrorRef error = NULL;
        self.addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        if (error) {
            CFRelease(error);
        }
    }
    return self;
}

+ (ABManager*) sharedBook {
    

    static ABManager* abManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        abManager = [[ABManager alloc] init];
    });
    
    return abManager;
}

- (void)dealloc
{
    if (self.addressBook) {
        CFRelease(self.addressBook);
    }
}

- (NSMutableArray *) allPersonsAddPerson:(BOOL) addPerson
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        if (!addPerson) {
            [self fillPersonsArray];
        }
        
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){

                    UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                    [cantAddContactAlert show];
                    return;
                }
            if (!addPerson) {
                [self fillPersonsArray];
                [self canReadAfterPermision];
            }
                
            });
        });
        
    }

    return self.arrayOfPersons;
}

- (void) canReadAfterPermision {
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    NSArray* newPersons = [[NSArray alloc] initWithArray:self.arrayOfPersons];

    [dictionary setObject:@"Append" forKey:ABManagerKindOfChangeInfoKey];
    [dictionary setObject:newPersons forKey:ABManagerDidChangeAddressBookInfoKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ABManagerDidChangeAddressBookNotification
                                                        object:nil
                                                      userInfo:dictionary];

}




- (void) fillPersonsArray
{

    [self.arrayOfPersons removeAllObjects];

    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(self.addressBook);

    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(self.addressBook);
    NSArray *emailArray;
    NSArray *phoneArray;
    
    for(int i = 0; i < numberOfContacts; i++){
        Person* person = [[Person alloc] init];
        
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        ABMultiValueRef companyProperty = ABRecordCopyValue(aPerson, kABPersonOrganizationProperty);
        ABMultiValueRef birthdayProperty = ABRecordCopyValue(aPerson, kABPersonBirthdayProperty);
        ABMultiValueRef addressProperty = ABRecordCopyValue(aPerson, kABPersonAddressProperty);
        
        ABMultiValueRef phoneProperty = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        if (emailProperty) {
            emailArray = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);
            CFRelease(emailProperty);
        }
        if (phoneProperty) {
            phoneArray = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
            CFRelease(phoneProperty);
        }
        CFDataRef cfImage = ABPersonCopyImageData(aPerson);
        UIImage *img = [UIImage imageWithData:(__bridge NSData *)cfImage];
        if (cfImage) {
            CFRelease(cfImage);
        }
        person.image = img;

        if (fnameProperty != nil) {
            person.firstName = [NSString stringWithFormat:@"%@", fnameProperty];
            CFRelease(fnameProperty);
        }
        if (lnameProperty != nil) {
            person.lastName = [NSString stringWithFormat:@"%@", lnameProperty];
            CFRelease(lnameProperty);
        }
        if (companyProperty != nil) {
            person.companyName = [NSString stringWithFormat:@"%@", companyProperty];
            CFRelease(companyProperty);
        }
        if (birthdayProperty != nil) {
            person.birthdayDate = [NSString stringWithFormat:@"%@", birthdayProperty];
            CFRelease(birthdayProperty);
        }
        if (addressProperty != nil) {
            if (ABMultiValueGetCount(addressProperty) > 0) {
                CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(addressProperty, 0);
                NSString* street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
                    if(!street) street = @"";
                NSString* city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
                    if(!city) city = @"";
                NSString* country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);
                    if(!country) country = @"";
                NSString* countryCode = CFDictionaryGetValue(dict, kABPersonAddressCountryCodeKey);
                    if(!countryCode) countryCode = @"";
                person.address = [NSString stringWithFormat:@"str.-%@_city.-%@_country.-%@_countryCode.-%@", street, city, country, countryCode];
                CFRelease(dict);
            }
            CFRelease(addressProperty);
        }


        for (int i = 0; i < [emailArray count]; i++) {
            LabelAndInfo* email = [[LabelAndInfo alloc] init];
            email.info = emailArray[i];
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(emailProperty, i);
            email.label = (__bridge_transfer NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
            
            [person.emails addObject:email];
            CFRelease(locLabel);
        }
        
        for (int i = 0; i < [phoneArray count]; i++) {
            LabelAndInfo* number = [[LabelAndInfo alloc] init];
            number.info = phoneArray[i];
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phoneProperty, i);
            number.label = (__bridge_transfer NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
            
            [person.numbers addObject:number];
            CFRelease(locLabel);
        }
        [self.arrayOfPersons addObject:person];
        if (aPerson) {
            CFRelease(aPerson);
        }

    }


}

- (void) deletePerson:(CDPerson*) personToRemove {
    
    long count = ABAddressBookGetPersonCount(self.addressBook);
    if(count == 0 && self.addressBook != NULL) { //If there are no contacts, don't delete
        return;
    }
    ABRecordRef person = [self findPerson:personToRemove];

    BOOL result = ABAddressBookRemoveRecord (self.addressBook, person, NULL); //remove it

    if(result == YES) {
        BOOL save = ABAddressBookSave(self.addressBook, NULL); //save address book state
        if(save == YES && person != NULL) {
            NSLog(@"OK");
        } else {
            NSLog(@"Couldn't save, breaking out");
        }
    } else {
        NSLog(@"Couldn't delete, breaking out");
    }

}

- (ABRecordRef) findPerson:(CDPerson*) person {
    CFErrorRef *error = NULL;
    ABRecordRef pers = nil;
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    long peopleCount = CFArrayGetCount(allPeople);
    for (int i = 0; i < peopleCount; i++){
        
        pers = CFArrayGetValueAtIndex(allPeople, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(pers, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(pers, kABPersonLastNameProperty);
        if (!fnameProperty) {
            fnameProperty = @"";
        }
        if (!lnameProperty) {
            lnameProperty = @"";
        }
        if ([person.firstName isEqualToString:(__bridge NSString *)(fnameProperty)] &&
            [person.lastName isEqualToString:(__bridge NSString *)(lnameProperty)]) {
            error = nil;
            
            break;
        }
        pers = nil;
        if (fnameProperty) {
            CFRelease(fnameProperty);
        }
        if (lnameProperty) {
            CFRelease(lnameProperty);
        }
    }
    if (allPeople) {
        CFRelease(allPeople);
    }
    if (error) {
        CFRelease(error);
    }

    
    return pers;
}





- (void) updateAdressBookPerson:(CDPerson*) person withPerson:(CDPerson*) newPers{
        CFErrorRef *error = NULL;
        ABMultiValueIdentifier identifier;
        ABRecordRef pers = nil;
        CFStringRef keys[4];
        CFStringRef values[4];
        keys[0] = kABPersonAddressStreetKey;
        keys[1] = kABPersonAddressCityKey;
        keys[2] = kABPersonAddressCountryKey;
        keys[3] = kABPersonAddressCountryCodeKey;

    
        if (person) {
            pers = [self findPerson:person];
        } else {
            pers = ABPersonCreate();
        }
    
        if (pers) {
    
            ABRecordSetValue(pers, kABPersonFirstNameProperty, CFBridgingRetain(newPers.firstName), error);
            ABRecordSetValue(pers, kABPersonLastNameProperty, CFBridgingRetain(newPers.lastName), error);
            ABRecordSetValue(pers, kABPersonOrganizationProperty, CFBridgingRetain(newPers.companyName), error);
            
            ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            ABMutableMultiValueRef multiEmails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABDictionaryPropertyType);
            
            if ([newPers.coordinate count] != 0) {
                NSArray* coordinates = [newPers.coordinate allObjects];
                for (int i = 0; i < [newPers.coordinate count]; i++) {
                    CDCoordinate* coordinate = [coordinates objectAtIndex:i];
                    NSArray* components = [coordinate.fullAddress makeArrayOfLocationsAndDescriptions];
                    int j = 0;
                    for (NSString* component in components) {
                        NSArray* lad = [component componentsSeparatedByString:@"-"];
                        values[j] = (__bridge CFTypeRef)[lad lastObject];
                        j++;
                    }
                }
                CFDictionaryRef dict = CFDictionaryCreate(NULL, (const void **)keys, (const void **)values, 4, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                ABMultiValueAddValueAndLabel(address, dict, kABHomeLabel, &identifier);
                CFRelease(dict);
            }

            
            NSArray* numbers = [newPers.phoneNumber allObjects];
            for (int i = 0; i < [newPers.phoneNumber count]; i++) {
                CDPhoneNumber* number = [numbers objectAtIndex:i];
                ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number.number), [self returnNumbersTypeLabels:number.typeLabel], NULL);
            }
            NSArray* emails = [newPers.email allObjects];
            for (int i = 0; i < [newPers.email count]; i++) {
                CDEmail* email = [emails objectAtIndex:i];
                ABMultiValueAddValueAndLabel(multiEmails, (__bridge CFTypeRef)(email.email), [self returnEmailsTypeLabels:email.typeLabel], NULL);
            }
            

        
            ABRecordSetValue(pers, kABPersonAddressProperty, address, nil);
            ABRecordSetValue(pers, kABPersonPhoneProperty, multiPhone, nil);
            ABRecordSetValue(pers, kABPersonEmailProperty, multiEmails, nil);
    
            if (!person) {
                ABAddressBookAddRecord(self.addressBook, pers, error);
            }
            if (multiEmails) {
                CFRelease(multiEmails);
            }
            if (multiPhone) {
                CFRelease(multiPhone);
            }
            if (address) {
                CFRelease(address);
            }
    
            ABAddressBookSave(self.addressBook, error);

        }



    
        if (error != NULL)
        {
            CFStringRef errorDesc = CFErrorCopyDescription(*error);
            NSLog(@"Contact not saved: %@", errorDesc);
            CFRelease(errorDesc);
            CFRelease(error);
        }
    
}



-(CFStringRef) returnNumbersTypeLabels:(NSString*) type {
    if ([type isEqualToString:@"home"]) {
        return kABHomeLabel;
    }
    if ([type isEqualToString:@"work"]) {
        return kABWorkLabel;
    }
    if ([type isEqualToString:@"work fax"]) {
        return kABPersonPhoneWorkFAXLabel;
    }
    if ([type isEqualToString:@"other"]) {
        return kABOtherLabel;
    }
    if ([type isEqualToString:@"pager"]) {
        return kABPersonPhonePagerLabel;
    }
    if ([type isEqualToString:@"main"]) {
        return kABPersonPhoneMainLabel;
    }
    if ([type isEqualToString:@"iPhone"]) {
        return kABPersonPhoneIPhoneLabel;
    }
    if ([type isEqualToString:@"home fax"]) {
        return kABPersonPhoneHomeFAXLabel;
    }
    if ([type isEqualToString:@"mobile"]) {
        return kABPersonPhoneMobileLabel;
    }
    return kABOtherLabel;
}

-(CFStringRef) returnEmailsTypeLabels:(NSString*) type {
    if ([type isEqualToString:@"home"]) {
        return (__bridge CFStringRef)(type);
    }
    if ([type isEqualToString:@"work"]) {
        return (__bridge CFStringRef)(type);
    }
    if ([type isEqualToString:@"iCloud"]) {
        return (__bridge CFStringRef)(type);
    }
    if ([type isEqualToString:@"other"]) {
        return (__bridge CFStringRef)(type);
    }
    return (__bridge CFStringRef)@"";
}

@end
