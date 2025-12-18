package com.ucobank.finacle.servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.ucobank.finacle.dao.*;
import com.ucobank.finacle.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Data Servlet - Handles all AJAX data operations
 * Provides CRUD operations for customers, accounts, transactions
 */
@WebServlet("/api/data/*")
public class DataServlet extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAO();
    private final AccountDAO accountDAO = new AccountDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final AuditDAO auditDAO = new AuditDAO();
    private final Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "/";

        try {
            Map<String, Object> result = new HashMap<>();

            switch (pathInfo) {
                case "/customers":
                    handleGetCustomers(request, result);
                    break;
                case "/customer":
                    handleGetCustomer(request, result);
                    break;
                case "/accounts":
                    handleGetAccounts(request, result);
                    break;
                case "/account":
                    handleGetAccount(request, result);
                    break;
                case "/transactions":
                    handleGetTransactions(request, result);
                    break;
                case "/audit":
                    handleGetAuditLogs(request, result);
                    break;
                case "/dashboard":
                    handleGetDashboard(request, result);
                    break;
                case "/search":
                    handleSearch(request, result);
                    break;
                default:
                    result.put("success", false);
                    result.put("error", "Unknown endpoint: " + pathInfo);
            }

            out.print(gson.toJson(result));

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            out.print(gson.toJson(error));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "/";

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String userId = user != null ? user.getUserId() : "SYSTEM";

        try {
            Map<String, Object> result = new HashMap<>();

            switch (pathInfo) {
                case "/customer/create":
                    handleCreateCustomer(request, userId, result);
                    break;
                case "/customer/update":
                    handleUpdateCustomer(request, userId, result);
                    break;
                case "/customer/delete":
                    handleDeleteCustomer(request, userId, result);
                    break;
                case "/account/create":
                    handleCreateAccount(request, userId, result);
                    break;
                case "/account/update":
                    handleUpdateAccount(request, userId, result);
                    break;
                case "/transaction/deposit":
                    handleDeposit(request, userId, result);
                    break;
                case "/transaction/withdraw":
                    handleWithdrawal(request, userId, result);
                    break;
                case "/transaction/transfer":
                    handleTransfer(request, userId, result);
                    break;
                default:
                    result.put("success", false);
                    result.put("error", "Unknown endpoint: " + pathInfo);
            }

            out.print(gson.toJson(result));

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            out.print(gson.toJson(error));
        }
    }

    // GET handlers
    private void handleGetCustomers(HttpServletRequest request, Map<String, Object> result) throws Exception {
        String type = request.getParameter("type");
        String search = request.getParameter("search");
        String status = request.getParameter("status");

        List<Customer> customers;
        if (search != null && !search.isEmpty()) {
            customers = customerDAO.searchCustomers(search, type, status);
        } else {
            customers = customerDAO.getAllCustomers(type);
        }

        result.put("success", true);
        result.put("data", customers);
        result.put("count", customers.size());
    }

    private void handleGetCustomer(HttpServletRequest request, Map<String, Object> result) throws Exception {
        String customerId = request.getParameter("id");
        if (customerId == null || customerId.isEmpty()) {
            result.put("success", false);
            result.put("error", "Customer ID is required");
            return;
        }

        Customer customer = customerDAO.getCustomerById(customerId);
        if (customer != null) {
            List<Account> accounts = accountDAO.getAccountsByCustomerId(customerId);
            result.put("success", true);
            result.put("data", customer);
            result.put("accounts", accounts);
        } else {
            result.put("success", false);
            result.put("error", "Customer not found");
        }
    }

    private void handleGetAccounts(HttpServletRequest request, Map<String, Object> result) throws Exception {
        String type = request.getParameter("type");
        String customerId = request.getParameter("customerId");
        String search = request.getParameter("search");

        List<Account> accounts;
        if (customerId != null && !customerId.isEmpty()) {
            accounts = accountDAO.getAccountsByCustomerId(customerId);
        } else if (search != null && !search.isEmpty()) {
            accounts = accountDAO.searchAccounts(search, type, null);
        } else {
            accounts = accountDAO.getAllAccounts(type);
        }

        result.put("success", true);
        result.put("data", accounts);
        result.put("count", accounts.size());
    }

    private void handleGetAccount(HttpServletRequest request, Map<String, Object> result) throws Exception {
        String accountId = request.getParameter("id");
        if (accountId == null || accountId.isEmpty()) {
            result.put("success", false);
            result.put("error", "Account ID is required");
            return;
        }

        Account account = accountDAO.getAccountById(accountId);
        if (account != null) {
            List<Transaction> transactions = transactionDAO.getTransactionsByAccountId(accountId, 20);
            result.put("success", true);
            result.put("data", account);
            result.put("transactions", transactions);
        } else {
            result.put("success", false);
            result.put("error", "Account not found");
        }
    }

    private void handleGetTransactions(HttpServletRequest request, Map<String, Object> result) throws Exception {
        String accountId = request.getParameter("accountId");
        String type = request.getParameter("type");
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        int limit = getIntParam(request, "limit", 100);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        java.sql.Date fromDate = fromDateStr != null ? new java.sql.Date(sdf.parse(fromDateStr).getTime()) : null;
        java.sql.Date toDate = toDateStr != null ? new java.sql.Date(sdf.parse(toDateStr).getTime()) : null;

        List<Transaction> transactions;
        if (accountId != null && !accountId.isEmpty()) {
            transactions = transactionDAO.searchTransactions(accountId, type, fromDate, toDate, limit);
        } else {
            transactions = transactionDAO.getRecentTransactions(limit);
        }

        result.put("success", true);
        result.put("data", transactions);
        result.put("count", transactions.size());
    }

    private void handleGetAuditLogs(HttpServletRequest request, Map<String, Object> result) throws Exception {
        String entityType = request.getParameter("entityType");
        String entityId = request.getParameter("entityId");
        String action = request.getParameter("action");
        String userId = request.getParameter("userId");
        int limit = getIntParam(request, "limit", 100);

        List<AuditLog> logs;
        if (entityId != null && !entityId.isEmpty()) {
            logs = auditDAO.getAuditLogsByEntity(entityType, entityId, limit);
        } else {
            logs = auditDAO.searchAuditLogs(entityType, entityId, action, userId, null, null, limit);
        }

        result.put("success", true);
        result.put("data", logs);
        result.put("count", logs.size());
    }

    private void handleGetDashboard(HttpServletRequest request, Map<String, Object> result) throws Exception {
        Map<String, Object> dashboard = new HashMap<>();

        // Customer counts
        dashboard.put("totalRetailCustomers", customerDAO.getCustomerCount("RETAIL"));
        dashboard.put("totalCorporateCustomers", customerDAO.getCustomerCount("CORPORATE"));

        // Account counts
        dashboard.put("totalSavingsAccounts", accountDAO.getAccountCount("SAVINGS"));
        dashboard.put("totalCurrentAccounts", accountDAO.getAccountCount("CURRENT"));
        dashboard.put("totalFDAccounts", accountDAO.getAccountCount("FD"));
        dashboard.put("totalRDAccounts", accountDAO.getAccountCount("RD"));

        // Recent transactions
        dashboard.put("recentTransactions", transactionDAO.getRecentTransactions(10));

        // Recent customers
        dashboard.put("recentCustomers", customerDAO.getAllCustomers(null).subList(0, 
            Math.min(5, customerDAO.getAllCustomers(null).size())));

        result.put("success", true);
        result.put("data", dashboard);
    }

    private void handleSearch(HttpServletRequest request, Map<String, Object> result) throws Exception {
        String query = request.getParameter("q");
        String type = request.getParameter("type"); // customer, account, transaction

        if (query == null || query.trim().isEmpty()) {
            result.put("success", false);
            result.put("error", "Search query is required");
            return;
        }

        Map<String, Object> searchResults = new HashMap<>();

        if (type == null || type.equals("customer") || type.equals("all")) {
            searchResults.put("customers", customerDAO.searchCustomers(query, null, null));
        }
        if (type == null || type.equals("account") || type.equals("all")) {
            searchResults.put("accounts", accountDAO.searchAccounts(query, null, null));
        }

        result.put("success", true);
        result.put("data", searchResults);
    }

    // POST handlers
    private void handleCreateCustomer(HttpServletRequest request, String userId, Map<String, Object> result) throws Exception {
        Customer customer = new Customer();
        customer.setCustomerType(request.getParameter("customerType"));
        customer.setFullName(request.getParameter("fullName"));
        customer.setGender(request.getParameter("gender"));
        customer.setEmail(request.getParameter("email"));
        customer.setMobile(request.getParameter("mobile"));
        customer.setAddressLine1(request.getParameter("addressLine1"));
        customer.setCity(request.getParameter("city"));
        customer.setState(request.getParameter("state"));
        customer.setPinCode(request.getParameter("pinCode"));
        customer.setIdType(request.getParameter("idType"));
        customer.setIdNumber(request.getParameter("idNumber"));
        customer.setPanNumber(request.getParameter("panNumber"));
        customer.setAadharNumber(request.getParameter("aadharNumber"));
        customer.setOccupation(request.getParameter("occupation"));

        String dobStr = request.getParameter("dateOfBirth");
        if (dobStr != null && !dobStr.isEmpty()) {
            customer.setDateOfBirth(new SimpleDateFormat("yyyy-MM-dd").parse(dobStr));
        }

        String incomeStr = request.getParameter("annualIncome");
        if (incomeStr != null && !incomeStr.isEmpty()) {
            customer.setAnnualIncome(new BigDecimal(incomeStr));
        }

        Customer created = customerDAO.createCustomer(customer, userId);

        // Log audit
        auditDAO.logAudit("CUSTOMER", created.getCustomerId(), "CREATE", 
            null, gson.toJson(created), null, userId, 
            request.getRemoteAddr(), request.getSession().getId(), "New customer created");

        result.put("success", true);
        result.put("data", created);
        result.put("message", "Customer created successfully with ID: " + created.getCustomerId());
    }

    private void handleUpdateCustomer(HttpServletRequest request, String userId, Map<String, Object> result) throws Exception {
        String customerId = request.getParameter("customerId");
        Customer existing = customerDAO.getCustomerById(customerId);
        if (existing == null) {
            result.put("success", false);
            result.put("error", "Customer not found");
            return;
        }

        String oldValue = gson.toJson(existing);

        // Update fields
        existing.setFullName(getParamOrDefault(request, "fullName", existing.getFullName()));
        existing.setEmail(getParamOrDefault(request, "email", existing.getEmail()));
        existing.setMobile(getParamOrDefault(request, "mobile", existing.getMobile()));
        existing.setAddressLine1(getParamOrDefault(request, "addressLine1", existing.getAddressLine1()));
        existing.setCity(getParamOrDefault(request, "city", existing.getCity()));
        existing.setState(getParamOrDefault(request, "state", existing.getState()));
        existing.setPinCode(getParamOrDefault(request, "pinCode", existing.getPinCode()));
        existing.setOccupation(getParamOrDefault(request, "occupation", existing.getOccupation()));
        existing.setKycStatus(getParamOrDefault(request, "kycStatus", existing.getKycStatus()));
        existing.setStatus(getParamOrDefault(request, "status", existing.getStatus()));

        boolean updated = customerDAO.updateCustomer(existing, userId);

        // Log audit
        auditDAO.logAudit("CUSTOMER", customerId, "UPDATE", 
            oldValue, gson.toJson(existing), null, userId, 
            request.getRemoteAddr(), request.getSession().getId(), "Customer updated");

        result.put("success", updated);
        result.put("data", existing);
        result.put("message", updated ? "Customer updated successfully" : "No changes made");
    }

    private void handleDeleteCustomer(HttpServletRequest request, String userId, Map<String, Object> result) throws Exception {
        String customerId = request.getParameter("customerId");
        
        boolean deleted = customerDAO.deleteCustomer(customerId, userId);

        // Log audit
        auditDAO.logAudit("CUSTOMER", customerId, "DELETE", 
            null, null, null, userId, 
            request.getRemoteAddr(), request.getSession().getId(), "Customer deleted/closed");

        result.put("success", deleted);
        result.put("message", deleted ? "Customer deleted successfully" : "Failed to delete customer");
    }

    private void handleCreateAccount(HttpServletRequest request, String userId, Map<String, Object> result) throws Exception {
        Account account = new Account();
        account.setCustomerId(request.getParameter("customerId"));
        account.setAccountType(request.getParameter("accountType"));
        account.setAccountName(request.getParameter("accountName"));
        account.setBranchCode(request.getParameter("branchCode"));
        account.setIfscCode(request.getParameter("ifscCode"));
        account.setNomineeName(request.getParameter("nomineeName"));
        account.setNomineeRelation(request.getParameter("nomineeRelation"));

        String balanceStr = request.getParameter("initialDeposit");
        BigDecimal balance = balanceStr != null && !balanceStr.isEmpty() ? new BigDecimal(balanceStr) : BigDecimal.ZERO;
        account.setBalance(balance);
        account.setAvailableBalance(balance);

        String rateStr = request.getParameter("interestRate");
        if (rateStr != null && !rateStr.isEmpty()) {
            account.setInterestRate(new BigDecimal(rateStr));
        }

        Account created = accountDAO.createAccount(account, userId);

        // Log audit
        auditDAO.logAudit("ACCOUNT", created.getAccountId(), "CREATE", 
            null, gson.toJson(created), null, userId, 
            request.getRemoteAddr(), request.getSession().getId(), "New account created");

        result.put("success", true);
        result.put("data", created);
        result.put("message", "Account created successfully with ID: " + created.getAccountId());
    }

    private void handleUpdateAccount(HttpServletRequest request, String userId, Map<String, Object> result) throws Exception {
        String accountId = request.getParameter("accountId");
        Account existing = accountDAO.getAccountById(accountId);
        if (existing == null) {
            result.put("success", false);
            result.put("error", "Account not found");
            return;
        }

        String oldValue = gson.toJson(existing);

        existing.setAccountName(getParamOrDefault(request, "accountName", existing.getAccountName()));
        existing.setNomineeName(getParamOrDefault(request, "nomineeName", existing.getNomineeName()));
        existing.setNomineeRelation(getParamOrDefault(request, "nomineeRelation", existing.getNomineeRelation()));
        existing.setStatus(getParamOrDefault(request, "status", existing.getStatus()));

        boolean updated = accountDAO.updateAccount(existing, userId);

        // Log audit
        auditDAO.logAudit("ACCOUNT", accountId, "UPDATE", 
            oldValue, gson.toJson(existing), null, userId, 
            request.getRemoteAddr(), request.getSession().getId(), "Account updated");

        result.put("success", updated);
        result.put("data", existing);
        result.put("message", updated ? "Account updated successfully" : "No changes made");
    }

    private void handleDeposit(HttpServletRequest request, String userId, Map<String, Object> result) throws Exception {
        String accountId = request.getParameter("accountId");
        BigDecimal amount = new BigDecimal(request.getParameter("amount"));
        String mode = request.getParameter("mode");
        String description = request.getParameter("description");
        String branchCode = request.getParameter("branchCode");

        Transaction txn = transactionDAO.performDeposit(accountId, amount, mode, description, branchCode, userId);

        // Log audit
        auditDAO.logAudit("TRANSACTION", txn.getTransactionId(), "DEPOSIT", 
            null, gson.toJson(txn), null, userId, 
            request.getRemoteAddr(), request.getSession().getId(), "Cash deposit");

        result.put("success", true);
        result.put("data", txn);
        result.put("message", "Deposit successful. Transaction ID: " + txn.getTransactionId());
    }

    private void handleWithdrawal(HttpServletRequest request, String userId, Map<String, Object> result) throws Exception {
        String accountId = request.getParameter("accountId");
        BigDecimal amount = new BigDecimal(request.getParameter("amount"));
        String mode = request.getParameter("mode");
        String description = request.getParameter("description");
        String branchCode = request.getParameter("branchCode");

        Transaction txn = transactionDAO.performWithdrawal(accountId, amount, mode, description, branchCode, userId);

        // Log audit
        auditDAO.logAudit("TRANSACTION", txn.getTransactionId(), "WITHDRAWAL", 
            null, gson.toJson(txn), null, userId, 
            request.getRemoteAddr(), request.getSession().getId(), "Cash withdrawal");

        result.put("success", true);
        result.put("data", txn);
        result.put("message", "Withdrawal successful. Transaction ID: " + txn.getTransactionId());
    }

    private void handleTransfer(HttpServletRequest request, String userId, Map<String, Object> result) throws Exception {
        String fromAccountId = request.getParameter("fromAccountId");
        String toAccountId = request.getParameter("toAccountId");
        BigDecimal amount = new BigDecimal(request.getParameter("amount"));
        String mode = request.getParameter("mode");
        String description = request.getParameter("description");
        String branchCode = request.getParameter("branchCode");

        // Perform withdrawal from source account
        Transaction debitTxn = transactionDAO.performWithdrawal(fromAccountId, amount, mode, 
            "Transfer to " + toAccountId + ": " + description, branchCode, userId);
        debitTxn.setToAccountId(toAccountId);

        // Perform deposit to destination account
        Transaction creditTxn = transactionDAO.performDeposit(toAccountId, amount, mode, 
            "Transfer from " + fromAccountId + ": " + description, branchCode, userId);

        // Log audit
        auditDAO.logAudit("TRANSACTION", debitTxn.getTransactionId(), "TRANSFER", 
            null, gson.toJson(debitTxn), null, userId, 
            request.getRemoteAddr(), request.getSession().getId(), "Fund transfer");

        result.put("success", true);
        result.put("debitTransaction", debitTxn);
        result.put("creditTransaction", creditTxn);
        result.put("message", "Transfer successful. Transaction ID: " + debitTxn.getTransactionId());
    }

    // Utility methods
    private int getIntParam(HttpServletRequest request, String name, int defaultValue) {
        String value = request.getParameter(name);
        if (value == null || value.isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String getParamOrDefault(HttpServletRequest request, String name, String defaultValue) {
        String value = request.getParameter(name);
        return (value != null && !value.isEmpty()) ? value : defaultValue;
    }
}
