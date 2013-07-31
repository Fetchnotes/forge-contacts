#import "contacts_API.h"
#import <AddressBook/AddressBook.h>


@implementation contacts_API

//
// Here you can implement your API methods which can be called from JavaScript
// an example method is included below to get you started.
//

// This will be callable from JavaScript as 'contacts.showAlert'
// it will require a parameter called text
+ (void)getContacts:(ForgeTask*)task Query:(NSString*)searchQuery Skip:(NSNumber*)skip Limit:(NSNumber*)limit {
    
    int skipNum = [skip intValue];
    int limitNum = [limit intValue];
    
    // Grab the entire address book
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    // Grab queriedAddressBook & size
    CFArrayRef queriedAddressBook = ABAddressBookCopyPeopleWithName(addressBook,
                                                        (__bridge CFStringRef)searchQuery);
    NSUInteger queriedAddressBookSize = CFArrayGetCount(queriedAddressBook);
    NSLog(@"Size of queriedAddressBook: %lu", (unsigned long)queriedAddressBookSize);
    
    // If the searchQuery is empty - load everything. Usually on initial load of view.
    // If there is something in searchQuery - use just the queriedAddressBook because that doesn't need to copy the entire array.
    if (queriedAddressBookSize == 0) {
        CFArrayRef addressBookCopy = ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        NSMutableArray *allEmails = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(addressBookCopy)];
        
        for (CFIndex i = skipNum; i < limitNum; i++) {
            ABRecordRef person = CFArrayGetValueAtIndex(addressBookCopy, i);
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                [allEmails addObject:email];
            }
            CFRelease(emails);
        }
        CFRelease(addressBook);
        CFRelease(addressBookCopy);
        
        [task success:allEmails];
        
    } else {
        
        NSMutableArray *data = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < queriedAddressBookSize; i++) {
            NSString * firstName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(queriedAddressBook, i), kABPersonFirstNameProperty);
            NSString * lastName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(queriedAddressBook, i), kABPersonLastNameProperty);
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
            
            // Create JSON object
            NSDictionary *setUser = [NSDictionary
                                     dictionaryWithObjectsAndKeys:firstName,@"firstName",
                                     lastName,@"lastName",
    //                                 email,@"email",
    //                                 phone,@"phone",
                                     nil];
    //        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:setUser
    //                                                           options:NSJSONWritingPrettyPrinted error:nil];

            NSLog(@"jsonData%@", setUser);
            [data addObject:setUser];
        }
        
        
        if ((queriedAddressBook != nil) && (CFArrayGetCount(queriedAddressBook) > 0))
        {
            [task success:data];
        } else {
            // Show an alert if "Appleseed" is not in Contacts
            [task error:nil];
        }
    }
}

@end
