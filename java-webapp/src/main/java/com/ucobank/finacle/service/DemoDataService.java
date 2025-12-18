package com.ucobank.finacle.service;

import com.ucobank.finacle.model.*;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.*;

/**
 * Demo Data Service - Provides mock data when database is offline
 * This allows the application to function without an actual database connection
 */
public class DemoDataService {

    private static final Map<String, Customer> customers = new LinkedHashMap<>();
    private static final Map<String, Account> accounts = new LinkedHashMap<>();
    private static final List<Transaction> transactions = new ArrayList<>();
    private static final List<AuditLog> auditLogs = new ArrayList<>();

    static {
        initializeDemoData();
    }

    private static void initializeDemoData() {
        // Create demo customers
        customers.put("CUS001", createCustomer("CUS001", "RETAIL", "Rajesh Kumar", "MALE", "rajesh.kumar@email.com", "9876543210", "Mumbai", "Maharashtra", "VERIFIED", "ACTIVE"));
        customers.put("CUS002", createCustomer("CUS002", "RETAIL", "Priya Sharma", "FEMALE", "priya.sharma@email.com", "9876543211", "Delhi", "Delhi", "VERIFIED", "ACTIVE"));
        customers.put("CUS003", createCustomer("CUS003", "CORPORATE", "ABC Industries Pvt Ltd", null, "contact@abcindustries.com", "9876543212", "Bangalore", "Karnataka", "VERIFIED", "ACTIVE"));
        customers.put("CUS004", createCustomer("CUS004", "RETAIL", "Amit Patel", "MALE", "amit.patel@email.com", "9876543213", "Ahmedabad", "Gujarat", "PENDING", "ACTIVE"));
        customers.put("CUS005", createCustomer("CUS005", "RETAIL", "Sunita Devi", "FEMALE", "sunita.devi@email.com", "9876543214", "Kolkata", "West Bengal", "VERIFIED", "ACTIVE"));
        customers.put("CUS006", createCustomer("CUS006", "CORPORATE", "XYZ Exports Ltd", null, "info@xyzexports.com", "9876543215", "Chennai", "Tamil Nadu", "VERIFIED", "ACTIVE"));
        customers.put("CUS007", createCustomer("CUS007", "RETAIL", "Mohammed Ali", "MALE", "m.ali@email.com", "9876543216", "Hyderabad", "Telangana", "REJECTED", "INACTIVE"));

        // Create demo accounts
        accounts.put("ACC001", createAccount("ACC001", "CUS001", "SAVINGS", "Rajesh Kumar - Savings", new BigDecimal("125000.50"), new BigDecimal("3.5")));
        accounts.put("ACC002", createAccount("ACC002", "CUS001", "CURRENT", "Rajesh Kumar - Current", new BigDecimal("450000.00"), new BigDecimal("0.0")));
        accounts.put("ACC003", createAccount("ACC003", "CUS002", "SAVINGS", "Priya Sharma - Savings", new BigDecimal("78500.75"), new BigDecimal("3.5")));
        accounts.put("ACC004", createAccount("ACC004", "CUS003", "CURRENT", "ABC Industries - Current", new BigDecimal("2500000.00"), new BigDecimal("0.0")));
        accounts.put("ACC005", createAccount("ACC005", "CUS004", "SAVINGS", "Amit Patel - Savings", new BigDecimal("15000.00"), new BigDecimal("3.5")));
        accounts.put("ACC006", createAccount("ACC006", "CUS005", "FD", "Sunita Devi - Fixed Deposit", new BigDecimal("500000.00"), new BigDecimal("6.5")));
        accounts.put("ACC007", createAccount("ACC007", "CUS006", "CURRENT", "XYZ Exports - Current", new BigDecimal("1850000.00"), new BigDecimal("0.0")));

        // Create demo transactions
        transactions.add(createTransaction("TXN001", "ACC001", "CREDIT", new BigDecimal("50000.00"), "Salary Credit - Dec 2025"));
        transactions.add(createTransaction("TXN002", "ACC001", "DEBIT", new BigDecimal("5000.00"), "ATM Withdrawal"));
        transactions.add(createTransaction("TXN003", "ACC002", "CREDIT", new BigDecimal("100000.00"), "Business Payment Received"));
        transactions.add(createTransaction("TXN004", "ACC003", "DEBIT", new BigDecimal("15000.00"), "Online Shopping"));
        transactions.add(createTransaction("TXN005", "ACC004", "CREDIT", new BigDecimal("500000.00"), "Invoice Payment - Client XYZ"));
        transactions.add(createTransaction("TXN006", "ACC001", "DEBIT", new BigDecimal("2500.00"), "Utility Bill Payment"));
        transactions.add(createTransaction("TXN007", "ACC005", "CREDIT", new BigDecimal("10000.00"), "Cash Deposit"));
        transactions.add(createTransaction("TXN008", "ACC002", "DEBIT", new BigDecimal("25000.00"), "Vendor Payment"));

        // Create demo audit logs
        auditLogs.add(createAuditLog(1L, "CUSTOMER", "CUS001", "CREATE", "admin", "Created new customer"));
        auditLogs.add(createAuditLog(2L, "ACCOUNT", "ACC001", "CREATE", "admin", "Opened savings account"));
        auditLogs.add(createAuditLog(3L, "CUSTOMER", "CUS001", "UPDATE", "maker", "Updated contact details"));
        auditLogs.add(createAuditLog(4L, "TRANSACTION", "TXN001", "CREATE", "teller1", "Salary credit processed"));
        auditLogs.add(createAuditLog(5L, "CUSTOMER", "CUS002", "CREATE", "admin", "Created new customer"));
        auditLogs.add(createAuditLog(6L, "ACCOUNT", "ACC003", "CREATE", "admin", "Opened savings account"));
    }

