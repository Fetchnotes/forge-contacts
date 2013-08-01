#import "contacts_API.h"
#import <AddressBook/AddressBook.h>


@implementation contacts_API

// If the searchQuery is empty - copy the entire address book and load everything. Used for initial load of view.
// If searchQuery is nonempty - use just the queriedAddressBook because that doesn't need to copy the entire array.
+ (void)getContacts:(ForgeTask*)task Query:(NSString*)searchQuery Skip:(NSNumber*)skip Limit:(NSNumber*)limit {
    
    int skipNum = [skip intValue];
    int limitNum = [limit intValue];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef queriedAddressBook = ABAddressBookCopyPeopleWithName(addressBook,
                                                        (__bridge CFStringRef)searchQuery);
    NSUInteger queriedAddressBookSize = CFArrayGetCount(queriedAddressBook);
    
    if (queriedAddressBookSize == 0) {
        CFArrayRef addressBookCopy = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *matchedContacts = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(addressBookCopy)];
        
        for (CFIndex i = skipNum; i < limitNum; i++) {
            ABRecordRef person = CFArrayGetValueAtIndex(addressBookCopy, i);
            NSString * contactFirstName = (__bridge NSString *)ABRecordCopyValue( person, kABPersonFirstNameProperty);
            NSString * contactLastName = (__bridge NSString *)ABRecordCopyValue( person, kABPersonLastNameProperty);
            NSMutableArray *contactEmails = [[NSMutableArray alloc] init];
            NSMutableDictionary *contactPhoneNumbers = [[NSMutableDictionary alloc] init];
            
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                [contactEmails addObject:email];
            }

            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (CFIndex j=0; j< ABMultiValueGetCount(phoneNumbers); j++) {
                NSString* number = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                NSString* label = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                [contactPhoneNumbers setObject:number forKey:label];
            }
            
            
            NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:
                                            contactEmails, @"emails",
                                            contactFirstName, @"firstName",
                                            contactLastName, @"lastName",
                                            contactPhoneNumbers, @"mobile",
                                            nil];
            
            [matchedContacts addObject:contact];
            
            CFRelease(emails);
            CFRelease(phoneNumbers);
        }
        CFRelease(addressBook);
        CFRelease(addressBookCopy);
        
        [task success:matchedContacts];
        
    } else {
        
        NSMutableArray *matchedContacts = [[NSMutableArray alloc] init];
        
        for (int i = skipNum; i < limitNum; i++) {
            ABRecordRef person = CFArrayGetValueAtIndex(queriedAddressBook, i);
            NSString * contactFirstName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(queriedAddressBook, i), kABPersonFirstNameProperty);
            NSString * contactLastName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(queriedAddressBook, i), kABPersonLastNameProperty);
            NSMutableArray *contactEmails = [[NSMutableArray alloc] init];
    //        NSString * email = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(people, i), kABPersonEmailProperty );
    //        NSString * phone = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(people, i), kABPersonPhoneProperty );
    //        [data addObject:firstName];
    //        [data addObject:lastName];
    //        [data addObject:email];
    //        [data addObject:phone];
    //        NSLog(@"firstName: %@",firstName);
    //        NSLog(@"lastName: %@",lastName);
    //        NSLog(@"email: %@",email);
    //        NSLog(@"phone: %@",phone);
            
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                [contactEmails addObject:email];
            }
            
            NSDictionary *contact = [NSDictionary
                                     dictionaryWithObjectsAndKeys:
                                     contactFirstName, @"firstName",
                                     contactLastName, @"lastName",
                                     contactEmails, @"email",
    //                                 phone,@"phone",
                                     nil];
    //        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:setUser
    //                                                           options:NSJSONWritingPrettyPrinted error:nil];

            [matchedContacts addObject:contact];
        }
        
        
        if ((queriedAddressBook != nil) && (CFArrayGetCount(queriedAddressBook) > 0))
        {
            [task success:matchedContacts];
        } else {
            // Show an alert if "Appleseed" is not in Contacts
            [task error:nil];
        }
    }
}

@end
