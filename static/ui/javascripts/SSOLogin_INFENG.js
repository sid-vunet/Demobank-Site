// SSO Login Resources - English
// UCO Bank CBS Browser Application

var SSOJSResourceBundle = {
	// Login page messages
	'login.title': 'Finacle Universal Banking Solution',
	'login.userId': 'User ID',
	'login.password': 'Password',
	'login.button': 'Login',
	'login.clear': 'Clear',
	'login.error': 'Invalid username or password',
	'login.required': 'Please enter both username and password',
	
	// Virtual keyboard messages
	'keyboard.title': 'Virtual Keyboard',
	'keyboard.subtitle': '(for entering password only)',
	'keyboard.clear': 'Clear',
	'keyboard.erase': 'Erase',
	'keyboard.caps': 'Caps',
	'keyboard.done': 'Done',
	'keyboard.cancel': 'Cancel',
	'keyboard.close': 'Close',
	'keyboard.help': 'Help',
	
	// Session messages
	'session.expired': 'Your session has expired. Please login again.',
	'session.timeout': 'Session timeout',
	
	// General messages
	'message.welcome': 'Welcome to UCO Bank',
	'message.loading': 'Loading...',
	'message.processing': 'Processing...'
};

// Export for global access
if (typeof window !== 'undefined') {
	window.SSOJSResourceBundle = SSOJSResourceBundle;
}
