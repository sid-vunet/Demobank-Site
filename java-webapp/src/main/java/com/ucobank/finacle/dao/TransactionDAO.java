package com.ucobank.finacle.dao;

import com.ucobank.finacle.config.DatabaseConfig;
import com.ucobank.finacle.model.Transaction;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Transaction DAO - Data Access Object for Transaction operations
 */
public class TransactionDAO {

    /**
     * Get transactions by account ID
     */
    public List<Transaction> getTransactionsByAccountId(String accountId, int limit) throws SQLException {
        List<Transaction> transactions = new ArrayList<>();
        String sql = "SELECT * FROM (SELECT t.*, a.ACCOUNT_NAME, c.FULL_NAME as CUSTOMER_NAME " +
                "FROM FIN_TRANSACTIONS t " +
                "LEFT JOIN FIN_ACCOUNTS a ON t.ACCOUNT_ID = a.ACCOUNT_ID " +
                "LEFT JOIN FIN_CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID " +
                "WHERE t.ACCOUNT_ID = ? ORDER BY t.TRANSACTION_DATE DESC) WHERE ROWNUM <= ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, accountId);
            stmt.setInt(2, limit > 0 ? limit : 100);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapResultSetToTransaction(rs));
                }
            }
        }
        return transactions;
    }

    /**
     * Get transaction by ID
     */
    public Transaction getTransactionById(String transactionId) throws SQLException {
        String sql = "SELECT t.*, a.ACCOUNT_NAME, c.FULL_NAME as CUSTOMER_NAME " +
                "FROM FIN_TRANSACTIONS t " +
                "LEFT JOIN FIN_ACCOUNTS a ON t.ACCOUNT_ID = a.ACCOUNT_ID " +
                "LEFT JOIN FIN_CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID " +
                "WHERE t.TRANSACTION_ID = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, transactionId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTransaction(rs);
                }
            }
        }
        return null;
    }

    /**
     * Search transactions
     */
    public List<Transaction> searchTransactions(String accountId, String transactionType, 
            Date fromDate, Date toDate, int limit) throws SQLException {
        List<Transaction> transactions = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT * FROM (SELECT t.*, a.ACCOUNT_NAME, c.FULL_NAME as CUSTOMER_NAME " +
            "FROM FIN_TRANSACTIONS t " +
            "LEFT JOIN FIN_ACCOUNTS a ON t.ACCOUNT_ID = a.ACCOUNT_ID " +
            "LEFT JOIN FIN_CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (accountId != null && !accountId.isEmpty()) {
            sql.append(" AND t.ACCOUNT_ID = ?");
            params.add(accountId);
        }

        if (transactionType != null && !transactionType.isEmpty()) {
            sql.append(" AND t.TRANSACTION_TYPE = ?");
            params.add(transactionType);
        }

        if (fromDate != null) {
            sql.append(" AND t.TRANSACTION_DATE >= ?");
            params.add(new Timestamp(fromDate.getTime()));
        }

        if (toDate != null) {
            sql.append(" AND t.TRANSACTION_DATE <= ?");
            params.add(new Timestamp(toDate.getTime()));
        }

        sql.append(" ORDER BY t.TRANSACTION_DATE DESC) WHERE ROWNUM <= ?");
        params.add(limit > 0 ? limit : 100);

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapResultSetToTransaction(rs));
                }
            }
        }
        return transactions;
    }

    /**
     * Get recent transactions
     */
    public List<Transaction> getRecentTransactions(int limit) throws SQLException {
        List<Transaction> transactions = new ArrayList<>();
        String sql = "SELECT * FROM (SELECT t.*, a.ACCOUNT_NAME, c.FULL_NAME as CUSTOMER_NAME " +
                "FROM FIN_TRANSACTIONS t " +
                "LEFT JOIN FIN_ACCOUNTS a ON t.ACCOUNT_ID = a.ACCOUNT_ID " +
                "LEFT JOIN FIN_CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID " +
                "ORDER BY t.TRANSACTION_DATE DESC) WHERE ROWNUM <= ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapResultSetToTransaction(rs));
                }
            }
        }
        return transactions;
    }

    /**
     * Create new transaction
     */
    public Transaction createTransaction(Transaction transaction, String tellerId) throws SQLException {
        String sql = "INSERT INTO FIN_TRANSACTIONS (TRANSACTION_ID, ACCOUNT_ID, TRANSACTION_TYPE, " +
                "TRANSACTION_MODE, AMOUNT, BALANCE_AFTER, DESCRIPTION, REFERENCE_NO, TO_ACCOUNT_ID, " +
                "TO_IFSC, TO_ACCOUNT_NAME, STATUS, TRANSACTION_DATE, VALUE_DATE, BRANCH_CODE, " +
                "TELLER_ID, REMARKS, CREATED_DATE) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, SYSDATE, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = DatabaseConfig.getConnection()) {
            String transactionId = generateTransactionId(conn);
            transaction.setTransactionId(transactionId);

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, transactionId);
                stmt.setString(2, transaction.getAccountId());
                stmt.setString(3, transaction.getTransactionType());
                stmt.setString(4, transaction.getTransactionMode());
                stmt.setBigDecimal(5, transaction.getAmount());
                stmt.setBigDecimal(6, transaction.getBalanceAfter());
                stmt.setString(7, transaction.getDescription());
                stmt.setString(8, transaction.getReferenceNo());
                stmt.setString(9, transaction.getToAccountId());
                stmt.setString(10, transaction.getToIfsc());
                stmt.setString(11, transaction.getToAccountName());
                stmt.setString(12, transaction.getStatus() != null ? transaction.getStatus() : "SUCCESS");
                stmt.setString(13, transaction.getBranchCode());
                stmt.setString(14, tellerId);
                stmt.setString(15, transaction.getRemarks());

                stmt.executeUpdate();
            }
            return transaction;
        }
    }

    /**
     * Perform deposit
     */
    public Transaction performDeposit(String accountId, BigDecimal amount, String mode, 
            String description, String branchCode, String tellerId) throws SQLException {
        
        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Get current balance
                BigDecimal currentBalance;
                String sql = "SELECT BALANCE FROM FIN_ACCOUNTS WHERE ACCOUNT_ID = ? FOR UPDATE";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, accountId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException("Account not found: " + accountId);
                        }
                        currentBalance = rs.getBigDecimal("BALANCE");
                    }
                }

                // Calculate new balance
                BigDecimal newBalance = currentBalance.add(amount);

                // Update account balance
                sql = "UPDATE FIN_ACCOUNTS SET BALANCE = ?, AVAILABLE_BALANCE = ?, UPDATED_DATE = CURRENT_TIMESTAMP WHERE ACCOUNT_ID = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setBigDecimal(1, newBalance);
                    stmt.setBigDecimal(2, newBalance);
                    stmt.setString(3, accountId);
                    stmt.executeUpdate();
                }

                // Create transaction record
                Transaction txn = new Transaction();
                txn.setAccountId(accountId);
                txn.setTransactionType("CREDIT");
                txn.setTransactionMode(mode);
                txn.setAmount(amount);
                txn.setBalanceAfter(newBalance);
                txn.setDescription(description);
                txn.setReferenceNo(generateReferenceNo("DEP"));
                txn.setBranchCode(branchCode);
                txn.setStatus("SUCCESS");

                String txnId = generateTransactionId(conn);
                txn.setTransactionId(txnId);

                sql = "INSERT INTO FIN_TRANSACTIONS (TRANSACTION_ID, ACCOUNT_ID, TRANSACTION_TYPE, " +
                        "TRANSACTION_MODE, AMOUNT, BALANCE_AFTER, DESCRIPTION, REFERENCE_NO, STATUS, " +
                        "TRANSACTION_DATE, VALUE_DATE, BRANCH_CODE, TELLER_ID, CREATED_DATE) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, SYSDATE, ?, ?, CURRENT_TIMESTAMP)";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, txnId);
                    stmt.setString(2, accountId);
                    stmt.setString(3, "CREDIT");
                    stmt.setString(4, mode);
                    stmt.setBigDecimal(5, amount);
                    stmt.setBigDecimal(6, newBalance);
                    stmt.setString(7, description);
                    stmt.setString(8, txn.getReferenceNo());
                    stmt.setString(9, "SUCCESS");
                    stmt.setString(10, branchCode);
                    stmt.setString(11, tellerId);
                    stmt.executeUpdate();
                }

                conn.commit();
                return txn;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * Perform withdrawal
     */
    public Transaction performWithdrawal(String accountId, BigDecimal amount, String mode,
            String description, String branchCode, String tellerId) throws SQLException {
        
        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Get current balance
                BigDecimal currentBalance;
                String sql = "SELECT BALANCE FROM FIN_ACCOUNTS WHERE ACCOUNT_ID = ? FOR UPDATE";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, accountId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException("Account not found: " + accountId);
                        }
                        currentBalance = rs.getBigDecimal("BALANCE");
                    }
                }

                // Check sufficient balance
                if (currentBalance.compareTo(amount) < 0) {
                    throw new SQLException("Insufficient balance. Available: " + currentBalance);
                }

                // Calculate new balance
                BigDecimal newBalance = currentBalance.subtract(amount);

                // Update account balance
                sql = "UPDATE FIN_ACCOUNTS SET BALANCE = ?, AVAILABLE_BALANCE = ?, UPDATED_DATE = CURRENT_TIMESTAMP WHERE ACCOUNT_ID = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setBigDecimal(1, newBalance);
                    stmt.setBigDecimal(2, newBalance);
                    stmt.setString(3, accountId);
                    stmt.executeUpdate();
                }

                // Create transaction record
                Transaction txn = new Transaction();
                txn.setAccountId(accountId);
                txn.setTransactionType("DEBIT");
                txn.setTransactionMode(mode);
                txn.setAmount(amount);
                txn.setBalanceAfter(newBalance);
                txn.setDescription(description);
                txn.setReferenceNo(generateReferenceNo("WDL"));
                txn.setBranchCode(branchCode);
                txn.setStatus("SUCCESS");

                String txnId = generateTransactionId(conn);
                txn.setTransactionId(txnId);

                sql = "INSERT INTO FIN_TRANSACTIONS (TRANSACTION_ID, ACCOUNT_ID, TRANSACTION_TYPE, " +
                        "TRANSACTION_MODE, AMOUNT, BALANCE_AFTER, DESCRIPTION, REFERENCE_NO, STATUS, " +
                        "TRANSACTION_DATE, VALUE_DATE, BRANCH_CODE, TELLER_ID, CREATED_DATE) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, SYSDATE, ?, ?, CURRENT_TIMESTAMP)";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, txnId);
                    stmt.setString(2, accountId);
                    stmt.setString(3, "DEBIT");
                    stmt.setString(4, mode);
                    stmt.setBigDecimal(5, amount);
                    stmt.setBigDecimal(6, newBalance);
                    stmt.setString(7, description);
                    stmt.setString(8, txn.getReferenceNo());
                    stmt.setString(9, "SUCCESS");
                    stmt.setString(10, branchCode);
                    stmt.setString(11, tellerId);
                    stmt.executeUpdate();
                }

                conn.commit();
                return txn;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * Generate transaction ID
     */
    private String generateTransactionId(Connection conn) throws SQLException {
        String sql = "SELECT 'TXN' || TO_CHAR(SYSDATE, 'YYYYMMDD') || LPAD(FIN_TRANSACTION_SEQ.NEXTVAL, 6, '0') FROM DUAL";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getString(1);
            }
        }
        throw new SQLException("Failed to generate transaction ID");
    }

    /**
     * Generate reference number
     */
    private String generateReferenceNo(String prefix) {
        return prefix + System.currentTimeMillis();
    }

    /**
     * Map ResultSet to Transaction object
     */
    private Transaction mapResultSetToTransaction(ResultSet rs) throws SQLException {
        Transaction txn = new Transaction();
        txn.setTransactionId(rs.getString("TRANSACTION_ID"));
        txn.setAccountId(rs.getString("ACCOUNT_ID"));
        txn.setTransactionType(rs.getString("TRANSACTION_TYPE"));
        txn.setTransactionMode(rs.getString("TRANSACTION_MODE"));
        txn.setAmount(rs.getBigDecimal("AMOUNT"));
        txn.setBalanceAfter(rs.getBigDecimal("BALANCE_AFTER"));
        txn.setDescription(rs.getString("DESCRIPTION"));
        txn.setReferenceNo(rs.getString("REFERENCE_NO"));
        txn.setToAccountId(rs.getString("TO_ACCOUNT_ID"));
        txn.setToIfsc(rs.getString("TO_IFSC"));
        txn.setToAccountName(rs.getString("TO_ACCOUNT_NAME"));
        txn.setStatus(rs.getString("STATUS"));
        txn.setTransactionDate(rs.getTimestamp("TRANSACTION_DATE"));
        txn.setValueDate(rs.getDate("VALUE_DATE"));
        txn.setBranchCode(rs.getString("BRANCH_CODE"));
        txn.setTellerId(rs.getString("TELLER_ID"));
        txn.setRemarks(rs.getString("REMARKS"));
        txn.setCreatedDate(rs.getTimestamp("CREATED_DATE"));
        
        try {
            txn.setAccountName(rs.getString("ACCOUNT_NAME"));
            txn.setCustomerName(rs.getString("CUSTOMER_NAME"));
        } catch (SQLException e) {
            // Columns may not exist in all queries
        }
        
        return txn;
    }
}
