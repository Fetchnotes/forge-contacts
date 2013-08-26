#import "contacts_API.h"
#import <AddressBook/AddressBook.h>


@implementation contacts_API

// If searchQuery is nonempty - use just the queriedAddressBook because that doesn't need to copy the entire array.
+ (void)getContacts:(ForgeTask*)task Query:(NSString*)searchQuery Skip:(NSNumber*)skip Limit:(NSNumber*)limit {
    
    int startAt = [skip intValue];
    int amtToReturn = [limit intValue];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef queriedAddressBook = ABAddressBookCopyPeopleWithName(addressBook,
                                                        (__bridge CFStringRef)searchQuery);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
            
        NSMutableArray *matchedContacts = [[NSMutableArray alloc] init];
        
        int sizeOfqueriedAddressBook = CFArrayGetCount(queriedAddressBook);
        if (sizeOfqueriedAddressBook == 0) {
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
            [task success:matchedContacts];
            CFRelease(queriedAddressBook);
        } else {
            CFRelease(addressBook);
            [task error:nil];
        }
    }
    
    else if (accessGranted == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Want to share notes with people who don't use Fetchnotes? We'll need access to your contacts. Don't worry, we'll never share anything without your permission.\n\n1) Open up the 'Settings' app\n2) Tap on 'Privacy'\n3) Tap 'Contacts'\n4) Find Fetchnotes on the list and switch the toggle to 'On'\n"
                                                       delegate:nil
                                              cancelButtonTitle:@"Got it"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
