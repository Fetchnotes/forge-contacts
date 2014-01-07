#import "contacts_API.h"
#import <AddressBook/AddressBook.h>
#import <JBDeviceOwner.h>

@implementation contacts_API

+ (void)getContactsInstructions:(ForgeTask*)task {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hi there!"
                                                    message:@"Want to share notes with people who don't use Fetchnotes? We'll need access to your contacts. Don't worry, we never share without your permission.\n\n1) Open up the 'Settings' app\n2) Tap on 'Privacy'\n3) Tap 'Contacts'\n4) Go to Fetchnotes, and switch the toggle to 'On'"
                                                   delegate:self
                                          cancelButtonTitle:@"Got it"
                                          otherButtonTitles:nil];
    
    [alert show];
}

//- (NSString *)encodeToBase64String:(UIImage *)image {
//    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//}
//
//- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
//    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    return [UIImage imageWithData:data];
//}

+ (void)getContacts:(ForgeTask*)task Query:(NSString*)searchQuery Skip:(NSNumber*)skip Limit:(NSNumber*)limit {
    
    dispatch_queue_t queue;
    
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
    
        CFErrorRef myError = NULL;
        __block int startAt = [skip intValue];
        __block int amtToReturn = [limit intValue];
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &myError);
        
        ABAddressBookRequestAccessWithCompletion(addressBook,
         ^(bool granted, CFErrorRef error) {
             if (granted) {
                 NSArray *queriedAddressBook = CFBridgingRelease(
                                                        ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)(searchQuery))
                                                        );
                 NSMutableArray *matchedContacts = [[NSMutableArray alloc] init];
                 
                 int sizeOfqueriedAddressBook = CFArrayGetCount((__bridge CFArrayRef)(queriedAddressBook));
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
                         NSString *contactFirstName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex((__bridge CFArrayRef)(queriedAddressBook), i), kABPersonFirstNameProperty);
                         NSString *contactLastName = (__bridge NSString *)ABRecordCopyValue( CFArrayGetValueAtIndex((__bridge CFArrayRef)(queriedAddressBook), i), kABPersonLastNameProperty);
                         
                         if ([contactFirstName length] == 0) contactFirstName = @"";
                         if ([contactLastName length] == 0) contactLastName = @"";  
                         
                         NSMutableDictionary *contactPhoneNumbers = [[NSMutableDictionary alloc] init];
                         ABRecordRef person = CFArrayGetValueAtIndex((__bridge CFArrayRef)(queriedAddressBook), i);
                         NSNumber *recordId = [NSNumber numberWithInteger:ABRecordGetRecordID(person)];
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
                             
                             if (label)
                                 [contactPhoneNumbers setObject:number forKey:label];
                             else
                                 [contactPhoneNumbers setObject:number forKey:@"other"];
                             CFRelease((__bridge CFTypeRef)(number));
                         }
                         
                         if ([contactPhoneNumbers count] != 0 || contactEmails.count != 0) {
                             NSDictionary *contact = [NSDictionary
                                                      dictionaryWithObjectsAndKeys:
                                                      contactFirstName, @"firstName",
                                                      contactLastName, @"lastName",
                                                      contactEmails, @"email",
                                                      contactPhoneNumbers, @"phone",
                                                      recordId, @"recordID",
                                                      nil];
                             
                             [matchedContacts addObject:contact];
                         }

                         CFRelease(emails);
                         CFRelease(phoneNumbers);
                     }
                 }

                 if (queriedAddressBook != nil) {
                     [task success:matchedContacts];
                 } else {
                     CFRelease(addressBook);
                     [task error:nil];
                 }
                 
             } else {
                 [task error:@"Rejected"];
             }
         });
    });
}

+ (void)getContact:(ForgeTask*)task withRecordID:(NSNumber*)recordID {
    
    dispatch_queue_t queue;
    
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        CFErrorRef myError = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &myError);
        
        ABAddressBookRequestAccessWithCompletion(addressBook,
         ^(bool granted, CFErrorRef error) {
             if (granted) {
                 NSMutableArray *finalContact = [[NSMutableArray alloc] init];
                 ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook,recordID.integerValue);

                 NSString *contactFirstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                 NSString *contactLastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                 if ([contactFirstName length] == 0) contactFirstName = @"";
                 if ([contactLastName length] == 0) contactLastName = @"";

                 NSMutableDictionary *contactPhoneNumbers = [[NSMutableDictionary alloc] init];
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
   
                     if (label)
                         [contactPhoneNumbers setObject:number forKey:label];
                     else
                         [contactPhoneNumbers setObject:number forKey:@"other"];
                     CFRelease((__bridge CFTypeRef)(number));
                 }

                 NSString *dataUrl = @"";
                 UIImage *contactPhoto;
                 if(ABPersonHasImageData(person)) {
                     contactPhoto = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)];
                     NSString *encodedContactPhoto = [UIImagePNGRepresentation(contactPhoto) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                     dataUrl = [NSString stringWithFormat:@"data:image/png;base64,%@", encodedContactPhoto];
                 }
                
                 if ([contactPhoneNumbers count] != 0 || contactEmails.count != 0) {
                     NSDictionary *contact = [NSDictionary
                                              dictionaryWithObjectsAndKeys:
                                              contactFirstName, @"firstName",
                                              contactLastName, @"lastName",
                                              contactEmails, @"email",
                                              contactPhoneNumbers, @"phone",
                                              dataUrl, @"photo",
                                              nil];
                     [finalContact addObject:contact];
                 }
                 
                 CFRelease(emails);
                 CFRelease(phoneNumbers);
                 [task success:finalContact];
             } else {
                 [task error:@"Rejected"];
             }
         });
    });
}

+ (void)getOwner:(ForgeTask*)task {
    JBDeviceOwner *owner = [UIDevice currentDevice].owner;
    
    if (owner != nil) {
        NSDictionary *ownerDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  owner.firstName, @"firstName",
                                  owner.lastName, @"lastName",
                                  owner.email, @"email",
                                  owner.phone, @"phone",
                                  nil];
        
        [task success:ownerDic];
    } else {
        [task error:@"No match"];
    }
}

@end
