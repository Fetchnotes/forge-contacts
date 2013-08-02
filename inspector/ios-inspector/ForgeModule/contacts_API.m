#import "contacts_API.h"
#import <AddressBook/AddressBook.h>


@implementation contacts_API

// If the searchQuery is empty - copy the entire address book and load everything. Used for initial load of view.
// If searchQuery is nonempty - use just the queriedAddressBook because that doesn't need to copy the entire array.
+ (void)getContacts:(ForgeTask*)task Query:(NSString*)searchQuery Skip:(NSNumber*)skip Limit:(NSNumber*)limit {
    
    int startAt = [skip intValue];
    int amtToReturn = [limit intValue];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef queriedAddressBook = ABAddressBookCopyPeopleWithName(addressBook,
                                                        (__bridge CFStringRef)searchQuery);
    
    if ([searchQuery isEqual: @""]) {
        CFArrayRef addressBookCopy = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *matchedContacts = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(addressBookCopy)];

        int sizeOfTotalAddressBookCopy = CFArrayGetCount(addressBookCopy);
        if (sizeOfTotalAddressBookCopy == 0) {
            CFRelease(addressBook);
            CFRelease(addressBookCopy);
            CFRelease(queriedAddressBook);
            [task error:@"No entries in address book"];
        }
        
        int amtLeft = sizeOfTotalAddressBookCopy - startAt;
        
        if (amtLeft > 0) {
            if (amtToReturn > sizeOfTotalAddressBookCopy) {
                amtToReturn = sizeOfTotalAddressBookCopy;
            }
            if (amtLeft < amtToReturn) {
                amtToReturn = amtLeft;
            }
            
            int stopAt = amtToReturn + startAt;
            
            for (CFIndex i = startAt; i < stopAt; i++) {
                ABRecordRef person = CFArrayGetValueAtIndex(addressBookCopy, i);
                NSString * contactFirstName = (__bridge NSString *)ABRecordCopyValue( person, kABPersonFirstNameProperty);
                NSString * contactLastName = (__bridge NSString *)ABRecordCopyValue( person, kABPersonLastNameProperty);
                NSMutableArray *contactEmails = [[NSMutableArray alloc] init];
                NSMutableDictionary *contactPhoneNumbers = [[NSMutableDictionary alloc] init];
                
                ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                    NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                    [contactEmails addObject:email];
                    CFRelease((__bridge CFTypeRef)(email));
                }
                
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                for (CFIndex j=0; j< ABMultiValueGetCount(phoneNumbers); j++) {
                    NSString* number = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                    NSString* label = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                    [contactPhoneNumbers setObject:number forKey:label];
                    CFRelease((__bridge CFTypeRef)(number));
                    CFRelease((__bridge CFTypeRef)(label));
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
            CFRelease(addressBookCopy);
            CFRelease(queriedAddressBook);
            [task success:matchedContacts];
            
        } else {
            [task success:@"No more contacts to return"];
            CFRelease(addressBookCopy);
            CFRelease(queriedAddressBook);
        }
        
    } else {
        
        NSMutableArray *matchedContacts = [[NSMutableArray alloc] init];
        
        int sizeOfqueriedAddressBook = CFArrayGetCount(queriedAddressBook);
        if (sizeOfqueriedAddressBook == 0) {
            CFRelease(addressBook);
            CFRelease(queriedAddressBook);
            [task error:@"No entries in address book"];
        }
        
        int amtLeft = sizeOfqueriedAddressBook - startAt;
        
        if (amtLeft > 0) {
            if (amtToReturn > sizeOfqueriedAddressBook) {
                amtToReturn = sizeOfqueriedAddressBook;
            }
            if (amtLeft < amtToReturn) {
                amtToReturn = amtLeft;
            }
            
            int stopAt = amtToReturn + startAt;
        
            for (int i = startAt; i < stopAt; i++) {
                NSString * contactFirstName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(queriedAddressBook, i), kABPersonFirstNameProperty);
                NSString * contactLastName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(queriedAddressBook, i), kABPersonLastNameProperty);
                NSMutableDictionary *contactPhoneNumbers = [[NSMutableDictionary alloc] init];
                ABRecordRef person = CFArrayGetValueAtIndex(queriedAddressBook, i);
                NSMutableArray *contactEmails = [[NSMutableArray alloc] init];
                
                ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                    NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                    [contactEmails addObject:email];
                    CFRelease((__bridge CFTypeRef)(email));                
                }
                
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                for (CFIndex j=0; j< ABMultiValueGetCount(phoneNumbers); j++) {
                    NSString* number = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                    NSString* label = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                    [contactPhoneNumbers setObject:number forKey:label];
                    CFRelease((__bridge CFTypeRef)(number));
                    CFRelease((__bridge CFTypeRef)(label));
                }
                
                NSDictionary *contact = [NSDictionary
                                         dictionaryWithObjectsAndKeys:
                                         contactFirstName, @"firstName",
                                         contactLastName, @"lastName",
                                         contactEmails, @"email",
                                         contactPhoneNumbers,@"phone",
                                         nil];

                [matchedContacts addObject:contact];
                CFRelease(emails);
                CFRelease(phoneNumbers);
            }
        }
        
        if (queriedAddressBook != nil) {
            CFRelease(addressBook);
            [task success:matchedContacts];
        } else {
            CFRelease(addressBook);
            [task error:nil];
        }
    }
}

@end
