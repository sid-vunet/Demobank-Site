package com.ucobank.finacle.service;

import java.util.HashMap;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;

/**
 * Function Service - Handles function data and titles
 * Provides data for each function in the content area
 */
public class FunctionService {

    private static final Map<String, String> functionTitles = new HashMap<>();
    
    static {
        // CIF Retail
        functionTitles.put("welcome", "Welcome");
        functionTitles.put("CIF_RETAIL_AUDIT", "CIF Retail - Audit Trail");
        functionTitles.put("CIF_RETAIL_EDIT", "CIF Retail - Edit Entity");
        functionTitles.put("CIF_RETAIL_QUEUE", "CIF Retail - Entity Queue");
        functionTitles.put("CIF_RETAIL_NEW", "CIF Retail - New Entity");
        functionTitles.put("CIF_RETAIL_OPS", "CIF Retail - Operations");
        functionTitles.put("CIF_RETAIL_RM", "CIF Retail - Relationship Manager Maintenance");
        
        // CIF Corporate
        functionTitles.put("CIF_CORP_AUDIT", "CIF Corporate - Audit Trail");
        functionTitles.put("CIF_CORP_EDIT", "CIF Corporate - Edit Entity");
        functionTitles.put("CIF_CORP_QUEUE", "CIF Corporate - Entity Queue");
        functionTitles.put("CIF_CORP_GROUP", "CIF Corporate - Group Mapping");
        functionTitles.put("CIF_CORP_NEW", "CIF Corporate - New Entity");
        functionTitles.put("CIF_CORP_OPS", "CIF Corporate - Operations");
        functionTitles.put("CIF_CORP_RM", "CIF Corporate - Relationship Manager Maintenance");
        
        // Accounts
        functionTitles.put("ACC_SAVINGS", "Savings Account");
        functionTitles.put("ACC_CURRENT", "Current Account");
        functionTitles.put("ACC_FD", "Fixed Deposit");
        functionTitles.put("ACC_RD", "Recurring Deposit");
        
        // Transactions
        functionTitles.put("TXN_DEPOSIT", "Cash Deposit");
        functionTitles.put("TXN_WITHDRAW", "Cash Withdrawal");
        functionTitles.put("TXN_TRANSFER", "Fund Transfer");
        functionTitles.put("TXN_BILL", "Bill Payment");
        
        // Reports
        functionTitles.put("RPT_DAILY", "Daily Reports");
        functionTitles.put("RPT_STATEMENT", "Account Statement");
        functionTitles.put("RPT_HISTORY", "Transaction History");
        functionTitles.put("RPT_MIS", "MIS Reports");
        
        // Administration
        functionTitles.put("ADMIN_USER", "User Management");
        functionTitles.put("ADMIN_ROLE", "Role Management");
        functionTitles.put("ADMIN_AUDIT", "Audit Logs");
    }

    /**
     * Get function title by ID
     */
    public String getFunctionTitle(String functionId) {
        return functionTitles.getOrDefault(functionId, "Function: " + functionId);
    }

    /**
     * Get function data based on function ID and action
     * Returns data object that can be used in JSP
     */
    public Object getFunctionData(String functionId, String action, HttpServletRequest request) {
        Map<String, Object> data = new HashMap<>();
        
        data.put("functionId", functionId);
        data.put("title", getFunctionTitle(functionId));
        
        // Handle specific function data
        switch (functionId) {
            case "CIF_RETAIL_AUDIT":
            case "CIF_CORP_AUDIT":
                data.put("type", "audit");
                data.put("searchFields", new String[]{"customerId", "accountNo", "fromDate", "toDate", "txnType"});
                break;
                
            case "CIF_RETAIL_EDIT":
            case "CIF_CORP_EDIT":
                data.put("type", "edit");
                data.put("searchFields", new String[]{"customerId"});
                if ("search".equals(action)) {
                    String custId = request.getParameter("customerId");
                    data.put("customerData", getCustomerData(custId));
                }
                break;
                
            case "CIF_RETAIL_NEW":
            case "CIF_CORP_NEW":
                data.put("type", "create");
                data.put("formFields", new String[]{"fullName", "dob", "email", "phone", "address", "idType", "idNumber"});
                break;
                
            case "CIF_RETAIL_QUEUE":
            case "CIF_CORP_QUEUE":
                data.put("type", "queue");
                data.put("queueItems", getQueueItems());
                break;
                
            case "TXN_DEPOSIT":
            case "TXN_WITHDRAW":
            case "TXN_TRANSFER":
                data.put("type", "transaction");
                break;
                
            case "RPT_STATEMENT":
            case "RPT_HISTORY":
                data.put("type", "report");
                data.put("searchFields", new String[]{"accountNo", "fromDate", "toDate"});
                break;
                
            default:
                data.put("type", "generic");
                break;
        }
        
        return data;
    }
    
    private Map<String, String> getCustomerData(String customerId) {
        // Simulated customer data
        Map<String, String> customer = new HashMap<>();
        if (customerId != null && !customerId.isEmpty()) {
            customer.put("customerId", customerId);
            customer.put("fullName", "John Doe");
            customer.put("dob", "1985-06-15");
            customer.put("email", "john.doe@example.com");
            customer.put("phone", "+91 9876543210");
            customer.put("address", "123 Main Street, Mumbai, Maharashtra 400001");
            customer.put("idType", "PAN");
            customer.put("idNumber", "ABCDE1234F");
        }
        return customer;
    }
    
    private Object[] getQueueItems() {
        // Simulated queue items
        return new Object[]{
            new String[]{"Q001", "New Customer - John Smith", "Pending Approval", "2025-12-10"},
            new String[]{"Q002", "Update Address - Jane Doe", "Under Review", "2025-12-09"},
            new String[]{"Q003", "Account Closure - Bob Wilson", "Pending Documents", "2025-12-08"}
        };
    }
}
