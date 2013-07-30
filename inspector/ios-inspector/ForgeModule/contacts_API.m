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

    NSString *query = @"hor";
    
    // Grab people matching query
    CFArrayRef people = ABAddressBookCopyPeopleWithName(addressBook,
                                                        (__bridge CFStringRef)query);
    
    // Convert to Array & grab length
    NSMutableArray *dataCopy = [(__bridge NSArray *) people mutableCopy];
    NSUInteger length = [dataCopy count];
    NSLog(@"nums: %lu", (unsigned long)length);
    
    // Store results in array
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (int i = 0; i < length; i++) {
        NSString * firstName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(people, i), kABPersonFirstNameProperty);
        NSString * lastName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex(people, i), kABPersonLastNameProperty);
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
