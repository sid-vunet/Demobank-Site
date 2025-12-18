// Two-Factor Authentication utilities
// UCO Bank CBS Browser Application

var TFAAuth = {
	popupWindow: null,
	
	// Focus on TFA popup if it exists
	focus: function() {
		if (this.popupWindow && !this.popupWindow.closed) {
			this.popupWindow.focus();
		}
	},
	
	// Open TFA popup
	open: function(url, width, height) {
		width = width || 400;
		height = height || 300;
		
		var left = (screen.width - width) / 2;
		var top = (screen.height - height) / 2;
		
		var features = 'width=' + width + ',height=' + height + 
					  ',left=' + left + ',top=' + top + 
					  ',resizable=yes,scrollbars=yes';
		
		this.popupWindow = window.open(url, 'TFAPopup', features);
		
		if (this.popupWindow) {
			this.popupWindow.focus();
		}
	},
	
	// Close TFA popup
	close: function() {
		if (this.popupWindow && !this.popupWindow.closed) {
			this.popupWindow.close();
		}
		this.popupWindow = null;
	},
	
	// Check if TFA is enabled
	isEnabled: function() {
		return (typeof twoStepAuth !== 'undefined' && twoStepAuth === 'true');
	}
};

// Global function for backward compatibility
function TFApopupWindowFocus() {
	TFAAuth.focus();
}

// Export
if (typeof window !== 'undefined') {
	window.TFAAuth = TFAAuth;
}
