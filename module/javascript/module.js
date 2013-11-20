// Expose the native API to javascript
forge.contacts = {
    showAlert: function (text, success, error) {
        forge.internal.call('contacts.showAlert', {text: text}, success, error);
    }
};

// Register for our native event
forge.internal.addEventListener("contacts.resume", function () {
	alert("Welcome back!");
});
