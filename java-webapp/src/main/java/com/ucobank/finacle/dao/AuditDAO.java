package com.ucobank.finacle.dao;

import com.ucobank.finacle.config.DatabaseConfig;
import com.ucobank.finacle.model.AuditLog;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Audit DAO - Data Access Object for Audit Log operations
 */
public class AuditDAO {

    /**
     * Log an audit entry
     */
    public void logAudit(String entityType, String entityId, String action, 
            String oldValue, String newValue, String fieldName, String userId, 
            String userIp, String sessionId, String remarks) throws SQLException {
        
        String sql = "INSERT INTO FIN_AUDIT_LOGS (AUDIT_ID, ENTITY_TYPE, ENTITY_ID, ACTION, " +
                "OLD_VALUE, NEW_VALUE, FIELD_NAME, USER_ID, USER_IP, SESSION_ID, ACTION_DATE, REMARKS) " +
                "VALUES (FIN_AUDIT_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?)";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, entityType);
            stmt.setString(2, entityId);
            stmt.setString(3, action);
            stmt.setString(4, oldValue);
            stmt.setString(5, newValue);
            stmt.setString(6, fieldName);
            stmt.setString(7, userId);
            stmt.setString(8, userIp);
            stmt.setString(9, sessionId);
            stmt.setString(10, remarks);

            stmt.executeUpdate();
        }
    }

    /**
     * Get audit logs by entity
     */
    public List<AuditLog> getAuditLogsByEntity(String entityType, String entityId, int limit) throws SQLException {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT * FROM (SELECT a.*, u.FULL_NAME as USER_NAME FROM FIN_AUDIT_LOGS a " +
                "LEFT JOIN FIN_USERS u ON a.USER_ID = u.USER_ID " +
                "WHERE a.ENTITY_TYPE = ? AND a.ENTITY_ID = ? ORDER BY a.ACTION_DATE DESC) WHERE ROWNUM <= ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, entityType);
            stmt.setString(2, entityId);
            stmt.setInt(3, limit > 0 ? limit : 100);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToAuditLog(rs));
                }
            }
        }
        return logs;
    }

    /**
     * Search audit logs
     */
    public List<AuditLog> searchAuditLogs(String entityType, String entityId, String action,
            String userId, Date fromDate, Date toDate, int limit) throws SQLException {
        List<AuditLog> logs = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT * FROM (SELECT a.*, u.FULL_NAME as USER_NAME FROM FIN_AUDIT_LOGS a " +
            "LEFT JOIN FIN_USERS u ON a.USER_ID = u.USER_ID WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (entityType != null && !entityType.isEmpty()) {
            sql.append(" AND a.ENTITY_TYPE = ?");
            params.add(entityType);
        }

        if (entityId != null && !entityId.isEmpty()) {
            sql.append(" AND a.ENTITY_ID = ?");
            params.add(entityId);
        }

        if (action != null && !action.isEmpty()) {
            sql.append(" AND a.ACTION = ?");
            params.add(action);
        }

        if (userId != null && !userId.isEmpty()) {
            sql.append(" AND a.USER_ID = ?");
            params.add(userId);
        }

        if (fromDate != null) {
            sql.append(" AND a.ACTION_DATE >= ?");
            params.add(new Timestamp(fromDate.getTime()));
        }

        if (toDate != null) {
            sql.append(" AND a.ACTION_DATE <= ?");
            params.add(new Timestamp(toDate.getTime()));
        }

        sql.append(" ORDER BY a.ACTION_DATE DESC) WHERE ROWNUM <= ?");
        params.add(limit > 0 ? limit : 100);

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToAuditLog(rs));
                }
            }
        }
        return logs;
    }

    /**
     * Get recent audit logs
     */
    public List<AuditLog> getRecentAuditLogs(int limit) throws SQLException {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT * FROM (SELECT a.*, u.FULL_NAME as USER_NAME FROM FIN_AUDIT_LOGS a " +
                "LEFT JOIN FIN_USERS u ON a.USER_ID = u.USER_ID " +
                "ORDER BY a.ACTION_DATE DESC) WHERE ROWNUM <= ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToAuditLog(rs));
                }
            }
        }
        return logs;
    }

    /**
     * Map ResultSet to AuditLog object
     */
    private AuditLog mapResultSetToAuditLog(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setAuditId(rs.getLong("AUDIT_ID"));
        log.setEntityType(rs.getString("ENTITY_TYPE"));
        log.setEntityId(rs.getString("ENTITY_ID"));
        log.setAction(rs.getString("ACTION"));
        log.setOldValue(rs.getString("OLD_VALUE"));
        log.setNewValue(rs.getString("NEW_VALUE"));
        log.setFieldName(rs.getString("FIELD_NAME"));
        log.setUserId(rs.getString("USER_ID"));
        log.setUserIp(rs.getString("USER_IP"));
        log.setSessionId(rs.getString("SESSION_ID"));
        log.setActionDate(rs.getTimestamp("ACTION_DATE"));
        log.setRemarks(rs.getString("REMARKS"));
        
        try {
            log.setUserName(rs.getString("USER_NAME"));
        } catch (SQLException e) {
            // Column may not exist
        }
        
        return log;
    }
}
