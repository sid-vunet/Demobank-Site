// SSO Main Module
// UCO Bank CBS Browser Application

var SSO = {
	version: '1.0.0',
	initialized: false,
	
	// Initialize SSO
	init: function() {
		if (this.initialized) {
			return;
		}
		
		SSOUtils.log(3, 'SSO', 'init', 'Initializing SSO module v' + this.version);
		
		// Check browser compatibility
		var browser = SSOUtils.checkBrowser();
		if (!browser.isCompatible) {
			SSOUtils.log(2, 'SSO', 'init', 'Browser may not be fully compatible');
		}
		
		this.initialized = true;
		SSOUtils.log(3, 'SSO', 'init', 'SSO module initialized');
	},
	
	// Submit login form
	submitLogin: function(formName) {
		SSOUtils.log(3, 'SSO', 'submitLogin', 'Attempting login');
		
		if (!SSOUtils.validateForm(formName)) {
			return false;
		}
		
		var form = document.forms[formName];
		if (form) {
			SSOUtils.log(3, 'SSO', 'submitLogin', 'Submitting form');
			form.submit();
			return true;
		}
		
		return false;
	},
	
	// Logout
	logout: function() {
		SSOUtils.log(3, 'SSO', 'logout', 'Logging out');
		SSOUtils.deleteCookie('uco-session');
		window.location.href = '/login';
	},
	
	// Redirect to home
	redirectToHome: function() {
		SSOUtils.log(3, 'SSO', 'redirectToHome', 'Redirecting to home');
		window.location.href = '/home';
	}
};

// Initialize on load
if (typeof window !== 'undefined') {
	window.SSO = SSO;
	
	// Auto-initialize
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', function() {
			SSO.init();
		});
	} else {
		SSO.init();
	}
}
