// Login Page JavaScript
// UCO Bank CBS Browser Application

var Login = {
	formName: 'loginForm',
	
	// Set focus on first field
	setFocus: function() {
		var form = document.forms[this.formName];
		if (form && form.elements['txtLoginId']) {
			form.elements['txtLoginId'].focus();
		}
	},
	
	// Validate login form
	validate: function() {
		return SSOUtils.validateForm(this.formName);
	},
	
	// Submit login form
	submit: function() {
		if (this.validate()) {
			var form = document.forms[this.formName];
			if (form) {
				form.submit();
			}
		}
		return false;
	},
	
	// Clear form
	clear: function() {
		var form = document.forms[this.formName];
		if (form) {
			form.reset();
			this.setFocus();
		}
	},
	
	// Handle enter key
	handleEnterKey: function(event) {
		if (event.keyCode === 13) {
			return this.submit();
		}
		return true;
	}
};

// Global function for backward compatibility
function setFormFocus() {
	Login.setFocus();
}

// Export
if (typeof window !== 'undefined') {
	window.Login = Login;
}
