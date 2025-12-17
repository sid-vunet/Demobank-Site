<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // JSP Logic - Handles all actions like real Finacle
    String action = request.getParameter("action");
    String callType = request.getParameter("CALLTYPE");
    String username = request.getParameter("txtLoginId");
    String password = request.getParameter("txtPassword");
    String errorMsg = "";
    boolean isAuthenticated = false;
    
    // Check if user is already logged in
    String sessionUser = (String) session.getAttribute("username");
    if (sessionUser != null && !sessionUser.isEmpty()) {
        isAuthenticated = true;
    }
    
    // Handle different actions
    if ("login".equals(action) && username != null && password != null) {
        // Validate credentials (simulate authentication)
        if (!username.isEmpty() && !password.isEmpty()) {
            // Successful login - set session
            session.setAttribute("username", username);
            session.setAttribute("userId", username);
            session.setAttribute("loginTime", new java.util.Date().toString());
            session.setAttribute("authenticated", "true");
            session.setAttribute("sessionId", session.getId());
            isAuthenticated = true;
            
            // Redirect to home or requested page
            if ("GET_BANK_HOME_PAGE".equals(callType)) {
                response.sendRedirect(request.getContextPath() + "/fininfra/ui/SSOLogin.jsp?view=home");
                return;
            }
        } else {
            errorMsg = "Invalid username or password";
        }
    }
    
    // Handle logout
    if ("logout".equals(action)) {
        session.invalidate();
        response.sendRedirect(request.getContextPath() + "/fininfra/ui/SSOLogin.jsp");
        return;
    }
    
    // Determine which view to show
    String view = request.getParameter("view");
    if (view == null) {
        view = isAuthenticated ? "home" : "login";
    }
    
    // Handle CALLTYPE for Finacle compatibility
    if ("GET_LOGIN_PAGE".equals(callType)) {
        view = "login";
    } else if ("GET_BANK_HOME_PAGE".equals(callType)) {
        view = isAuthenticated ? "home" : "login";
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=10"/>
<meta http-equiv="Content-Language" content="en">
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<title><%= "home".equals(view) ? "UCO Bank - Home" : "Single Sign on Login Page" %></title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/ui/login.css">
<script>
// Configuration variables - populated from server
var saltEnabled = 'N';
var pageDomain = 'ucobanknet.in';
var twoStepAuth = 'true';
var ssoJsCryptSpi = 'custom/SSOCrypt';
var digestAlgorithm = 'SHA-512';
var recvTimeout = '';
var newEncEnabled = 'YES';
var contextSleepTime = '500';
var invokeCoreMenuInSameModule = true;
var fininfraActiveComponents = 'SSO,SVS,URM,FCSE,RI,FLS';
var newUIEnabled = false;

// Session data from server
var sessionUser = '<%= session.getAttribute("username") != null ? session.getAttribute("username") : "" %>';
var sessionId = '<%= session.getId() %>';
var isAuthenticated = <%= isAuthenticated %>;

var dojoConfig = (function(){
	var correctPathName = (location.pathname.charAt(0) == "/") ? location.pathname : "/" + location.pathname;
	return {
		isDebug: true,
		packages: []
	};
})();
</script>

<script type='text/javascript' src='<%=request.getContextPath()%>/javascripts/ssodomain.js'></script>
<script type='text/javascript' src='<%=request.getContextPath()%>/ui/javascripts/SSOLogin_INFENG.js'></script>
<script type='text/javascript' src='<%=request.getContextPath()%>/ui/javascripts/tfaAuth.js'></script>
<script type='text/javascript' src='<%=request.getContextPath()%>/ui/javascripts/sso.js'></script>
<script type='text/javascript' src='<%=request.getContextPath()%>/ui/javascripts/ssojsutils.js'></script>
<script type='text/javascript' src='<%=request.getContextPath()%>/ui/javascripts/login.js'></script>

<script>
// Navigation functions
function goToBankJsp() {	
	window.location.href = "<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp?view=home";
}

function setFormFocus() {
	if(document.forms[0] && document.forms[0].elements['txtLoginId']) {
		document.forms[0].elements['txtLoginId'].focus();
	}
}

function populateUserAndSetPwdFocus() {
	// Auto-populate last username if available
	var lastUser = '<%= request.getParameter("lastUser") != null ? request.getParameter("lastUser") : "" %>';
	if (lastUser && document.forms[0] && document.forms[0].elements['txtLoginId']) {
		document.forms[0].elements['txtLoginId'].value = lastUser;
		if (document.forms[0].elements['txtPassword']) {
			document.forms[0].elements['txtPassword'].focus();
		}
	}
}

function TFApopupWindowFocus() {
	// TFA popup focus logic
}

function doLogout() {
	if (confirm('Are you sure you want to logout?')) {
		window.location.href = "<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp?action=logout";
	}
}

function validateLogin() {
	var userId = document.forms[0].elements['txtLoginId'].value;
	var password = document.forms[0].elements['txtPassword'].value;
	
	if (!userId || userId.trim() === '') {
		alert('Please enter User ID');
		return false;
	}
	
	if (!password || password.trim() === '') {
		alert('Please enter Password');
		return false;
	}
	
	return true;
}

top.document.title='Finacle Universal Banking Solution';
</script>

</head>
<body onLoad="<%= "login".equals(view) ? "setFormFocus();populateUserAndSetPwdFocus();TFApopupWindowFocus();" : "" %>" onclick="TFApopupWindowFocus();">

<span id="testSpan" style="visibility:hidden;">null</span>

<% if ("login".equals(view)) { %>
<!-- ========== LOGIN VIEW ========== -->

<div align="center" background="yellow" background-color="yellow" bgcolor="yellow">
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <marquee style="color:#FF0000;font-family:Bookman;font-size:140%;font-weight:bold;background-color:yellow;">******   UCOBANK LOCAL ENVIRONMENT   *******</marquee>
  <span style="color:#ff6600;font-family:Bookman;font-size:130%;font-weight:bold;background-color:yellow;">FINACLE 10.2.25 LOCAL SIMULATION</span>

  <% if (!errorMsg.isEmpty()) { %>
  <div style="background-color:#ffcccc;border:1px solid #cc0000;padding:10px;margin:10px;max-width:600px;">
    <strong style="color:#cc0000;">Error:</strong> <%= errorMsg %>
  </div>
  <% } %>

  <table width="626" style="border: 1px solid #ccc;" cellspacing="0" cellpadding="0" height="378" background="<%=request.getContextPath()%>/ui/images/loginbg.gif">       
    <tr>
      <td colspan="2" height="20">&nbsp;</td>
    </tr>
    <tr>
      <td width="313" valign="top">
        <table width="313" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="20">&nbsp;</td>
            <td width="273">
              <img src="<%=request.getContextPath()%>/ui/images/logo.gif" alt="UCO Bank Logo" />
            </td>
            <td width="20">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="313" valign="top">
        <form name="loginForm" method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp?action=login" onsubmit="return validateLogin();">
          <table width="313" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td colspan="3" height="10"></td>
            </tr>
            <tr>
              <td width="20">&nbsp;</td>
              <td width="273">
                <table width="273" border="0" cellspacing="2" cellpadding="0">
                  <tr>
                    <td colspan="2" class="login-header">User Login</td>
                  </tr>
                  <tr>
                    <td height="5" colspan="2"></td>
                  </tr>
                  <tr>
                    <td width="100" class="login-label">User ID:</td>
                    <td width="173">
                      <input type="text" name="txtLoginId" id="txtLoginId" size="20" maxlength="50" class="login-input" autocomplete="off" />
                    </td>
                  </tr>
                  <tr>
                    <td height="5" colspan="2"></td>
                  </tr>
                  <tr>
                    <td class="login-label">Password:</td>
                    <td>
                      <input type="password" name="txtPassword" id="txtPassword" size="20" maxlength="50" class="login-input" autocomplete="off" />
                    </td>
                  </tr>
                  <tr>
                    <td height="10" colspan="2"></td>
                  </tr>
                  <tr>
                    <td colspan="2" align="center">
                      <input type="submit" value="Login" class="login-button" />
                      <input type="reset" value="Clear" class="login-button" />
                    </td>
                  </tr>
                  <tr>
                    <td height="10" colspan="2"></td>
                  </tr>
                  <tr>
                    <td colspan="2" class="login-info">
                      <small>Please use your credentials to login</small>
                    </td>
                  </tr>
                </table>
              </td>
              <td width="20">&nbsp;</td>
            </tr>
          </table>
        </form>
      </td>
    </tr>
    <tr>
      <td colspan="2" height="20">&nbsp;</td>
    </tr>
  </table>
  
</div>

<% } else if ("home".equals(view)) { %>
<!-- ========== HOME VIEW - MODULAR FINACLE LAYOUT ========== -->
<div class="finacle-container">
    <!-- Section 1: Header - Gray area with User dropdown, Calendar, Timezone -->
    <jsp:include page="includes/header.jsp" />
    
    <!-- Section 2: Banner - Blue Finacle logo bar with icon buttons -->
    <jsp:include page="includes/banner.jsp" />
    
    <!-- Section 3: Main Area - Left menu + Content -->
    <div class="finacle-main">
        <!-- Left Panel - Functions menu tree -->
        <jsp:include page="includes/leftmenu.jsp" />
        
        <!-- Content Area - Dynamic based on selected function -->
        <jsp:include page="includes/content.jsp" />
    </div>
</div>

<style>
/* Additional Finacle-specific styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    overflow: hidden;
    font-family: Arial, sans-serif;
}

.finacle-container {
    width: 100%;
    height: 100vh;
    display: flex;
    flex-direction: column;
    background-color: #ffffff;
}

.finacle-main {
    display: flex;
    flex: 1;
    overflow: hidden;
}

.finacle-leftmenu {
    width: 250px;
    min-width: 250px;
    max-width: 250px;
    border-right: 1px solid #ccc;
    overflow-y: auto;
    background-color: #f9f9f9;
    height: 100%;
}

.finacle-content {
    flex: 1;
    overflow-y: auto;
    overflow-x: hidden;
    background-color: #ffffff;
    height: 100%;
}
</style>

<script>
// Global function to load different modules
function loadFunction(funcName) {
    window.location.href = '<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp?view=home&function=' + funcName;
}

// Solution dropdown handler
document.addEventListener('DOMContentLoaded', function() {
    var solutionDropdown = document.getElementById('solutionDropdown');
    if (solutionDropdown) {
        solutionDropdown.addEventListener('change', function() {
            if (this.value !== 'Select' && this.value !== 'FININFRA') {
                alert('Switching to solution: ' + this.value);
                // In real Finacle, this would switch the entire application context
            }
        });
    }
});
</script>

<% } %>

</body>
</html>