    private static Customer createCustomer(String id, String type, String name, String gender, String email, String mobile, String city, String state, String kycStatus, String status) {
        Customer c = new Customer();
        c.setCustomerId(id);
        c.setCustomerType(type);
        c.setFullName(name);
        c.setGender(gender);
        c.setEmail(email);
        c.setMobile(mobile);
        c.setCity(city);
        c.setState(state);
        c.setKycStatus(kycStatus);
        c.setStatus(status);
        c.setCreatedDate(new Timestamp(System.currentTimeMillis() - 86400000L * 30)); // 30 days ago
        return c;
    }

    private static Account createAccount(String id, String customerId, String type, String name, BigDecimal balance, BigDecimal interestRate) {
        Account a = new Account();
        a.setAccountId(id);
        a.setCustomerId(customerId);
        a.setAccountType(type);
        a.setAccountName(name);
        a.setBalance(balance);
        a.setAvailableBalance(balance);
        a.setInterestRate(interestRate);
        a.setCurrency("INR");
        a.setStatus("ACTIVE");
        a.setBranchCode("BR001");
        a.setIfscCode("UCBA0001234");
        a.setOpeningDate(new Date(System.currentTimeMillis() - 86400000L * 365)); // 1 year ago
        a.setCustomerName(customers.get(customerId) != null ? customers.get(customerId).getFullName() : "");
        return a;
    }

    private static Transaction createTransaction(String id, String accountId, String type, BigDecimal amount, String description) {
        Transaction t = new Transaction();
        t.setTransactionId(id);
        t.setAccountId(accountId);
        t.setTransactionType(type);
        t.setTransactionMode("NEFT");
        t.setAmount(amount);
        t.setDescription(description);
        t.setReferenceNo("REF" + System.currentTimeMillis() % 1000000);
        t.setStatus("SUCCESS");
        t.setBranchCode("BR001");
        t.setTransactionDate(new Timestamp(System.currentTimeMillis() - (long)(Math.random() * 86400000L * 30)));
        return t;
    }

    private static AuditLog createAuditLog(Long id, String entityType, String entityId, String action, String user, String details) {
        AuditLog a = new AuditLog();
        a.setAuditId(id);
        a.setEntityType(entityType);
        a.setEntityId(entityId);
        a.setAction(action);
        a.setUserId(user);
        a.setRemarks(details);
        a.setActionDate(new Timestamp(System.currentTimeMillis() - (long)(Math.random() * 86400000L * 7)));
        return a;
    }

    // ==================== PUBLIC API ====================

    public static List<Customer> getAllCustomers() {
        return new ArrayList<>(customers.values());
    }

    public static Customer getCustomerById(String customerId) {
        return customers.get(customerId);
    }

    public static List<Customer> searchCustomers(String searchTerm) {
        if (searchTerm == null || searchTerm.isEmpty()) {
            return getAllCustomers();
        }
        String term = searchTerm.toLowerCase();
        List<Customer> results = new ArrayList<>();
        for (Customer c : customers.values()) {
            if (c.getCustomerId().toLowerCase().contains(term) ||
                c.getFullName().toLowerCase().contains(term) ||
                (c.getMobile() != null && c.getMobile().contains(term)) ||
                (c.getCity() != null && c.getCity().toLowerCase().contains(term))) {
                results.add(c);
            }
        }
        return results;
    }

    public static int getRetailCustomerCount() {
        return (int) customers.values().stream().filter(c -> "RETAIL".equals(c.getCustomerType())).count();
    }

    public static int getCorporateCustomerCount() {
        return (int) customers.values().stream().filter(c -> "CORPORATE".equals(c.getCustomerType())).count();
    }

    public static List<Account> getAllAccounts() {
        return new ArrayList<>(accounts.values());
    }

    public static Account getAccountById(String accountId) {
        return accounts.get(accountId);
    }

    public static List<Account> getAccountsByCustomerId(String customerId) {
        List<Account> results = new ArrayList<>();
        for (Account a : accounts.values()) {
            if (customerId.equals(a.getCustomerId())) {
                results.add(a);
            }
        }
        return results;
    }

