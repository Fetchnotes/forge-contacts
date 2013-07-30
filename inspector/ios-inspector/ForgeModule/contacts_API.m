#import "contacts_API.h"
#import <AddressBook/AddressBook.h>


@implementation contacts_API

//
// Here you can implement your API methods which can be called from JavaScript
// an example method is included below to get you started.
//

// This will be callable from JavaScript as 'contacts.showAlert'
// it will require a parameter called text
+ (void)showAlert:(ForgeTask*)task text:(NSString *)text {
    // Fetch the address book
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    // Grab number of people
    int count = ABAddressBookGetPersonCount(addressBook);
    NSLog(@"count: %i", count);

    NSString *query = @"horak";
    
    // Grab people matching query
    CFArrayRef people = ABAddressBookCopyPeopleWithName(addressBook,
                                                        (__bridge CFStringRef)query);
    
    // Convert to Array & grab length
    NSMutableArray *dataCopy = [(__bridge NSArray *) people mutableCopy];
    NSUInteger length = [dataCopy count];
    NSLog(@"nums: %lu", (unsigned long)length);
    
    
    // Store values in array
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (int i = 0; i < length; i++) {
        NSString * lastName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(people, i), kABPersonLastNameProperty );
        NSString * firstName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(people, i), kABPersonFirstNameProperty );
        [data addObject:lastName];
        [data addObject:firstName];
    }
    
    
    if ((people != nil) && (CFArrayGetCount(people) > 0))
    {
        [task success:data];
    } else {
        // Show an alert if "Appleseed" is not in Contacts
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Could not find perons in the Contacts application"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
        [task error:nil];
    }
}

@end
