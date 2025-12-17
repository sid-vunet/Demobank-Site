// SSO Domain Configuration
// UCO Bank CBS Browser Application

var pageDomain = pageDomain || 'ucobanknet.in';

// Domain configuration
var ssoConfig = {
	domain: pageDomain,
	secure: false, // Set to true in production with HTTPS
	path: '/',
	sameSite: 'Lax'
};

// SSO Domain utilities
function getSSODomain() {
	return ssoConfig.domain;
}

function getSecureFlag() {
	return ssoConfig.secure;
}

function getSSOPath() {
	return ssoConfig.path;
}

// Log configuration (for debugging)
console.log('SSO Domain configured:', ssoConfig.domain);
