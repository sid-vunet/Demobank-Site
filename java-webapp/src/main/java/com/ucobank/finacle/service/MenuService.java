package com.ucobank.finacle.service;

import java.util.ArrayList;
import java.util.List;

import com.ucobank.finacle.model.MenuItem;

/**
 * Menu Service - Provides menu structure for the application
 * Returns menu items based on user role
 */
public class MenuService {

    /**
     * Get menu items for user based on role
     * @param userRole User's role
     * @return List of menu items
     */
    public List<MenuItem> getMenuItems(String userRole) {
        List<MenuItem> menuItems = new ArrayList<>();
        
        // CIF Retail Section
        MenuItem cifRetail = new MenuItem("cifRetail", "CIF Retail", true);
        cifRetail.setIcon("folder");
        cifRetail.setExpanded(true);
        
        cifRetail.addChild(new MenuItem("auditTrail", "Audit Trail", "CIF_RETAIL_AUDIT"));
        cifRetail.addChild(new MenuItem("editEntity", "Edit Entity", "CIF_RETAIL_EDIT"));
        cifRetail.addChild(new MenuItem("entityQueue", "Entity Queue", "CIF_RETAIL_QUEUE"));
        cifRetail.addChild(new MenuItem("newEntity", "New Entity", "CIF_RETAIL_NEW"));
        cifRetail.addChild(new MenuItem("operations", "Operations", "CIF_RETAIL_OPS"));
        cifRetail.addChild(new MenuItem("relationshipManager", "Relationship Manager Maintenance", "CIF_RETAIL_RM"));
        
        menuItems.add(cifRetail);
        
        // CIF Corporate Section
        MenuItem cifCorporate = new MenuItem("cifCorporate", "CIF Corporate", true);
        cifCorporate.setIcon("folder");
        cifCorporate.setExpanded(false);
        
        cifCorporate.addChild(new MenuItem("corpAuditTrail", "Audit Trail", "CIF_CORP_AUDIT"));
        cifCorporate.addChild(new MenuItem("corpEditEntity", "Edit Entity", "CIF_CORP_EDIT"));
        cifCorporate.addChild(new MenuItem("corpEntityQueue", "Entity Queue", "CIF_CORP_QUEUE"));
        cifCorporate.addChild(new MenuItem("corpGroupMapping", "Group Mapping", "CIF_CORP_GROUP"));
        cifCorporate.addChild(new MenuItem("corpNewEntity", "New Entity", "CIF_CORP_NEW"));
        cifCorporate.addChild(new MenuItem("corpOperations", "Operations", "CIF_CORP_OPS"));
        cifCorporate.addChild(new MenuItem("corpRelationshipManager", "Relationship Manager Maintenance", "CIF_CORP_RM"));
        
        menuItems.add(cifCorporate);
        
        // Add role-specific menus
        if ("ADMIN".equals(userRole)) {
            MenuItem admin = new MenuItem("administration", "Administration", true);
            admin.setIcon("folder");
            admin.addChild(new MenuItem("userMgmt", "User Management", "ADMIN_USER"));
            admin.addChild(new MenuItem("roleMgmt", "Role Management", "ADMIN_ROLE"));
            admin.addChild(new MenuItem("auditLogs", "Audit Logs", "ADMIN_AUDIT"));
            menuItems.add(admin);
        }
        
        // Accounts Section
        MenuItem accounts = new MenuItem("accounts", "Accounts", true);
        accounts.setIcon("folder");
        accounts.setExpanded(false);
        
        accounts.addChild(new MenuItem("savingsAccount", "Savings Account", "ACC_SAVINGS"));
        accounts.addChild(new MenuItem("currentAccount", "Current Account", "ACC_CURRENT"));
        accounts.addChild(new MenuItem("fixedDeposit", "Fixed Deposit", "ACC_FD"));
        accounts.addChild(new MenuItem("recurringDeposit", "Recurring Deposit", "ACC_RD"));
        
        menuItems.add(accounts);
        
        // Transactions Section
        MenuItem transactions = new MenuItem("transactions", "Transactions", true);
        transactions.setIcon("folder");
        transactions.setExpanded(false);
        
        transactions.addChild(new MenuItem("cashDeposit", "Cash Deposit", "TXN_DEPOSIT"));
        transactions.addChild(new MenuItem("cashWithdrawal", "Cash Withdrawal", "TXN_WITHDRAW"));
        transactions.addChild(new MenuItem("fundTransfer", "Fund Transfer", "TXN_TRANSFER"));
        transactions.addChild(new MenuItem("billPayment", "Bill Payment", "TXN_BILL"));
        
        menuItems.add(transactions);
        
        // Reports Section
        MenuItem reports = new MenuItem("reports", "Reports", true);
        reports.setIcon("folder");
        reports.setExpanded(false);
        
        reports.addChild(new MenuItem("dailyReport", "Daily Reports", "RPT_DAILY"));
        reports.addChild(new MenuItem("accountStatement", "Account Statement", "RPT_STATEMENT"));
        reports.addChild(new MenuItem("transactionHistory", "Transaction History", "RPT_HISTORY"));
        reports.addChild(new MenuItem("misReports", "MIS Reports", "RPT_MIS"));
        
        menuItems.add(reports);
        
        return menuItems;
    }
}
