package com.ucobank.finacle.dao;

import com.ucobank.finacle.config.DatabaseConfig;
import com.ucobank.finacle.model.Account;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Account DAO - Data Access Object for Account operations
 */
public class AccountDAO {

    /**
     * Get all accounts with optional type filter
     */
    public List<Account> getAllAccounts(String accountType) throws SQLException {
        List<Account> accounts = new ArrayList<>();
        String sql = "SELECT a.*, c.FULL_NAME as CUSTOMER_NAME FROM FIN_ACCOUNTS a " +
                "LEFT JOIN FIN_CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID " +
                "WHERE a.STATUS = 'ACTIVE'";
        
        if (accountType != null && !accountType.isEmpty()) {
            sql += " AND a.ACCOUNT_TYPE = ?";
        }
        sql += " ORDER BY a.CREATED_DATE DESC";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            if (accountType != null && !accountType.isEmpty()) {
                stmt.setString(1, accountType);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    accounts.add(mapResultSetToAccount(rs));
                }
            }
        }
        return accounts;
    }

    /**
     * Get account by ID
     */
    public Account getAccountById(String accountId) throws SQLException {
        String sql = "SELECT a.*, c.FULL_NAME as CUSTOMER_NAME FROM FIN_ACCOUNTS a " +
                "LEFT JOIN FIN_CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID " +
                "WHERE a.ACCOUNT_ID = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, accountId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAccount(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get accounts by customer ID
     */
    public List<Account> getAccountsByCustomerId(String customerId) throws SQLException {
        List<Account> accounts = new ArrayList<>();
        String sql = "SELECT a.*, c.FULL_NAME as CUSTOMER_NAME FROM FIN_ACCOUNTS a " +
                "LEFT JOIN FIN_CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID " +
                "WHERE a.CUSTOMER_ID = ? AND a.STATUS = 'ACTIVE' ORDER BY a.ACCOUNT_TYPE";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, customerId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    accounts.add(mapResultSetToAccount(rs));
                }
            }
        }
        return accounts;
    }

    /**
     * Search accounts
     */
    public List<Account> searchAccounts(String searchTerm, String accountType, String status) throws SQLException {
        List<Account> accounts = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.*, c.FULL_NAME as CUSTOMER_NAME FROM FIN_ACCOUNTS a " +
            "LEFT JOIN FIN_CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (accountType != null && !accountType.isEmpty()) {
            sql.append(" AND a.ACCOUNT_TYPE = ?");
            params.add(accountType);
        }

        if (status != null && !status.isEmpty()) {
            sql.append(" AND a.STATUS = ?");
            params.add(status);
        }

        if (searchTerm != null && !searchTerm.isEmpty()) {
            sql.append(" AND (a.ACCOUNT_ID LIKE ? OR a.CUSTOMER_ID LIKE ? OR UPPER(c.FULL_NAME) LIKE ?)");
            String term = "%" + searchTerm.toUpperCase() + "%";
            params.add("%" + searchTerm + "%");
            params.add("%" + searchTerm + "%");
            params.add(term);
        }

        sql.append(" ORDER BY a.CREATED_DATE DESC");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    accounts.add(mapResultSetToAccount(rs));
                }
            }
        }
        return accounts;
    }

    /**
     * Create new account
     */
    public Account createAccount(Account account, String createdBy) throws SQLException {
        String sql = "INSERT INTO FIN_ACCOUNTS (ACCOUNT_ID, CUSTOMER_ID, ACCOUNT_TYPE, ACCOUNT_NAME, " +
                "CURRENCY, BALANCE, AVAILABLE_BALANCE, INTEREST_RATE, OPENING_DATE, MATURITY_DATE, " +
                "BRANCH_CODE, IFSC_CODE, STATUS, NOMINEE_NAME, NOMINEE_RELATION, CREATED_BY, CREATED_DATE) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = DatabaseConfig.getConnection()) {
            String accountId = generateAccountId(conn);
            account.setAccountId(accountId);

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, accountId);
                stmt.setString(2, account.getCustomerId());
                stmt.setString(3, account.getAccountType());
                stmt.setString(4, account.getAccountName());
                stmt.setString(5, account.getCurrency() != null ? account.getCurrency() : "INR");
                stmt.setBigDecimal(6, account.getBalance());
                stmt.setBigDecimal(7, account.getAvailableBalance());
                stmt.setBigDecimal(8, account.getInterestRate());
                stmt.setDate(9, account.getMaturityDate() != null ? new java.sql.Date(account.getMaturityDate().getTime()) : null);
                stmt.setString(10, account.getBranchCode());
                stmt.setString(11, account.getIfscCode());
                stmt.setString(12, "ACTIVE");
                stmt.setString(13, account.getNomineeName());
                stmt.setString(14, account.getNomineeRelation());
                stmt.setString(15, createdBy);

                stmt.executeUpdate();
            }
            return account;
        }
    }

    /**
     * Update account
     */
    public boolean updateAccount(Account account, String updatedBy) throws SQLException {
        String sql = "UPDATE FIN_ACCOUNTS SET ACCOUNT_NAME = ?, INTEREST_RATE = ?, " +
                "BRANCH_CODE = ?, IFSC_CODE = ?, STATUS = ?, NOMINEE_NAME = ?, NOMINEE_RELATION = ?, " +
                "UPDATED_BY = ?, UPDATED_DATE = CURRENT_TIMESTAMP WHERE ACCOUNT_ID = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, account.getAccountName());
            stmt.setBigDecimal(2, account.getInterestRate());
            stmt.setString(3, account.getBranchCode());
            stmt.setString(4, account.getIfscCode());
            stmt.setString(5, account.getStatus());
            stmt.setString(6, account.getNomineeName());
            stmt.setString(7, account.getNomineeRelation());
            stmt.setString(8, updatedBy);
            stmt.setString(9, account.getAccountId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Update account balance
     */
    public boolean updateBalance(String accountId, java.math.BigDecimal newBalance, java.math.BigDecimal availableBalance) throws SQLException {
        String sql = "UPDATE FIN_ACCOUNTS SET BALANCE = ?, AVAILABLE_BALANCE = ?, UPDATED_DATE = CURRENT_TIMESTAMP WHERE ACCOUNT_ID = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setBigDecimal(1, newBalance);
            stmt.setBigDecimal(2, availableBalance);
            stmt.setString(3, accountId);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Get account count by type
     */
    public int getAccountCount(String accountType) throws SQLException {
        String sql = "SELECT COUNT(*) FROM FIN_ACCOUNTS WHERE STATUS = 'ACTIVE'";
        if (accountType != null) {
            sql += " AND ACCOUNT_TYPE = ?";
        }

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            if (accountType != null) {
                stmt.setString(1, accountType);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Generate new account ID
     */
    private String generateAccountId(Connection conn) throws SQLException {
        String sql = "SELECT FIN_ACCOUNT_SEQ.NEXTVAL FROM DUAL";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getString(1);
            }
        }
        throw new SQLException("Failed to generate account ID");
    }

    /**
     * Map ResultSet to Account object
     */
    private Account mapResultSetToAccount(ResultSet rs) throws SQLException {
        Account account = new Account();
        account.setAccountId(rs.getString("ACCOUNT_ID"));
        account.setCustomerId(rs.getString("CUSTOMER_ID"));
        account.setAccountType(rs.getString("ACCOUNT_TYPE"));
        account.setAccountName(rs.getString("ACCOUNT_NAME"));
        account.setCurrency(rs.getString("CURRENCY"));
        account.setBalance(rs.getBigDecimal("BALANCE"));
        account.setAvailableBalance(rs.getBigDecimal("AVAILABLE_BALANCE"));
        account.setInterestRate(rs.getBigDecimal("INTEREST_RATE"));
        account.setOpeningDate(rs.getDate("OPENING_DATE"));
        account.setMaturityDate(rs.getDate("MATURITY_DATE"));
        account.setBranchCode(rs.getString("BRANCH_CODE"));
        account.setIfscCode(rs.getString("IFSC_CODE"));
        account.setStatus(rs.getString("STATUS"));
        account.setNomineeName(rs.getString("NOMINEE_NAME"));
        account.setNomineeRelation(rs.getString("NOMINEE_RELATION"));
        account.setCreatedBy(rs.getString("CREATED_BY"));
        account.setCreatedDate(rs.getTimestamp("CREATED_DATE"));
        account.setUpdatedBy(rs.getString("UPDATED_BY"));
        account.setUpdatedDate(rs.getTimestamp("UPDATED_DATE"));
        
        try {
            account.setCustomerName(rs.getString("CUSTOMER_NAME"));
        } catch (SQLException e) {
            // Column may not exist in all queries
        }
        
        return account;
    }
}
