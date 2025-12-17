<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*, com.ucobank.finacle.model.*, com.ucobank.finacle.service.*" %>
<%!
    // Helper method to get current date formatted
    private String getCurrentDate() {
        return new java.text.SimpleDateFormat("MM/dd/yyyy").format(new java.util.Date());
    }
%>
<%
    // ============================================================
    // SSOLogin.jsp - SINGLE JSP FOR ALL FINACLE RENDERING
    // This JSP handles: Login, Home, All Functions, Logout, Errors
    // ============================================================
    
    // Get request parameters
    String view = request.getParameter("view");
    String functionId = request.getParameter("functionId");
    String action = request.getParameter("action");
    String callType = request.getParameter("CALLTYPE");
    
    // Get session attributes
    Boolean isAuthenticated = (Boolean) session.getAttribute("authenticated");
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    String solution = (String) session.getAttribute("solution");
    Date loginTime = (Date) session.getAttribute("loginTime");
    
    // Get request attributes (set by servlet)
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String lastUserId = (String) request.getAttribute("lastUserId");
    Object functionData = request.getAttribute("functionData");
    String functionTitle = (String) request.getAttribute("functionTitle");
    List menuItems = (List) request.getAttribute("menuItems");
    
    // Determine current view
    // Priority: explicit view param > authenticated state > default login
    String currentView = "login"; // default
    
    if (view != null && !view.isEmpty()) {
        currentView = view;
    } else if (isAuthenticated != null && isAuthenticated) {
        currentView = "home";
    }
    
    // Handle CALLTYPE for Finacle compatibility
    if ("GET_LOGIN_PAGE".equals(callType)) {
        currentView = "login";
    } else if ("GET_BANK_HOME_PAGE".equals(callType)) {
        currentView = (isAuthenticated != null && isAuthenticated) ? "home" : "login";
    } else if ("LOGOUT".equals(callType)) {
        session.invalidate();
        currentView = "login";
        successMessage = "You have been logged out successfully.";
    }
    
    // If trying to access home without auth, redirect to login
    if ("home".equals(currentView) && (isAuthenticated == null || !isAuthenticated)) {
        currentView = "login";
        errorMessage = "Session expired. Please login again.";
    }
    
    // Set defaults
    if (solution == null) solution = "FININFRA";
    if (functionId == null) functionId = "welcome";
    if (functionTitle == null) functionTitle = "Welcome";
    
    // Page title based on view
    String pageTitle = "login".equals(currentView) ? "Single Sign on Login Page" : "UCO Bank - Finacle Home";
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=10"/>
    <meta http-equiv="Content-Language" content="en">
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
    <title><%= pageTitle %></title>
    
    <style>
        /* ============ COMMON STYLES ============ */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; font-size: 12px; background-color: #f0f0f0; }
        
        /* ============ LOGIN VIEW STYLES ============ */
        .login-container { text-align: center; padding-top: 50px; }
        .marquee-banner { background-color: yellow; padding: 10px; }
        .login-box { width: 626px; margin: 20px auto; border: 1px solid #ccc; background-color: #fff; }
        .login-header { color: #2e5f9e; font-size: 16px; font-weight: bold; border-bottom: 2px solid #2e5f9e; padding-bottom: 5px; margin-bottom: 15px; }
        .login-label { font-weight: bold; color: #333; }
        .login-input { width: 180px; padding: 5px; border: 1px solid #999; }
        .login-button { padding: 6px 20px; background-color: #4a90e2; color: white; border: none; cursor: pointer; font-weight: bold; margin: 0 5px; }
        .login-button:hover { background-color: #2e5f9e; }
        .error-box { background-color: #ffcccc; border: 1px solid #cc0000; padding: 10px; margin: 10px auto; max-width: 600px; color: #cc0000; }
        .success-box { background-color: #ccffcc; border: 1px solid #00cc00; padding: 10px; margin: 10px auto; max-width: 600px; color: #006600; }
        
        /* ============ HOME VIEW STYLES ============ */
        .finacle-container { width: 100%; height: 100vh; display: flex; flex-direction: column; }
        .finacle-main { display: flex; flex: 1; overflow: hidden; }
        
        /* Header - Gray Bar */
        .finacle-header { background-color: #e8e8e8; border-bottom: 1px solid #ccc; padding: 5px 10px; font-size: 11px; }
        .header-notification { color: #cc0000; font-weight: bold; text-align: center; padding: 3px; }
        
        /* Banner - Blue Bar */
        .finacle-banner { background: linear-gradient(to bottom, #4a90e2 0%, #2e5f9e 100%); padding: 8px 10px; color: white; }
        .finacle-logo { background-color: white; padding: 5px 15px; border-radius: 3px; display: inline-block; }
        .finacle-logo-text { color: #cc0000; font-size: 24px; font-weight: bold; font-family: 'Times New Roman', serif; }
        .finacle-logo-sub { color: #333; font-size: 8px; letter-spacing: 1px; }
        .icon-button { width: 32px; height: 32px; cursor: pointer; margin: 0 3px; background-color: #ccc; border: 1px solid #999; text-align: center; line-height: 32px; display: inline-block; }
        
        /* Menu Bar */
        .finacle-menubar { background-color: #f5f5f5; border-bottom: 1px solid #ccc; padding: 3px 10px; font-size: 11px; }
        
        /* Left Menu */
        .finacle-leftmenu { width: 250px; min-width: 250px; border-right: 1px solid #ccc; overflow-y: auto; background-color: #f9f9f9; }
        .menu-title { background-color: #4a90e2; color: white; padding: 8px; font-weight: bold; font-size: 12px; }
        .menu-section { margin-top: 2px; }
        .menu-header { background-color: #e0e8f0; padding: 5px 8px; cursor: pointer; border-bottom: 1px solid #ccc; font-weight: bold; }
        .menu-header:hover { background-color: #d0dced; }
        .menu-items { background-color: #fff; padding-left: 25px; display: none; }
        .menu-items.expanded { display: block; }
        .menu-item { padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee; }
        .menu-item:hover { background-color: #e8f0ff; font-weight: bold; }
        .menu-item.active { background-color: #cce0ff; font-weight: bold; }
        
        /* Content Area */
        .finacle-content { flex: 1; overflow-y: auto; background-color: #fff; padding: 20px; }
        .content-title { color: #2e5f9e; font-size: 18px; font-weight: bold; border-bottom: 2px solid #4a90e2; padding-bottom: 8px; margin-bottom: 20px; }
        .form-section { background-color: #f9f9f9; border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; }
        .form-table td { padding: 5px 10px; }
        .form-label { font-weight: bold; }
        .form-input { width: 200px; padding: 4px; border: 1px solid #999; }
        .form-button { padding: 6px 20px; background-color: #4a90e2; color: white; border: none; cursor: pointer; margin-right: 10px; }
        .form-button:hover { background-color: #2e5f9e; }
        .form-button.secondary { background-color: #999; }
        .form-button.danger { background-color: #cc0000; }
        
        /* Quick Access Tiles */
        .quick-tiles { display: flex; flex-wrap: wrap; gap: 15px; margin-top: 20px; }
        .quick-tile { background-color: #f0f8ff; border: 1px solid #ccc; padding: 15px; border-radius: 5px; cursor: pointer; width: 200px; }
        .quick-tile:hover { background-color: #e0f0ff; border-color: #4a90e2; }
        .quick-tile-title { color: #2e5f9e; font-weight: bold; margin-bottom: 5px; }
        .quick-tile-desc { font-size: 11px; color: #666; }
        
        /* Data Table */
        .data-table { width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 11px; }
        .data-table th { background-color: #4a90e2; color: white; padding: 8px; text-align: left; }
        .data-table td { padding: 8px; border-bottom: 1px solid #ddd; }
        .data-table tr:hover { background-color: #f5f5f5; }
    </style>
    
    <script>
        // Global variables from server
        var isAuthenticated = <%= isAuthenticated != null && isAuthenticated %>;
        var sessionUser = '<%= username != null ? username : "" %>';
        var currentView = '<%= currentView %>';
        var currentFunction = '<%= functionId %>';
        
        // Form focus on load
        function setFormFocus() {
            var userField = document.getElementById('txtLoginId');
            if (userField) userField.focus();
        }
        
        // Validate login form
        function validateLogin() {
            var userId = document.getElementById('txtLoginId').value;
            var password = document.getElementById('txtPassword').value;
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
        
        // Logout confirmation
        function doLogout() {
            if (confirm('Are you sure you want to logout?')) {
                window.location.href = '<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp?CALLTYPE=LOGOUT';
            }
        }
        
        // Load function content
        function loadFunction(functionId) {
            window.location.href = '<%=request.getContextPath()%>/function?functionId=' + functionId;
        }
        
        // Toggle menu section
        function toggleMenu(menuId) {
            var menu = document.getElementById(menuId);
            var icon = document.getElementById(menuId + '_icon');
            if (menu.classList.contains('expanded')) {
                menu.classList.remove('expanded');
                if (icon) icon.innerHTML = '▶';
            } else {
                menu.classList.add('expanded');
                if (icon) icon.innerHTML = '▼';
            }
        }
        
        // Initialize on page load
        window.onload = function() {
            if (currentView === 'login') {
                setFormFocus();
            }
        };
    </script>
</head>
<body>

<% if ("login".equals(currentView)) { %>
<!-- ================== LOGIN VIEW ================== -->
<div class="login-container">
    
    <!-- Banner -->
    <div class="marquee-banner">
        <marquee style="color:#FF0000;font-family:Bookman;font-size:140%;font-weight:bold;">
            ******   UCOBANK LOCAL ENVIRONMENT   *******
        </marquee>
        <span style="color:#ff6600;font-family:Bookman;font-size:130%;font-weight:bold;">
            FINACLE 10.2.25 LOCAL SIMULATION
        </span>
    </div>
    
    <!-- Success Message -->
    <% if (successMessage != null && !successMessage.isEmpty()) { %>
    <div class="success-box">
        <strong>✓</strong> <%= successMessage %>
    </div>
    <% } %>
    
    <!-- Error Message -->
    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
    <div class="error-box">
        <strong>Error:</strong> <%= errorMessage %>
    </div>
    <% } %>
    
    <!-- Login Box -->
    <table class="login-box" cellspacing="0" cellpadding="20">
        <tr>
            <td width="313" valign="top" align="center">
                <div style="padding: 40px; border: 1px solid #ccc; background-color: #f9f9f9;">
                    <span style="font-size: 24px; color: #cc0000; font-weight: bold;">UCO Bank</span><br/>
                    <span style="font-size: 11px; color: #666;">Core Banking System</span>
                </div>
            </td>
            <td width="313" valign="top">
                <form name="loginForm" method="POST" action="<%=request.getContextPath()%>/login" onsubmit="return validateLogin();">
                    <table width="100%" border="0" cellspacing="5" cellpadding="5">
                        <tr>
                            <td colspan="2" class="login-header">User Login</td>
                        </tr>
                        <tr>
                            <td class="login-label">User ID:</td>
                            <td>
                                <input type="text" name="txtLoginId" id="txtLoginId" class="login-input" 
                                       maxlength="50" autocomplete="off" value="<%= lastUserId != null ? lastUserId : "" %>" />
                            </td>
                        </tr>
                        <tr>
                            <td class="login-label">Password:</td>
                            <td>
                                <input type="password" name="txtPassword" id="txtPassword" class="login-input" 
                                       maxlength="50" autocomplete="off" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" align="center" style="padding-top: 15px;">
                                <input type="submit" value="Login" class="login-button" />
                                <input type="reset" value="Clear" class="login-button" style="background-color: #999;" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" align="center" style="font-size: 11px; color: #666; padding-top: 10px;">
                                Please use your credentials to login
                            </td>
                        </tr>
                    </table>
                </form>
            </td>
        </tr>
    </table>
    
</div>

<% } else if ("home".equals(currentView)) { %>
<!-- ================== HOME VIEW ================== -->
<div class="finacle-container">
    
    <!-- ======== SECTION 1: HEADER (Gray Bar) ======== -->
    <div class="finacle-header">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td width="200">
                    <strong>User:</strong> 
                    <select style="font-size: 11px; padding: 2px;">
                        <option selected><%= username != null ? username : "Guest" %></option>
                    </select>
                </td>
                <td align="center" class="header-notification">
                    (1st October, i.e. Wednesday's Presentation): 2. Presentation : 11 AM to 3 PM (Special Clearing)
                </td>
                <td width="400" align="right">
                    <strong>Calendar:</strong>
                    <select style="font-size: 11px; padding: 2px;">
                        <option selected>Gregorian</option>
                        <option>Islamic</option>
                    </select>
                    &nbsp;&nbsp;
                    <strong>Time Zone:</strong> IST
                    &nbsp;&nbsp;
                    <span style="cursor: pointer;">🔍 Search</span>
                    &nbsp;&nbsp;
                    <strong>Solution:</strong>
                    <select style="font-size: 11px; padding: 2px;">
                        <option>Select</option>
                        <option>CRM</option>
                        <option>CoreServer</option>
                        <option selected>FININFRA</option>
                        <option>GBM</option>
                    </select>
                </td>
            </tr>
        </table>
    </div>
    
    <!-- ======== SECTION 2: BANNER (Blue Bar) ======== -->
    <div class="finacle-banner">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td width="250">
                    <div class="finacle-logo">
                        <span class="finacle-logo-text">r Finacle<sup style="font-size: 10px;">®</sup></span>
                        <div class="finacle-logo-sub">Universal Banking Solution from Infosys</div>
                    </div>
                </td>
                <td align="center">
                    <span class="icon-button" title="Home" onclick="loadFunction('welcome')">🏠</span>
                    <span class="icon-button" title="Profile">👤</span>
                    <span class="icon-button" title="Messages">✉</span>
                    <span class="icon-button" title="Email">📧</span>
                    <span class="icon-button" title="Calculator">🔢</span>
                    <span class="icon-button" title="Notes">📝</span>
                </td>
                <td width="250" align="right" style="font-size: 11px;">
                    <div>Customer Call: None</div>
                    <div>Consult Call: None</div>
                    <div>Rep Status: Non-Telephony Rep</div>
                </td>
            </tr>
        </table>
    </div>
    
    <!-- Menu Shortcut Bar -->
    <div class="finacle-menubar">
        <table width="100%" border="0">
            <tr>
                <td align="right">
                    <strong><%= getCurrentDate() %></strong>
                    &nbsp;|&nbsp;
                    <strong>Menu Shortcut:</strong>
                    <input type="text" style="width: 150px; font-size: 11px; padding: 2px;" placeholder="Enter shortcut..." />
                    <button class="form-button" style="padding: 2px 10px; font-size: 11px;">Go</button>
                </td>
            </tr>
        </table>
    </div>
    
    <!-- ======== SECTION 3 & 4: MAIN AREA ======== -->
    <div class="finacle-main">
        
        <!-- ======== LEFT MENU ======== -->
        <div class="finacle-leftmenu">
            <div class="menu-title">
                📁 Functions
                <span style="float: right; cursor: pointer;" onclick="doLogout()">✕</span>
            </div>
            
            <!-- CIF Retail -->
            <div class="menu-section">
                <div class="menu-header" onclick="toggleMenu('cifRetailMenu')">
                    <span id="cifRetailMenu_icon">▼</span> CIF Retail
                </div>
                <div id="cifRetailMenu" class="menu-items expanded">
                    <div class="menu-item <%= "CIF_RETAIL_AUDIT".equals(functionId) ? "active" : "" %>" onclick="loadFunction('CIF_RETAIL_AUDIT')">📄 Audit Trail</div>
                    <div class="menu-item <%= "CIF_RETAIL_EDIT".equals(functionId) ? "active" : "" %>" onclick="loadFunction('CIF_RETAIL_EDIT')">📄 Edit Entity</div>
                    <div class="menu-item <%= "CIF_RETAIL_QUEUE".equals(functionId) ? "active" : "" %>" onclick="loadFunction('CIF_RETAIL_QUEUE')">📄 Entity Queue</div>
                    <div class="menu-item <%= "CIF_RETAIL_NEW".equals(functionId) ? "active" : "" %>" onclick="loadFunction('CIF_RETAIL_NEW')">📄 New Entity</div>
                    <div class="menu-item <%= "CIF_RETAIL_OPS".equals(functionId) ? "active" : "" %>" onclick="loadFunction('CIF_RETAIL_OPS')">📄 Operations</div>
                    <div class="menu-item <%= "CIF_RETAIL_RM".equals(functionId) ? "active" : "" %>" onclick="loadFunction('CIF_RETAIL_RM')">📄 Relationship Manager Maintenance</div>
                </div>
            </div>
            
            <!-- CIF Corporate -->
            <div class="menu-section">
                <div class="menu-header" onclick="toggleMenu('cifCorpMenu')">
                    <span id="cifCorpMenu_icon">▶</span> CIF Corporate
                </div>
                <div id="cifCorpMenu" class="menu-items">
                    <div class="menu-item" onclick="loadFunction('CIF_CORP_AUDIT')">📄 Audit Trail</div>
                    <div class="menu-item" onclick="loadFunction('CIF_CORP_EDIT')">📄 Edit Entity</div>
                    <div class="menu-item" onclick="loadFunction('CIF_CORP_QUEUE')">📄 Entity Queue</div>
                    <div class="menu-item" onclick="loadFunction('CIF_CORP_GROUP')">📄 Group Mapping</div>
                    <div class="menu-item" onclick="loadFunction('CIF_CORP_NEW')">📄 New Entity</div>
                    <div class="menu-item" onclick="loadFunction('CIF_CORP_OPS')">📄 Operations</div>
                    <div class="menu-item" onclick="loadFunction('CIF_CORP_RM')">📄 Relationship Manager Maintenance</div>
                </div>
            </div>
            
            <!-- Accounts -->
            <div class="menu-section">
                <div class="menu-header" onclick="toggleMenu('accountsMenu')">
                    <span id="accountsMenu_icon">▶</span> Accounts
                </div>
                <div id="accountsMenu" class="menu-items">
                    <div class="menu-item" onclick="loadFunction('ACC_SAVINGS')">📄 Savings Account</div>
                    <div class="menu-item" onclick="loadFunction('ACC_CURRENT')">📄 Current Account</div>
                    <div class="menu-item" onclick="loadFunction('ACC_FD')">📄 Fixed Deposit</div>
                    <div class="menu-item" onclick="loadFunction('ACC_RD')">📄 Recurring Deposit</div>
                </div>
            </div>
            
            <!-- Transactions -->
            <div class="menu-section">
                <div class="menu-header" onclick="toggleMenu('txnMenu')">
                    <span id="txnMenu_icon">▶</span> Transactions
                </div>
                <div id="txnMenu" class="menu-items">
                    <div class="menu-item" onclick="loadFunction('TXN_DEPOSIT')">📄 Cash Deposit</div>
                    <div class="menu-item" onclick="loadFunction('TXN_WITHDRAW')">📄 Cash Withdrawal</div>
                    <div class="menu-item" onclick="loadFunction('TXN_TRANSFER')">📄 Fund Transfer</div>
                    <div class="menu-item" onclick="loadFunction('TXN_BILL')">📄 Bill Payment</div>
                </div>
            </div>
            
            <!-- Reports -->
            <div class="menu-section">
                <div class="menu-header" onclick="toggleMenu('reportsMenu')">
                    <span id="reportsMenu_icon">▶</span> Reports
                </div>
                <div id="reportsMenu" class="menu-items">
                    <div class="menu-item" onclick="loadFunction('RPT_DAILY')">📄 Daily Reports</div>
                    <div class="menu-item" onclick="loadFunction('RPT_STATEMENT')">📄 Account Statement</div>
                    <div class="menu-item" onclick="loadFunction('RPT_HISTORY')">📄 Transaction History</div>
                    <div class="menu-item" onclick="loadFunction('RPT_MIS')">📄 MIS Reports</div>
                </div>
            </div>
            
            <!-- Scroll indicator -->
            <div style="padding: 10px; text-align: center; border-top: 1px solid #ccc; margin-top: 10px;">
                <button style="padding: 2px 10px;">◄</button>
                <span style="display: inline-block; width: 100px; height: 8px; background-color: #ddd; border: 1px solid #999;"></span>
                <button style="padding: 2px 10px;">►</button>
            </div>
        </div>
        
        <!-- ======== CONTENT AREA ======== -->
        <div class="finacle-content">
            
            <% if ("welcome".equals(functionId) || functionId == null) { %>
            <!-- WELCOME SCREEN -->
            <h2 class="content-title">Welcome to Finacle Universal Banking Solution</h2>
            
            <p style="font-size: 14px; margin-bottom: 20px;">
                Hello <strong><%= username %></strong>, you are logged into the <strong><%= solution %></strong> solution.
                <br/>Please select a function from the left menu to begin.
            </p>
            
            <h3 style="color: #2e5f9e; margin-bottom: 10px;">Quick Access</h3>
            <div class="quick-tiles">
                <div class="quick-tile" onclick="loadFunction('CIF_RETAIL_AUDIT')">
                    <div class="quick-tile-title">📋 Audit Trail</div>
                    <div class="quick-tile-desc">View transaction audit logs</div>
                </div>
                <div class="quick-tile" onclick="loadFunction('CIF_RETAIL_EDIT')">
                    <div class="quick-tile-title">✏️ Edit Entity</div>
                    <div class="quick-tile-desc">Modify existing customer records</div>
                </div>
                <div class="quick-tile" onclick="loadFunction('CIF_RETAIL_NEW')">
                    <div class="quick-tile-title">➕ New Entity</div>
                    <div class="quick-tile-desc">Create new customer entity</div>
                </div>
                <div class="quick-tile" onclick="loadFunction('CIF_RETAIL_QUEUE')">
                    <div class="quick-tile-title">📑 Entity Queue</div>
                    <div class="quick-tile-desc">View pending approvals</div>
                </div>
                <div class="quick-tile" onclick="loadFunction('TXN_TRANSFER')">
                    <div class="quick-tile-title">💸 Fund Transfer</div>
                    <div class="quick-tile-desc">Transfer funds between accounts</div>
                </div>
                <div class="quick-tile" onclick="loadFunction('RPT_STATEMENT')">
                    <div class="quick-tile-title">📊 Account Statement</div>
                    <div class="quick-tile-desc">Generate account statements</div>
                </div>
            </div>
            
            <div style="margin-top: 30px; padding: 15px; background-color: #fffacd; border: 1px solid #ffd700; border-radius: 5px;">
                <strong>⚠️ System Notice:</strong><br/>
                (1st October, i.e. Wednesday's Presentation): 2. Presentation : 11 AM to 3 PM (Special Clearing)
            </div>
            
            <div style="margin-top: 20px; text-align: center;">
                <button class="form-button danger" onclick="doLogout()">🚪 Logout</button>
            </div>
            
            <% } else if (functionId.contains("AUDIT")) { %>
            <!-- AUDIT TRAIL SCREEN -->
            <h2 class="content-title"><%= functionTitle != null ? functionTitle : "Audit Trail" %></h2>
            
            <div class="form-section">
                <form method="POST" action="<%=request.getContextPath()%>/function">
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <input type="hidden" name="action" value="search" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Customer ID:</td>
                            <td><input type="text" name="customerId" class="form-input" /></td>
                            <td class="form-label">From Date:</td>
                            <td><input type="date" name="fromDate" class="form-input" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Account Number:</td>
                            <td><input type="text" name="accountNo" class="form-input" /></td>
                            <td class="form-label">To Date:</td>
                            <td><input type="date" name="toDate" class="form-input" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Transaction Type:</td>
                            <td>
                                <select name="txnType" class="form-input">
                                    <option value="">All Types</option>
                                    <option value="CREATE">Create</option>
                                    <option value="MODIFY">Modify</option>
                                    <option value="DELETE">Delete</option>
                                </select>
                            </td>
                            <td colspan="2">
                                <button type="submit" class="form-button">Search</button>
                                <button type="reset" class="form-button secondary">Clear</button>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
            
            <h3 style="color: #2e5f9e;">Search Results</h3>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Customer ID</th>
                        <th>Account No</th>
                        <th>Transaction Type</th>
                        <th>User</th>
                        <th>Details</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="6" align="center" style="padding: 20px; color: #999;">
                            No records found. Please enter search criteria and click Search.
                        </td>
                    </tr>
                </tbody>
            </table>
            
            <% } else if (functionId.contains("EDIT")) { %>
            <!-- EDIT ENTITY SCREEN -->
            <h2 class="content-title"><%= functionTitle != null ? functionTitle : "Edit Entity" %></h2>
            
            <div class="form-section">
                <form method="POST" action="<%=request.getContextPath()%>/function">
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <input type="hidden" name="action" value="search" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Customer ID:</td>
                            <td><input type="text" name="customerId" class="form-input" required /></td>
                            <td><button type="submit" class="form-button">Search</button></td>
                        </tr>
                    </table>
                </form>
            </div>
            
            <% if (functionData != null) { %>
            <div class="form-section">
                <h3 style="color: #2e5f9e; margin-bottom: 15px;">Customer Details</h3>
                <form method="POST" action="<%=request.getContextPath()%>/function">
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <input type="hidden" name="action" value="update" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Full Name:</td>
                            <td><input type="text" name="fullName" class="form-input" value="John Doe" /></td>
                            <td class="form-label">Date of Birth:</td>
                            <td><input type="date" name="dob" class="form-input" value="1985-06-15" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Email:</td>
                            <td><input type="email" name="email" class="form-input" value="john.doe@example.com" /></td>
                            <td class="form-label">Phone:</td>
                            <td><input type="tel" name="phone" class="form-input" value="+91 9876543210" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Address:</td>
                            <td colspan="3"><textarea name="address" rows="3" style="width: 90%; padding: 4px;">123 Main Street, Mumbai, Maharashtra 400001</textarea></td>
                        </tr>
                        <tr>
                            <td colspan="4" align="center" style="padding-top: 15px;">
                                <button type="submit" class="form-button">Update</button>
                                <button type="button" class="form-button danger" onclick="loadFunction('welcome')">Cancel</button>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
            <% } %>
            
            <% } else if (functionId.contains("NEW")) { %>
            <!-- NEW ENTITY SCREEN -->
            <h2 class="content-title"><%= functionTitle != null ? functionTitle : "New Entity" %></h2>
            
            <div class="form-section">
                <form method="POST" action="<%=request.getContextPath()%>/function">
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <input type="hidden" name="action" value="create" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Full Name: *</td>
                            <td><input type="text" name="fullName" class="form-input" required /></td>
                            <td class="form-label">Date of Birth: *</td>
                            <td><input type="date" name="dob" class="form-input" required /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Email: *</td>
                            <td><input type="email" name="email" class="form-input" required /></td>
                            <td class="form-label">Phone: *</td>
                            <td><input type="tel" name="phone" class="form-input" required /></td>
                        </tr>
                        <tr>
                            <td class="form-label">ID Type: *</td>
                            <td>
                                <select name="idType" class="form-input" required>
                                    <option value="">Select...</option>
                                    <option value="PAN">PAN Card</option>
                                    <option value="AADHAAR">Aadhaar</option>
                                    <option value="PASSPORT">Passport</option>
                                    <option value="VOTER">Voter ID</option>
                                </select>
                            </td>
                            <td class="form-label">ID Number: *</td>
                            <td><input type="text" name="idNumber" class="form-input" required /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Address: *</td>
                            <td colspan="3"><textarea name="address" rows="3" style="width: 90%; padding: 4px;" required></textarea></td>
                        </tr>
                        <tr>
                            <td colspan="4" align="center" style="padding-top: 15px;">
                                <button type="submit" class="form-button">Create Entity</button>
                                <button type="reset" class="form-button secondary">Clear</button>
                                <button type="button" class="form-button danger" onclick="loadFunction('welcome')">Cancel</button>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
            
            <% } else { %>
            <!-- GENERIC FUNCTION SCREEN -->
            <h2 class="content-title"><%= functionTitle != null ? functionTitle : "Function: " + functionId %></h2>
            
            <div class="form-section">
                <p>This function is under development.</p>
                <p><strong>Function ID:</strong> <%= functionId %></p>
                <p><strong>User:</strong> <%= username %></p>
                <p><strong>Role:</strong> <%= userRole %></p>
            </div>
            
            <button class="form-button" onclick="loadFunction('welcome')">← Back to Home</button>
            
            <% } %>
            
        </div>
        
    </div>
    
</div>

<% } %>

</body>
</html>