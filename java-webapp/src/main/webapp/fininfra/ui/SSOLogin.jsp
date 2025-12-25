<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*, java.math.*, com.ucobank.finacle.model.*, com.ucobank.finacle.service.*, com.ucobank.finacle.dao.*, com.ucobank.finacle.config.*" %>
<%!
    // Helper method to get current date formatted
    private String getCurrentDate() {
        return new java.text.SimpleDateFormat("MM/dd/yyyy").format(new java.util.Date());
    }
%>
<%
    // ============================================================
    // SSOLogin.jsp - SINGLE JSP FOR ALL FINACLE RENDERING
    // URL is ALWAYS: /fininfra/ui/SSOLogin.jsp (no parameters)
    // All state is managed via SESSION and POST form data
    // ============================================================
    
    // Get POST form parameters (internal navigation)
    String formAction = request.getParameter("formAction");
    String formFunctionId = request.getParameter("functionId");
    String formDataAction = request.getParameter("action");
    
    // Get session attributes
    Boolean isAuthenticated = (Boolean) session.getAttribute("authenticated");
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    String solution = (String) session.getAttribute("solution");
    Date loginTime = (Date) session.getAttribute("loginTime");
    String sessionView = (String) session.getAttribute("currentView");
    String sessionFunction = (String) session.getAttribute("currentFunction");
    
    // Get request attributes (set by servlet)
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String lastUserId = (String) request.getAttribute("lastUserId");
    Object functionData = request.getAttribute("functionData");
    String functionTitle = (String) request.getAttribute("functionTitle");
    List menuItems = (List) request.getAttribute("menuItems");
    
    // Handle internal navigation via POST form
    if ("navigate".equals(formAction) && formFunctionId != null) {
        session.setAttribute("currentFunction", formFunctionId);
        sessionFunction = formFunctionId;
    }
    if ("logout".equals(formAction)) {
        session.invalidate();
        isAuthenticated = null;
        sessionView = "login";
        successMessage = "You have been logged out successfully.";
    }
    
    // Handle login form submission directly (formAction = "login")
    if ("login".equals(formAction)) {
        String loginUserId = request.getParameter("txtLoginId");
        String loginPassword = request.getParameter("txtPassword");
        
        if (loginUserId == null || loginUserId.trim().isEmpty()) {
            errorMessage = "User ID is required";
            lastUserId = loginUserId;
        } else if (loginPassword == null || loginPassword.trim().isEmpty()) {
            errorMessage = "Password is required";
            lastUserId = loginUserId;
        } else {
            // Simple authentication (accepts any non-empty credentials for simulation)
            // In production, use AuthenticationService
            session.setAttribute("authenticated", true);
            session.setAttribute("username", loginUserId.trim().toUpperCase());
            session.setAttribute("userId", loginUserId.trim());
            session.setAttribute("userRole", "USER");
            session.setAttribute("solution", "FININFRA");
            session.setAttribute("loginTime", new java.util.Date());
            session.setAttribute("currentView", "home");
            session.setAttribute("currentFunction", "welcome");
            
            // Update local variables
            isAuthenticated = true;
            username = loginUserId.trim().toUpperCase();
            sessionView = "home";
            sessionFunction = "welcome";
        }
    }
    
    // Determine current view from session state
    String currentView = "login"; // default
    String functionId = "welcome"; // default
    
    if (isAuthenticated != null && isAuthenticated) {
        currentView = "home";
        functionId = (sessionFunction != null) ? sessionFunction : "welcome";
    }
    
    // Override with session view if set
    if (sessionView != null && !sessionView.isEmpty()) {
        if ("login".equals(sessionView)) {
            currentView = "login";
        } else if ("home".equals(sessionView) && isAuthenticated != null && isAuthenticated) {
            currentView = "home";
        }
    }
    
    // Set defaults
    if (solution == null) solution = "FININFRA";
    if (functionTitle == null) functionTitle = "Welcome";
    
    // Page title based on view
    String pageTitle = "login".equals(currentView) ? "Single Sign on Login Page" : "UCO Bank - Finacle Home";
    
    // Database connectivity status
    boolean dbConnected = false;
    String dbError = null;
    
    // Data from database
    List customerList = null;
    List accountList = null;
    List transactionList = null;
    List auditList = null;
    Customer selectedCustomer = null;
    Account selectedAccount = null;
    int retailCustomerCount = 0;
    int corporateCustomerCount = 0;
    int savingsAccountCount = 0;
    int currentAccountCount = 0;
    boolean demoMode = false;
    
    // Initialize DAOs and load data for authenticated users
    if (isAuthenticated != null && isAuthenticated && "home".equals(currentView)) {
        try {
            dbConnected = DatabaseConfig.isConnectionAvailable();
        } catch (Exception e) {
            dbConnected = false;
        }
        
        // Get common request parameters
        String searchTerm = request.getParameter("searchTerm");
        String customerId = request.getParameter("customerId");
        String accountId = request.getParameter("accountId");
        String crudAction = request.getParameter("crudAction");
            
        if (dbConnected) {
            // ========== DATABASE MODE ==========
            try {
                CustomerDAO customerDAO = new CustomerDAO();
                AccountDAO accountDAO = new AccountDAO();
                TransactionDAO transactionDAO = new TransactionDAO();
                AuditDAO auditDAO = new AuditDAO();
                
                // Get counts for dashboard
                retailCustomerCount = customerDAO.getCustomerCount("RETAIL");
                corporateCustomerCount = customerDAO.getCustomerCount("CORPORATE");
                savingsAccountCount = accountDAO.getAccountCount("SAVINGS");
                currentAccountCount = accountDAO.getAccountCount("CURRENT");
                
                // Load data based on current function
                if (functionId.contains("RETAIL")) {
                    customerList = customerDAO.searchCustomers(searchTerm, "RETAIL", null);
                } else if (functionId.contains("CORP")) {
                    customerList = customerDAO.searchCustomers(searchTerm, "CORPORATE", null);
                } else if (functionId.startsWith("ACC_")) {
                    String accType = null;
                    if (functionId.equals("ACC_SAVINGS")) accType = "SAVINGS";
                    else if (functionId.equals("ACC_CURRENT")) accType = "CURRENT";
                    else if (functionId.equals("ACC_FD")) accType = "FD";
                    else if (functionId.equals("ACC_RD")) accType = "RD";
                    accountList = accountDAO.getAllAccounts(accType);
                } else if (functionId.startsWith("TXN_") || functionId.equals("RPT_HISTORY")) {
                    transactionList = transactionDAO.getRecentTransactions(50);
                } else if (functionId.contains("AUDIT") || functionId.equals("ADMIN_AUDIT")) {
                    auditList = auditDAO.getRecentAuditLogs(50);
                }
                
                // Load specific customer/account for edit screens
                if (customerId != null && !customerId.isEmpty()) {
                    selectedCustomer = customerDAO.getCustomerById(customerId);
                    if (selectedCustomer != null) {
                        accountList = accountDAO.getAccountsByCustomerId(customerId);
                    }
                }
                if (accountId != null && !accountId.isEmpty()) {
                    selectedAccount = accountDAO.getAccountById(accountId);
                    if (selectedAccount != null) {
                        transactionList = transactionDAO.getTransactionsByAccountId(accountId, 20);
                    }
                }
                
                // Handle CRUD operations
                if (crudAction != null) {
                    try {
                        if ("createCustomer".equals(crudAction)) {
                            Customer newCust = new Customer();
                            newCust.setCustomerType(functionId.contains("CORP") ? "CORPORATE" : "RETAIL");
                            newCust.setFullName(request.getParameter("fullName"));
                            newCust.setEmail(request.getParameter("email"));
                            newCust.setMobile(request.getParameter("mobile"));
                            newCust.setAddressLine1(request.getParameter("addressLine1"));
                            newCust.setCity(request.getParameter("city"));
                            newCust.setState(request.getParameter("state"));
                            newCust.setPinCode(request.getParameter("pinCode"));
                            newCust.setPanNumber(request.getParameter("panNumber"));
                            newCust.setGender(request.getParameter("gender"));
                            Customer created = customerDAO.createCustomer(newCust, username);
                            successMessage = "Customer created successfully! ID: " + created.getCustomerId();
                        } else if ("updateCustomer".equals(crudAction) && customerId != null) {
                            Customer existing = customerDAO.getCustomerById(customerId);
                            if (existing != null) {
                                existing.setFullName(request.getParameter("fullName"));
                                existing.setEmail(request.getParameter("email"));
                                existing.setMobile(request.getParameter("mobile"));
                                existing.setAddressLine1(request.getParameter("addressLine1"));
                                existing.setCity(request.getParameter("city"));
                                existing.setState(request.getParameter("state"));
                                existing.setPinCode(request.getParameter("pinCode"));
                                existing.setKycStatus(request.getParameter("kycStatus"));
                                existing.setStatus(request.getParameter("status"));
                                customerDAO.updateCustomer(existing, username);
                                successMessage = "Customer updated successfully!";
                                selectedCustomer = customerDAO.getCustomerById(customerId);
                            }
                        } else if ("deposit".equals(crudAction) && accountId != null) {
                            BigDecimal amount = new BigDecimal(request.getParameter("amount"));
                            String desc = request.getParameter("description");
                            Transaction txn = transactionDAO.performDeposit(accountId, amount, "CASH", desc, "BR001", username);
                            successMessage = "Deposit successful! Transaction ID: " + txn.getTransactionId();
                            transactionList = transactionDAO.getTransactionsByAccountId(accountId, 20);
                        } else if ("withdraw".equals(crudAction) && accountId != null) {
                            BigDecimal amount = new BigDecimal(request.getParameter("amount"));
                            String desc = request.getParameter("description");
                            Transaction txn = transactionDAO.performWithdrawal(accountId, amount, "CASH", desc, "BR001", username);
                            successMessage = "Withdrawal successful! Transaction ID: " + txn.getTransactionId();
                            transactionList = transactionDAO.getTransactionsByAccountId(accountId, 20);
                        }
                    } catch (Exception e) {
                        errorMessage = "Error: " + e.getMessage();
                    }
                }
            } catch (Exception e) {
                dbError = e.getMessage();
                dbConnected = false;
            }
        }
        
        if (!dbConnected) {
            // ========== DEMO MODE ==========
            demoMode = true;
            
            // Get counts for dashboard from demo data
            retailCustomerCount = DemoDataService.getRetailCustomerCount();
            corporateCustomerCount = DemoDataService.getCorporateCustomerCount();
            savingsAccountCount = DemoDataService.getSavingsAccountCount();
            currentAccountCount = DemoDataService.getCurrentAccountCount();
            
            // Load demo data based on current function
            if (functionId.contains("RETAIL")) {
                customerList = DemoDataService.searchCustomers(searchTerm);
                // Filter to RETAIL only
                if (customerList != null) {
                    List filtered = new ArrayList();
                    for (Object o : customerList) {
                        Customer c = (Customer) o;
                        if ("RETAIL".equals(c.getCustomerType())) filtered.add(c);
                    }
                    customerList = filtered;
                }
            } else if (functionId.contains("CORP")) {
                customerList = DemoDataService.searchCustomers(searchTerm);
                // Filter to CORPORATE only
                if (customerList != null) {
                    List filtered = new ArrayList();
                    for (Object o : customerList) {
                        Customer c = (Customer) o;
                        if ("CORPORATE".equals(c.getCustomerType())) filtered.add(c);
                    }
                    customerList = filtered;
                }
            } else if (functionId.contains("EDIT") || functionId.contains("NEW")) {
                customerList = DemoDataService.getAllCustomers();
            } else if (functionId.startsWith("ACC_")) {
                String accType = null;
                if (functionId.equals("ACC_SAVINGS")) accType = "SAVINGS";
                else if (functionId.equals("ACC_CURRENT")) accType = "CURRENT";
                else if (functionId.equals("ACC_FD")) accType = "FD";
                else if (functionId.equals("ACC_RD")) accType = "RD";
                accountList = DemoDataService.getAccountsByType(accType);
            } else if (functionId.startsWith("TXN_") || functionId.equals("RPT_HISTORY")) {
                transactionList = DemoDataService.getAllTransactions();
            } else if (functionId.contains("AUDIT") || functionId.equals("ADMIN_AUDIT")) {
                String entityType = request.getParameter("entityType");
                String action = request.getParameter("action");
                auditList = DemoDataService.searchAuditLogs(entityType, action);
            }
            
            // Load specific customer/account for edit screens
            if (customerId != null && !customerId.isEmpty()) {
                selectedCustomer = DemoDataService.getCustomerById(customerId);
                if (selectedCustomer != null) {
                    accountList = DemoDataService.getAccountsByCustomerId(customerId);
                }
            }
            if (accountId != null && !accountId.isEmpty()) {
                selectedAccount = DemoDataService.getAccountById(accountId);
                if (selectedAccount != null) {
                    transactionList = DemoDataService.getTransactionsByAccountId(accountId);
                }
            }
            
            // Handle CRUD operations in demo mode
            if (crudAction != null) {
                try {
                    if ("createCustomer".equals(crudAction)) {
                        Customer newCust = new Customer();
                        newCust.setCustomerType(functionId.contains("CORP") ? "CORPORATE" : "RETAIL");
                        newCust.setFullName(request.getParameter("fullName"));
                        newCust.setEmail(request.getParameter("email"));
                        newCust.setMobile(request.getParameter("mobile"));
                        newCust.setAddressLine1(request.getParameter("addressLine1"));
                        newCust.setCity(request.getParameter("city"));
                        newCust.setState(request.getParameter("state"));
                        newCust.setPinCode(request.getParameter("pinCode"));
                        newCust.setPanNumber(request.getParameter("panNumber"));
                        newCust.setGender(request.getParameter("gender"));
                        Customer created = DemoDataService.createCustomer(newCust);
                        successMessage = "Customer created successfully! ID: " + created.getCustomerId() + " (Demo Mode)";
                    } else if ("updateCustomer".equals(crudAction) && customerId != null) {
                        Customer existing = DemoDataService.getCustomerById(customerId);
                        if (existing != null) {
                            existing.setFullName(request.getParameter("fullName"));
                            existing.setEmail(request.getParameter("email"));
                            existing.setMobile(request.getParameter("mobile"));
                            existing.setAddressLine1(request.getParameter("addressLine1"));
                            existing.setCity(request.getParameter("city"));
                            existing.setState(request.getParameter("state"));
                            existing.setPinCode(request.getParameter("pinCode"));
                            existing.setKycStatus(request.getParameter("kycStatus"));
                            existing.setStatus(request.getParameter("status"));
                            DemoDataService.updateCustomer(existing);
                            successMessage = "Customer updated successfully! (Demo Mode)";
                            selectedCustomer = DemoDataService.getCustomerById(customerId);
                        }
                    } else if ("deposit".equals(crudAction) && accountId != null) {
                        BigDecimal amount = new BigDecimal(request.getParameter("amount"));
                        String desc = request.getParameter("description");
                        Transaction txn = DemoDataService.performDeposit(accountId, amount, desc);
                        if (txn != null) {
                            successMessage = "Deposit successful! Transaction ID: " + txn.getTransactionId() + " (Demo Mode)";
                            transactionList = DemoDataService.getTransactionsByAccountId(accountId);
                        } else {
                            errorMessage = "Deposit failed - Account not found";
                        }
                    } else if ("withdraw".equals(crudAction) && accountId != null) {
                        BigDecimal amount = new BigDecimal(request.getParameter("amount"));
                        String desc = request.getParameter("description");
                        Transaction txn = DemoDataService.performWithdrawal(accountId, amount, desc);
                        if (txn != null) {
                            successMessage = "Withdrawal successful! Transaction ID: " + txn.getTransactionId() + " (Demo Mode)";
                            transactionList = DemoDataService.getTransactionsByAccountId(accountId);
                        } else {
                            errorMessage = "Withdrawal failed - Insufficient balance or account not found";
                        }
                    }
                } catch (Exception e) {
                    errorMessage = "Error: " + e.getMessage();
                }
            }
        }
    }
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
        
        // Logout - submit hidden form via POST
        function doLogout() {
            if (confirm('Are you sure you want to logout?')) {
                document.getElementById('navFormAction').value = 'logout';
                document.getElementById('navFormFunctionId').value = '';
                document.getElementById('navigationForm').submit();
            }
        }
        
        // Load function content - submit hidden form via POST (URL never changes)
        function loadFunction(functionId) {
            document.getElementById('navFormAction').value = 'navigate';
            document.getElementById('navFormFunctionId').value = functionId;
            document.getElementById('navigationForm').submit();
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
    <script>
        if (!window.__VUNET_RUM_LOADED__) {
            window.__VUNET_RUM_LOADED__ = true;
            (function (e, t, n, _, s, a) {
                e[t] = e[t] || {
                    readyListeners: [],
                    onReady: function (n) {
                        e[t].readyListeners.push(n);
                    }
                };
                s = n.createElement("script");
                s.async = 1;
                s.src = "https://cdn.vunet.ai/rum/vunet-rum.js";
                a = n.getElementsByTagName("script")[0];
                a.parentNode.insertBefore(s, a);
            })(window, "vunetRum", document);

            window.vunetRum.onReady(function () {
                window.vunetRum.initialize({
                    collectionSourceUrl: "https://brum.vunetsystems.com/rum/v1/traces",
                    serviceName: "vubank-frontend",
                    applicationName: "IBMB",
                    collectErrors: true,
                    decideApiEndpoint: "sr:100,sp:100",
                    dropShortTracesMs: 100,
                    ignoreUrls: [/\/rum\/v1\/.*/i, /\/vusmartmaps\/.*/i]
                }).then(() => {
                    let t = "anonymous";
                    try {
                        t = window.sessionUser;
                    } finally {
                        window.vunetRum.mapUser(t, {
                            isAuthenticated: window.isAuthenticated,
                            currentView: window.currentView,
                            currentFunction: window.currentFunction
                        });
                    }
                });
            });
        }
    </script>
</head>
<body>

<!-- Hidden Navigation Form - Used for all internal navigation via POST -->
<form id="navigationForm" method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp" style="display:none;">
    <input type="hidden" id="navFormAction" name="formAction" value="" />
    <input type="hidden" id="navFormFunctionId" name="functionId" value="" />
</form><% if ("login".equals(currentView)) { %>
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
                <form name="loginForm" method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp" onsubmit="return validateLogin();">
                    <input type="hidden" name="formAction" value="login" />
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
                    <span class="icon-button" title="Database Admin" onclick="window.location.href='<%=request.getContextPath()%>/admin/status'">🔧</span>
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
            
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="success-box" style="margin-bottom: 15px;">
                <strong>✓</strong> <%= successMessage %>
            </div>
            <% } %>
            
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="error-box" style="margin-bottom: 15px;">
                <strong>Error:</strong> <%= errorMessage %>
            </div>
            <% } %>
            
            <p style="font-size: 14px; margin-bottom: 20px;">
                Hello <strong><%= username %></strong>, you are logged into the <strong><%= solution %></strong> solution.
                <br/>Please select a function from the left menu to begin.
            </p>
            
            <!-- Database Status -->
            <% if (demoMode) { %>
            <div style="padding: 10px; margin-bottom: 20px; border-radius: 5px; background-color: #fff3e0; border: 1px solid #ff9800;">
                <strong>🎭 Demo Mode Active</strong>
                <span style="color: #666; font-size: 11px;"> - Using sample data (Oracle @ 10.1.92.130:1521 not reachable)</span>
                <div style="font-size: 11px; color: #e65100; margin-top: 5px;">All changes are stored in memory and will reset on server restart.</div>
            </div>
            <% } else if (dbConnected) { %>
            <div style="padding: 10px; margin-bottom: 20px; border-radius: 5px; background-color: #e8f5e9; border: 1px solid #4caf50;">
                <strong>✓ Database Connected</strong>
                <span style="color: #666; font-size: 11px;"> - Oracle @ 10.1.92.130:1521</span>
            </div>
            <% } else { %>
            <div style="padding: 10px; margin-bottom: 20px; border-radius: 5px; background-color: #ffebee; border: 1px solid #f44336;">
                <strong>✗ Database Offline</strong>
                <span style="color: #666; font-size: 11px;"> - Oracle @ 10.1.92.130:1521</span>
                <% if (dbError != null) { %>
                <div style="font-size: 11px; color: #cc0000; margin-top: 5px;"><%= dbError %></div>
                <% } %>
            </div>
            <% } %>
            
            <!-- Dashboard Stats -->
            <h3 style="color: #2e5f9e; margin-bottom: 15px;">📊 Dashboard Statistics <%= demoMode ? "(Demo Data)" : "" %></h3>
            <div style="display: flex; gap: 15px; margin-bottom: 25px; flex-wrap: wrap;">
                <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; width: 180px; text-align: center;">
                    <div style="font-size: 28px; font-weight: bold;"><%= retailCustomerCount %></div>
                    <div style="font-size: 12px;">Retail Customers</div>
                </div>
                <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 20px; border-radius: 8px; width: 180px; text-align: center;">
                    <div style="font-size: 28px; font-weight: bold;"><%= corporateCustomerCount %></div>
                    <div style="font-size: 12px;">Corporate Customers</div>
                </div>
                <div style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; padding: 20px; border-radius: 8px; width: 180px; text-align: center;">
                    <div style="font-size: 28px; font-weight: bold;"><%= savingsAccountCount %></div>
                    <div style="font-size: 12px;">Savings Accounts</div>
                </div>
                <div style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white; padding: 20px; border-radius: 8px; width: 180px; text-align: center;">
                    <div style="font-size: 28px; font-weight: bold;"><%= currentAccountCount %></div>
                    <div style="font-size: 12px;">Current Accounts</div>
                </div>
            </div>
            
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
            
            <% if (successMessage != null) { %><div class="success-box" style="margin-bottom:10px;"><strong>✓</strong> <%= successMessage %></div><% } %>
            <% if (errorMessage != null) { %><div class="error-box" style="margin-bottom:10px;"><strong>Error:</strong> <%= errorMessage %></div><% } %>
            
            <div class="form-section">
                <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp">
                    <input type="hidden" name="formAction" value="navigate" />
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Entity ID:</td>
                            <td><input type="text" name="entityId" class="form-input" value="<%= request.getParameter("entityId") != null ? request.getParameter("entityId") : "" %>" /></td>
                            <td class="form-label">From Date:</td>
                            <td><input type="date" name="fromDate" class="form-input" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Entity Type:</td>
                            <td>
                                <select name="entityType" class="form-input">
                                    <option value="">All Types</option>
                                    <option value="CUSTOMER">Customer</option>
                                    <option value="ACCOUNT">Account</option>
                                    <option value="TRANSACTION">Transaction</option>
                                </select>
                            </td>
                            <td class="form-label">To Date:</td>
                            <td><input type="date" name="toDate" class="form-input" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Action:</td>
                            <td>
                                <select name="action" class="form-input">
                                    <option value="">All Actions</option>
                                    <option value="CREATE">Create</option>
                                    <option value="UPDATE">Update</option>
                                    <option value="DELETE">Delete</option>
                                    <option value="DEPOSIT">Deposit</option>
                                    <option value="WITHDRAWAL">Withdrawal</option>
                                </select>
                            </td>
                            <td colspan="2">
                                <button type="submit" class="form-button">🔍 Search</button>
                                <button type="reset" class="form-button secondary">Clear</button>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
            
            <h3 style="color: #2e5f9e;">Audit Log Records (<%= auditList != null ? auditList.size() : 0 %> records)</h3>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Audit ID</th>
                        <th>Timestamp</th>
                        <th>Entity Type</th>
                        <th>Entity ID</th>
                        <th>Action</th>
                        <th>User</th>
                        <th>Remarks</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (auditList != null && auditList.size() > 0) {
                        for (Object obj : auditList) {
                            AuditLog log = (AuditLog) obj;
                    %>
                    <tr>
                        <td><%= log.getAuditId() %></td>
                        <td><%= log.getActionDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(log.getActionDate()) : "-" %></td>
                        <td><%= log.getEntityType() %></td>
                        <td><a href="#" onclick="loadFunction('<%= functionId.contains("RETAIL") ? "CIF_RETAIL_EDIT" : "CIF_CORP_EDIT" %>'); return false;" style="color: #2e5f9e;"><%= log.getEntityId() %></a></td>
                        <td><span style="padding: 2px 8px; border-radius: 3px; background-color: <%= "CREATE".equals(log.getAction()) ? "#4caf50" : "UPDATE".equals(log.getAction()) ? "#2196f3" : "DELETE".equals(log.getAction()) ? "#f44336" : "#9e9e9e" %>; color: white; font-size: 10px;"><%= log.getAction() %></span></td>
                        <td><%= log.getUserId() %></td>
                        <td><%= log.getRemarks() != null ? log.getRemarks() : "-" %></td>
                    </tr>
                    <% }} else { %>
                    <tr>
                        <td colspan="7" align="center" style="padding: 20px; color: #999;">
                            <%= dbConnected ? "No audit records found." : "Database not connected. Please check Oracle connection." %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            
            <% } else if (functionId.contains("EDIT")) { %>
            <!-- EDIT ENTITY SCREEN -->
            <h2 class="content-title"><%= functionTitle != null ? functionTitle : "Edit Entity" %></h2>
            
            <% if (successMessage != null) { %><div class="success-box" style="margin-bottom:10px;"><strong>✓</strong> <%= successMessage %></div><% } %>
            <% if (errorMessage != null) { %><div class="error-box" style="margin-bottom:10px;"><strong>Error:</strong> <%= errorMessage %></div><% } %>
            
            <div class="form-section">
                <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp">
                    <input type="hidden" name="formAction" value="navigate" />
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Customer ID:</td>
                            <td><input type="text" name="customerId" class="form-input" value="<%= request.getParameter("customerId") != null ? request.getParameter("customerId") : "" %>" required /></td>
                            <td><button type="submit" class="form-button">🔍 Search</button></td>
                        </tr>
                    </table>
                </form>
            </div>
            
            <% if (selectedCustomer != null) { %>
            <div class="form-section">
                <h3 style="color: #2e5f9e; margin-bottom: 15px;">Customer Details - <%= selectedCustomer.getCustomerId() %></h3>
                <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp">
                    <input type="hidden" name="formAction" value="navigate" />
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <input type="hidden" name="customerId" value="<%= selectedCustomer.getCustomerId() %>" />
                    <input type="hidden" name="crudAction" value="updateCustomer" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Customer ID:</td>
                            <td><input type="text" class="form-input" value="<%= selectedCustomer.getCustomerId() %>" disabled style="background:#eee;" /></td>
                            <td class="form-label">Type:</td>
                            <td><input type="text" class="form-input" value="<%= selectedCustomer.getCustomerType() %>" disabled style="background:#eee;" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Full Name: *</td>
                            <td><input type="text" name="fullName" class="form-input" value="<%= selectedCustomer.getFullName() %>" required /></td>
                            <td class="form-label">Gender:</td>
                            <td>
                                <select name="gender" class="form-input">
                                    <option value="MALE" <%= "MALE".equals(selectedCustomer.getGender()) ? "selected" : "" %>>Male</option>
                                    <option value="FEMALE" <%= "FEMALE".equals(selectedCustomer.getGender()) ? "selected" : "" %>>Female</option>
                                    <option value="OTHER" <%= "OTHER".equals(selectedCustomer.getGender()) ? "selected" : "" %>>Other</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td class="form-label">Email:</td>
                            <td><input type="email" name="email" class="form-input" value="<%= selectedCustomer.getEmail() != null ? selectedCustomer.getEmail() : "" %>" /></td>
                            <td class="form-label">Mobile: *</td>
                            <td><input type="tel" name="mobile" class="form-input" value="<%= selectedCustomer.getMobile() != null ? selectedCustomer.getMobile() : "" %>" required /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Address:</td>
                            <td colspan="3"><input type="text" name="addressLine1" class="form-input" style="width:90%;" value="<%= selectedCustomer.getAddressLine1() != null ? selectedCustomer.getAddressLine1() : "" %>" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">City:</td>
                            <td><input type="text" name="city" class="form-input" value="<%= selectedCustomer.getCity() != null ? selectedCustomer.getCity() : "" %>" /></td>
                            <td class="form-label">State:</td>
                            <td><input type="text" name="state" class="form-input" value="<%= selectedCustomer.getState() != null ? selectedCustomer.getState() : "" %>" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">PIN Code:</td>
                            <td><input type="text" name="pinCode" class="form-input" value="<%= selectedCustomer.getPinCode() != null ? selectedCustomer.getPinCode() : "" %>" /></td>
                            <td class="form-label">PAN Number:</td>
                            <td><input type="text" class="form-input" value="<%= selectedCustomer.getPanNumber() != null ? selectedCustomer.getPanNumber() : "" %>" disabled style="background:#eee;" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">KYC Status:</td>
                            <td>
                                <select name="kycStatus" class="form-input">
                                    <option value="PENDING" <%= "PENDING".equals(selectedCustomer.getKycStatus()) ? "selected" : "" %>>Pending</option>
                                    <option value="VERIFIED" <%= "VERIFIED".equals(selectedCustomer.getKycStatus()) ? "selected" : "" %>>Verified</option>
                                    <option value="REJECTED" <%= "REJECTED".equals(selectedCustomer.getKycStatus()) ? "selected" : "" %>>Rejected</option>
                                </select>
                            </td>
                            <td class="form-label">Status:</td>
                            <td>
                                <select name="status" class="form-input">
                                    <option value="ACTIVE" <%= "ACTIVE".equals(selectedCustomer.getStatus()) ? "selected" : "" %>>Active</option>
                                    <option value="INACTIVE" <%= "INACTIVE".equals(selectedCustomer.getStatus()) ? "selected" : "" %>>Inactive</option>
                                    <option value="BLOCKED" <%= "BLOCKED".equals(selectedCustomer.getStatus()) ? "selected" : "" %>>Blocked</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4" align="center" style="padding-top: 15px;">
                                <button type="submit" class="form-button">💾 Update Customer</button>
                                <button type="button" class="form-button secondary" onclick="loadFunction('welcome')">Cancel</button>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
            
            <% if (accountList != null && accountList.size() > 0) { %>
            <h3 style="color: #2e5f9e; margin-top: 20px;">Linked Accounts (<%= accountList.size() %>)</h3>
            <table class="data-table">
                <thead>
                    <tr><th>Account ID</th><th>Type</th><th>Balance</th><th>Status</th><th>Actions</th></tr>
                </thead>
                <tbody>
                    <% for (Object obj : accountList) { Account acc = (Account) obj; %>
                    <tr>
                        <td><%= acc.getAccountId() %></td>
                        <td><%= acc.getAccountType() %></td>
                        <td style="text-align:right; font-weight:bold;">₹ <%= String.format("%,.2f", acc.getBalance()) %></td>
                        <td><span style="padding:2px 8px; border-radius:3px; background-color:<%= "ACTIVE".equals(acc.getStatus()) ? "#4caf50" : "#f44336" %>; color:white; font-size:10px;"><%= acc.getStatus() %></span></td>
                        <td><a href="#" onclick="document.getElementById('navFormFunctionId').value='RPT_STATEMENT'; document.getElementById('navigationForm').submit();" style="color:#2e5f9e;">View Statement</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
            <% } else if (customerList != null && customerList.size() > 0) { %>
            <h3 style="color: #2e5f9e; margin-top: 20px;">Available Customers (<%= customerList.size() %>)</h3>
            <table class="data-table">
                <thead>
                    <tr><th>Customer ID</th><th>Name</th><th>Type</th><th>Mobile</th><th>City</th><th>Status</th><th>Actions</th></tr>
                </thead>
                <tbody>
                    <% for (Object obj : customerList) { Customer c = (Customer) obj; %>
                    <tr>
                        <td><%= c.getCustomerId() %></td>
                        <td><%= c.getFullName() %></td>
                        <td><%= c.getCustomerType() %></td>
                        <td><%= c.getMobile() != null ? c.getMobile() : "-" %></td>
                        <td><%= c.getCity() != null ? c.getCity() : "-" %></td>
                        <td><span style="padding:2px 8px; border-radius:3px; background-color:<%= "ACTIVE".equals(c.getStatus()) ? "#4caf50" : "#f44336" %>; color:white; font-size:10px;"><%= c.getStatus() %></span></td>
                        <td>
                            <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp" style="display:inline;">
                                <input type="hidden" name="formAction" value="navigate" />
                                <input type="hidden" name="functionId" value="<%= functionId %>" />
                                <input type="hidden" name="customerId" value="<%= c.getCustomerId() %>" />
                                <button type="submit" class="form-button" style="padding:2px 10px; font-size:11px;">✏️ Edit</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
            
            <% } else if (functionId.contains("NEW")) { %>
            <!-- NEW ENTITY SCREEN -->
            <h2 class="content-title"><%= functionTitle != null ? functionTitle : "Create New Entity" %></h2>
            
            <% if (successMessage != null) { %><div class="success-box" style="margin-bottom:10px;"><strong>✓</strong> <%= successMessage %></div><% } %>
            <% if (errorMessage != null) { %><div class="error-box" style="margin-bottom:10px;"><strong>Error:</strong> <%= errorMessage %></div><% } %>
            
            <div class="form-section">
                <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp">
                    <input type="hidden" name="formAction" value="navigate" />
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <input type="hidden" name="crudAction" value="createCustomer" />
                    
                    <h3 style="color: #2e5f9e; margin-bottom: 15px;">Personal Information</h3>
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Customer Type: *</td>
                            <td>
                                <select name="customerType" class="form-input" required>
                                    <option value="">-- Select --</option>
                                    <option value="RETAIL">Retail (Individual)</option>
                                    <option value="CORPORATE">Corporate</option>
                                </select>
                            </td>
                            <td class="form-label">Full Name: *</td>
                            <td><input type="text" name="fullName" class="form-input" required placeholder="Enter full name" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Date of Birth:</td>
                            <td><input type="date" name="dateOfBirth" class="form-input" /></td>
                            <td class="form-label">Gender:</td>
                            <td>
                                <select name="gender" class="form-input">
                                    <option value="">-- Select --</option>
                                    <option value="MALE">Male</option>
                                    <option value="FEMALE">Female</option>
                                    <option value="OTHER">Other</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td class="form-label">PAN Number:</td>
                            <td><input type="text" name="panNumber" class="form-input" pattern="[A-Z]{5}[0-9]{4}[A-Z]{1}" placeholder="ABCDE1234F" /></td>
                            <td class="form-label">Aadhaar Number:</td>
                            <td><input type="text" name="aadhaarNumber" class="form-input" pattern="[0-9]{12}" placeholder="12 digit Aadhaar" /></td>
                        </tr>
                    </table>
                    
                    <h3 style="color: #2e5f9e; margin: 20px 0 15px 0;">Contact Details</h3>
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Email:</td>
                            <td><input type="email" name="email" class="form-input" placeholder="email@example.com" /></td>
                            <td class="form-label">Mobile: *</td>
                            <td><input type="tel" name="mobile" class="form-input" required pattern="[0-9]{10}" placeholder="10 digit mobile" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Address Line 1:</td>
                            <td colspan="3"><input type="text" name="addressLine1" class="form-input" style="width:90%;" placeholder="Street address" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Address Line 2:</td>
                            <td colspan="3"><input type="text" name="addressLine2" class="form-input" style="width:90%;" placeholder="Apartment, suite, etc." /></td>
                        </tr>
                        <tr>
                            <td class="form-label">City:</td>
                            <td><input type="text" name="city" class="form-input" placeholder="City" /></td>
                            <td class="form-label">State:</td>
                            <td><input type="text" name="state" class="form-input" placeholder="State" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">PIN Code:</td>
                            <td><input type="text" name="pinCode" class="form-input" pattern="[0-9]{6}" placeholder="6 digit PIN" /></td>
                            <td class="form-label">Country:</td>
                            <td><input type="text" name="country" class="form-input" value="India" /></td>
                        </tr>
                    </table>
                    
                    <h3 style="color: #2e5f9e; margin: 20px 0 15px 0;">Account Options</h3>
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Open Account:</td>
                            <td>
                                <label><input type="checkbox" name="openAccount" value="SAVINGS" /> Savings Account</label>
                            </td>
                            <td class="form-label">Initial Deposit:</td>
                            <td><input type="number" name="initialDeposit" class="form-input" value="1000" min="500" step="100" /></td>
                        </tr>
                    </table>
                    
                    <div style="text-align: center; padding-top: 20px; border-top: 1px solid #ddd; margin-top: 20px;">
                        <button type="submit" class="form-button" style="padding: 8px 25px;">➕ Create Customer</button>
                        <button type="reset" class="form-button secondary" style="padding: 8px 25px;">🔄 Reset</button>
                        <button type="button" class="form-button secondary" onclick="loadFunction('welcome')" style="padding: 8px 25px;">✖ Cancel</button>
                    </div>
                </form>
            </div>
            
            <% } else if (functionId.startsWith("ACC_") || functionId.contains("ACCOUNT")) { %>
            <!-- ACCOUNTS SCREEN -->
            <h2 class="content-title"><%= functionTitle != null ? functionTitle : "Account Management" %></h2>
            
            <% if (successMessage != null) { %><div class="success-box" style="margin-bottom:10px;"><strong>✓</strong> <%= successMessage %></div><% } %>
            <% if (errorMessage != null) { %><div class="error-box" style="margin-bottom:10px;"><strong>Error:</strong> <%= errorMessage %></div><% } %>
            
            <div class="form-section">
                <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp">
                    <input type="hidden" name="formAction" value="navigate" />
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Account Type:</td>
                            <td>
                                <select name="accountType" class="form-input">
                                    <option value="">All Types</option>
                                    <option value="SAVINGS" <%= "SAVINGS".equals(request.getParameter("accountType")) ? "selected" : "" %>>Savings</option>
                                    <option value="CURRENT" <%= "CURRENT".equals(request.getParameter("accountType")) ? "selected" : "" %>>Current</option>
                                    <option value="FD" <%= "FD".equals(request.getParameter("accountType")) ? "selected" : "" %>>Fixed Deposit</option>
                                    <option value="RD" <%= "RD".equals(request.getParameter("accountType")) ? "selected" : "" %>>Recurring Deposit</option>
                                </select>
                            </td>
                            <td class="form-label">Status:</td>
                            <td>
                                <select name="status" class="form-input">
                                    <option value="">All Status</option>
                                    <option value="ACTIVE">Active</option>
                                    <option value="DORMANT">Dormant</option>
                                    <option value="CLOSED">Closed</option>
                                </select>
                            </td>
                            <td><button type="submit" class="form-button">🔍 Search</button></td>
                        </tr>
                    </table>
                </form>
            </div>
            
            <% if (accountList != null && accountList.size() > 0) { %>
            <h3 style="color: #2e5f9e; margin-top: 20px;">Accounts Found (<%= accountList.size() %>)</h3>
            <table class="data-table">
                <thead>
                    <tr><th>Account ID</th><th>Customer</th><th>Type</th><th>Balance</th><th>Interest Rate</th><th>Status</th><th>Opened Date</th><th>Actions</th></tr>
                </thead>
                <tbody>
                    <% for (Object obj : accountList) { Account acc = (Account) obj; %>
                    <tr>
                        <td><strong><%= acc.getAccountId() %></strong></td>
                        <td><a href="#" onclick="document.getElementById('navFormFunctionId').value='ENT_EDIT'; document.getElementById('navigationForm').elements['customerId'].value='<%= acc.getCustomerId() %>'; document.getElementById('navigationForm').submit();" style="color:#2e5f9e;"><%= acc.getCustomerId() %></a></td>
                        <td><span style="padding:2px 8px; border-radius:3px; background-color:#2196f3; color:white; font-size:10px;"><%= acc.getAccountType() %></span></td>
                        <td style="text-align:right; font-weight:bold; color: <%= acc.getBalance() != null && acc.getBalance().compareTo(java.math.BigDecimal.ZERO) >= 0 ? "#4caf50" : "#f44336" %>;">₹ <%= acc.getBalance() != null ? String.format("%,.2f", acc.getBalance()) : "0.00" %></td>
                        <td style="text-align:right;"><%= acc.getInterestRate() != null ? String.format("%.2f", acc.getInterestRate()) : "0.00" %>%</td>
                        <td><span style="padding:2px 8px; border-radius:3px; background-color:<%= "ACTIVE".equals(acc.getStatus()) ? "#4caf50" : "#9e9e9e" %>; color:white; font-size:10px;"><%= acc.getStatus() %></span></td>
                        <td><%= acc.getOpeningDate() != null ? new java.text.SimpleDateFormat("dd-MMM-yyyy").format(acc.getOpeningDate()) : "-" %></td>
                        <td>
                            <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp" style="display:inline;">
                                <input type="hidden" name="formAction" value="navigate" />
                                <input type="hidden" name="functionId" value="TXN_DEPOSIT" />
                                <input type="hidden" name="accountId" value="<%= acc.getAccountId() %>" />
                                <button type="submit" class="form-button" style="padding:2px 8px; font-size:10px; background:#4caf50;">💰 Deposit</button>
                            </form>
                            <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp" style="display:inline;">
                                <input type="hidden" name="formAction" value="navigate" />
                                <input type="hidden" name="functionId" value="TXN_WITHDRAW" />
                                <input type="hidden" name="accountId" value="<%= acc.getAccountId() %>" />
                                <button type="submit" class="form-button" style="padding:2px 8px; font-size:10px; background:#ff9800;">💸 Withdraw</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="form-section">
                <p style="color:#666;">No accounts found. Use the search form above or <a href="#" onclick="loadFunction('welcome')">go to home</a>.</p>
            </div>
            <% } %>
            
            <% } else if (functionId.startsWith("TXN_") || functionId.contains("TRANSACTION")) { %>
            <!-- TRANSACTIONS SCREEN -->
            <h2 class="content-title"><%= functionTitle != null ? functionTitle : "Transactions" %></h2>
            
            <% if (successMessage != null) { %><div class="success-box" style="margin-bottom:10px;"><strong>✓</strong> <%= successMessage %></div><% } %>
            <% if (errorMessage != null) { %><div class="error-box" style="margin-bottom:10px;"><strong>Error:</strong> <%= errorMessage %></div><% } %>
            
            <% 
            String txnType = "";
            if (functionId.contains("DEPOSIT")) txnType = "DEPOSIT";
            else if (functionId.contains("WITHDRAW")) txnType = "WITHDRAW";
            else if (functionId.contains("TRANSFER")) txnType = "TRANSFER";
            String selectedAccountId = request.getParameter("accountId") != null ? request.getParameter("accountId") : "";
            %>
            
            <div class="form-section">
                <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp">
                    <input type="hidden" name="formAction" value="navigate" />
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <input type="hidden" name="crudAction" value="<%= txnType.toLowerCase() %>" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Account ID: *</td>
                            <td><input type="text" name="accountId" class="form-input" value="<%= selectedAccountId %>" required placeholder="Enter Account ID" /></td>
                            <td class="form-label">Amount: *</td>
                            <td><input type="number" name="amount" class="form-input" min="1" step="0.01" required placeholder="Enter amount" /></td>
                        </tr>
                        <% if ("TRANSFER".equals(txnType)) { %>
                        <tr>
                            <td class="form-label">To Account: *</td>
                            <td><input type="text" name="toAccountId" class="form-input" required placeholder="Destination Account ID" /></td>
                            <td></td><td></td>
                        </tr>
                        <% } %>
                        <tr>
                            <td class="form-label">Description:</td>
                            <td colspan="3"><input type="text" name="description" class="form-input" style="width:90%;" placeholder="Transaction remarks (optional)" /></td>
                        </tr>
                        <tr>
                            <td colspan="4" align="center" style="padding-top: 15px;">
                                <% if ("DEPOSIT".equals(txnType)) { %>
                                <button type="submit" class="form-button" style="background:#4caf50; padding: 8px 25px;">💰 Deposit</button>
                                <% } else if ("WITHDRAW".equals(txnType)) { %>
                                <button type="submit" class="form-button" style="background:#ff9800; padding: 8px 25px;">💸 Withdraw</button>
                                <% } else if ("TRANSFER".equals(txnType)) { %>
                                <button type="submit" class="form-button" style="background:#2196f3; padding: 8px 25px;">🔄 Transfer</button>
                                <% } else { %>
                                <button type="submit" class="form-button" style="padding: 8px 25px;">Submit</button>
                                <% } %>
                                <button type="button" class="form-button secondary" onclick="loadFunction('welcome')" style="padding: 8px 25px;">Cancel</button>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
            
            <% if (transactionList != null && transactionList.size() > 0) { %>
            <h3 style="color: #2e5f9e; margin-top: 20px;">Recent Transactions (<%= transactionList.size() %>)</h3>
            <table class="data-table">
                <thead>
                    <tr><th>Txn ID</th><th>Date</th><th>Type</th><th>Account</th><th>Amount</th><th>Ref No</th><th>Description</th></tr>
                </thead>
                <tbody>
                    <% for (Object obj : transactionList) { Transaction txn = (Transaction) obj; %>
                    <tr>
                        <td><%= txn.getTransactionId() %></td>
                        <td><%= txn.getTransactionDate() != null ? new java.text.SimpleDateFormat("dd-MMM-yyyy HH:mm").format(txn.getTransactionDate()) : "-" %></td>
                        <td><span style="padding:2px 8px; border-radius:3px; background-color:<%= "CREDIT".equals(txn.getTransactionType()) ? "#4caf50" : "#f44336" %>; color:white; font-size:10px;"><%= txn.getTransactionType() %></span></td>
                        <td><%= txn.getAccountId() %></td>
                        <td style="text-align:right; font-weight:bold; color: <%= "CREDIT".equals(txn.getTransactionType()) ? "#4caf50" : "#f44336" %>;">
                            <%= "CREDIT".equals(txn.getTransactionType()) ? "+" : "-" %> ₹ <%= txn.getAmount() != null ? String.format("%,.2f", txn.getAmount()) : "0.00" %>
                        </td>
                        <td><%= txn.getReferenceNo() != null ? txn.getReferenceNo() : "-" %></td>
                        <td><%= txn.getDescription() != null ? txn.getDescription() : "-" %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
            
            <% } else if (functionId.startsWith("RPT_") || functionId.contains("REPORT")) { %>
            <!-- REPORTS SCREEN -->
            <h2 class="content-title"><%= functionTitle != null ? functionTitle : "Reports" %></h2>
            
            <div class="form-section">
                <form method="POST" action="<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp">
                    <input type="hidden" name="formAction" value="navigate" />
                    <input type="hidden" name="functionId" value="<%= functionId %>" />
                    <table class="form-table">
                        <tr>
                            <td class="form-label">Account ID:</td>
                            <td><input type="text" name="accountId" class="form-input" value="<%= request.getParameter("accountId") != null ? request.getParameter("accountId") : "" %>" /></td>
                            <td class="form-label">From Date:</td>
                            <td><input type="date" name="fromDate" class="form-input" /></td>
                        </tr>
                        <tr>
                            <td class="form-label">Report Type:</td>
                            <td>
                                <select name="reportType" class="form-input">
                                    <option value="STATEMENT">Account Statement</option>
                                    <option value="SUMMARY">Account Summary</option>
                                    <option value="INTEREST">Interest Report</option>
                                </select>
                            </td>
                            <td class="form-label">To Date:</td>
                            <td><input type="date" name="toDate" class="form-input" /></td>
                        </tr>
                        <tr>
                            <td colspan="4" align="center" style="padding-top: 15px;">
                                <button type="submit" class="form-button">📊 Generate Report</button>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
            
            <% if (transactionList != null && transactionList.size() > 0) { %>
            <h3 style="color: #2e5f9e; margin-top: 20px;">Statement</h3>
            <table class="data-table">
                <thead>
                    <tr><th>Date</th><th>Description</th><th>Debit</th><th>Credit</th><th>Balance</th></tr>
                </thead>
                <tbody>
                    <% 
                    java.math.BigDecimal runningBalance = java.math.BigDecimal.ZERO;
                    for (Object obj : transactionList) { Transaction txn = (Transaction) obj;
                        java.math.BigDecimal amt = txn.getAmount() != null ? txn.getAmount() : java.math.BigDecimal.ZERO;
                        if ("CREDIT".equals(txn.getTransactionType())) {
                            runningBalance = runningBalance.add(amt);
                        } else {
                            runningBalance = runningBalance.subtract(amt);
                        }
                    %>
                    <tr>
                        <td><%= txn.getTransactionDate() != null ? new java.text.SimpleDateFormat("dd-MMM-yyyy").format(txn.getTransactionDate()) : "-" %></td>
                        <td><%= txn.getDescription() != null ? txn.getDescription() : txn.getTransactionType() %></td>
                        <td style="text-align:right; color:#f44336;"><%= "DEBIT".equals(txn.getTransactionType()) ? "₹ " + String.format("%,.2f", txn.getAmount()) : "" %></td>
                        <td style="text-align:right; color:#4caf50;"><%= "CREDIT".equals(txn.getTransactionType()) ? "₹ " + String.format("%,.2f", txn.getAmount()) : "" %></td>
                        <td style="text-align:right; font-weight:bold;">₹ <%= String.format("%,.2f", runningBalance) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
            
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