contacts
======================
contacts is a [Trigger.IO](https://trigger.io/docs/current/api/native_modules/index.html) module that grabs relevent contacts' phone, email, and names from the devices' Address Book.

##Usage Notes
* contacts is dependent upon [JBDeviceOwner](https://github.com/jakeboxer/JBDeviceOwner) and [AddressBook](https://developer.apple.com/library/ios/documentation/AddressBook/Reference/ABAddressBookRef_iPhoneOS/Reference/reference.html)
* ARC friendly.
* Uses Grand Central Dispatch.

###getContactsPermission
Displays a native alert informing the user of a pending request for contacts access. Then displays request for access to contacts.
```js
forge.internal.call('contacts.getContactsPermission', success, error);
```

###getContactsInstructions
Displays a native alert informing the user how to re-enable access to contacts if they've previously denied it.
```js
forge.internal.call('contacts.getContactsInstructions', success, error);
```

###getContacts
Takes an array of queries and returns the resulting id's in an array.
```js
forge.internal.call('contacts.getContacts', {
  Query: 'alex' //Pass in the string you want to search for
  Skip: 0       // How many results to skip
  Limit: MAX    // Maximum number of results to send back
}, success, error);
```

###getOwner
Uses JBDeviceOwner to throw back an object containing the `firstName`, `lastName`, `email`, and `phone` based on the device name. Obviously just best guess.
```js
forge.internal.call('database.getOwner', success, error);
```

##License

Copyright (c) 2013, Fetchnotes Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.