    public static List<Account> getAccountsByType(String accountType) {
        if (accountType == null || accountType.isEmpty()) {
            return getAllAccounts();
        }
        List<Account> results = new ArrayList<>();
        for (Account a : accounts.values()) {
            if (accountType.equals(a.getAccountType())) {
                results.add(a);
            }
        }
        return results;
    }

    public static int getSavingsAccountCount() {
        return (int) accounts.values().stream().filter(a -> "SAVINGS".equals(a.getAccountType())).count();
    }

    public static int getCurrentAccountCount() {
        return (int) accounts.values().stream().filter(a -> "CURRENT".equals(a.getAccountType())).count();
    }

    public static List<Transaction> getAllTransactions() {
        List<Transaction> sorted = new ArrayList<>(transactions);
        sorted.sort((a, b) -> b.getTransactionDate().compareTo(a.getTransactionDate()));
        return sorted;
    }

    public static List<Transaction> getTransactionsByAccountId(String accountId) {
        List<Transaction> results = new ArrayList<>();
        for (Transaction t : transactions) {
            if (accountId.equals(t.getAccountId())) {
                results.add(t);
            }
        }
        results.sort((a, b) -> b.getTransactionDate().compareTo(a.getTransactionDate()));
        return results;
    }

    public static List<AuditLog> getAllAuditLogs() {
        List<AuditLog> sorted = new ArrayList<>(auditLogs);
        sorted.sort((a, b) -> b.getActionDate().compareTo(a.getActionDate()));
        return sorted;
    }

    public static List<AuditLog> searchAuditLogs(String entityType, String action) {
        List<AuditLog> results = new ArrayList<>();
        for (AuditLog a : auditLogs) {
            boolean match = true;
            if (entityType != null && !entityType.isEmpty() && !entityType.equals(a.getEntityType())) {
                match = false;
            }
            if (action != null && !action.isEmpty() && !action.equals(a.getAction())) {
                match = false;
            }
            if (match) {
                results.add(a);
            }
        }
        results.sort((a, b) -> b.getActionDate().compareTo(a.getActionDate()));
        return results;
    }

    // ==================== MUTATORS (Demo Mode) ====================

    public static Customer createCustomer(Customer customer) {
        String newId = "CUS" + String.format("%03d", customers.size() + 1);
        customer.setCustomerId(newId);
        customer.setCreatedDate(new Timestamp(System.currentTimeMillis()));
        customers.put(newId, customer);
        
        // Add audit log
        auditLogs.add(createAuditLog((long) auditLogs.size() + 1, "CUSTOMER", newId, "CREATE", "demo_user", "Created customer: " + customer.getFullName()));
        
        return customer;
    }

    public static void updateCustomer(Customer customer) {
        if (customers.containsKey(customer.getCustomerId())) {
            customers.put(customer.getCustomerId(), customer);
            auditLogs.add(createAuditLog((long) auditLogs.size() + 1, "CUSTOMER", customer.getCustomerId(), "UPDATE", "demo_user", "Updated customer details"));
        }
    }

    public static Transaction performDeposit(String accountId, BigDecimal amount, String description) {
        Account account = accounts.get(accountId);
        if (account != null) {
            account.setBalance(account.getBalance().add(amount));
            account.setAvailableBalance(account.getAvailableBalance().add(amount));
            
            Transaction txn = new Transaction();
            txn.setTransactionId("TXN" + String.format("%03d", transactions.size() + 1));
            txn.setAccountId(accountId);
            txn.setTransactionType("CREDIT");
            txn.setTransactionMode("CASH");
            txn.setAmount(amount);
            txn.setBalanceAfter(account.getBalance());
            txn.setDescription(description != null ? description : "Cash Deposit");
            txn.setReferenceNo("REF" + System.currentTimeMillis() % 1000000);
            txn.setStatus("SUCCESS");
            txn.setTransactionDate(new Timestamp(System.currentTimeMillis()));
            transactions.add(txn);
            
            return txn;
        }
        return null;
    }

    public static Transaction performWithdrawal(String accountId, BigDecimal amount, String description) {
        Account account = accounts.get(accountId);
        if (account != null && account.getBalance().compareTo(amount) >= 0) {
            account.setBalance(account.getBalance().subtract(amount));
            account.setAvailableBalance(account.getAvailableBalance().subtract(amount));
            
            Transaction txn = new Transaction();
            txn.setTransactionId("TXN" + String.format("%03d", transactions.size() + 1));
            txn.setAccountId(accountId);
            txn.setTransactionType("DEBIT");
            txn.setTransactionMode("CASH");
            txn.setAmount(amount);
            txn.setBalanceAfter(account.getBalance());
            txn.setDescription(description != null ? description : "Cash Withdrawal");
            txn.setReferenceNo("REF" + System.currentTimeMillis() % 1000000);
            txn.setStatus("SUCCESS");
            txn.setTransactionDate(new Timestamp(System.currentTimeMillis()));
            transactions.add(txn);
            
            return txn;
        }
        return null;
    }
}
