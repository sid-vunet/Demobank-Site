// SSO Utilities
// UCO Bank CBS Browser Application

var SSOUtils = {
	// Logging levels: 0=OFF, 1=ERROR, 2=WARN, 3=INFO, 4=DEBUG
	logLevel: 3,
	
	// Log function
	log: function(level, module, method, message) {
		if (level <= this.logLevel) {
			var levelName = ['OFF', 'ERROR', 'WARN', 'INFO', 'DEBUG'][level] || 'UNKNOWN';
			var timestamp = new Date().toISOString();
			console.log('[' + timestamp + '] [' + levelName + '] [' + module + '.' + method + '] ' + message);
		}
	},
	
	// Get cookie value
	getCookie: function(name) {
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i = 0; i < ca.length; i++) {
			var c = ca[i];
			while (c.charAt(0) == ' ') c = c.substring(1, c.length);
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
		}
		return null;
	},
	
	// Set cookie
	setCookie: function(name, value, days) {
		var expires = "";
		if (days) {
			var date = new Date();
			date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
			expires = "; expires=" + date.toUTCString();
		}
		document.cookie = name + "=" + (value || "") + expires + "; path=/";
	},
	
	// Delete cookie
	deleteCookie: function(name) {
		document.cookie = name + '=; Max-Age=-99999999; path=/';
	},
	
	// Form validation
	validateForm: function(formName) {
		var form = document.forms[formName];
		if (!form) {
			this.log(1, 'SSOUtils', 'validateForm', 'Form not found: ' + formName);
			return false;
		}
		
		var userId = form.elements['txtLoginId'];
		var password = form.elements['txtPassword'];
		
		if (!userId || !userId.value.trim()) {
			alert('Please enter User ID');
			if (userId) userId.focus();
			return false;
		}
		
		if (!password || !password.value.trim()) {
			alert('Please enter Password');
			if (password) password.focus();
			return false;
		}
		
		return true;
	},
	
	// Check browser compatibility
	checkBrowser: function() {
		var ua = navigator.userAgent;
		var isIE = ua.indexOf('MSIE') !== -1 || ua.indexOf('Trident/') !== -1;
		var isEdge = ua.indexOf('Edge/') !== -1 || ua.indexOf('Edg/') !== -1;
		
		this.log(3, 'SSOUtils', 'checkBrowser', 'IE: ' + isIE + ', Edge: ' + isEdge);
		
		return {
			isIE: isIE,
			isEdge: isEdge,
			isCompatible: isIE || isEdge
		};
	}
};

// Resource bundle setter
function setSSOResourceBundle(bundle) {
	if (typeof window !== 'undefined') {
		window.SSOResourceBundle = bundle;
	}
	SSOUtils.log(3, 'SSO', 'setSSOResourceBundle', 'Resource bundle set');
}

// Login status setter
function setLoginStatus() {
	SSOUtils.log(3, 'SSO', 'setLoginStatus', 'Setting login status');
}

// Globals setter
function setGlobals(appletMode, maxRetries) {
	if (typeof window !== 'undefined') {
		window.isAppletMode = appletMode;
		window.maxLoginRetries = maxRetries;
	}
	SSOUtils.log(3, 'SSO', 'setGlobals', 'Globals set - AppletMode: ' + appletMode + ', MaxRetries: ' + maxRetries);
}

// Export
if (typeof window !== 'undefined') {
	window.SSOUtils = SSOUtils;
}
