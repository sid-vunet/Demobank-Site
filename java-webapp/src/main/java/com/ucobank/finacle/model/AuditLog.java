package com.ucobank.finacle.model;

import java.sql.Timestamp;

/**
 * AuditLog Model - Represents an audit trail entry
 */
public class AuditLog {
    private Long auditId;
    private String entityType;
    private String entityId;
    private String action;
    private String oldValue;
    private String newValue;
    private String fieldName;
    private String userId;
    private String userIp;
    private String userAgent;
    private String sessionId;
    private Timestamp actionDate;
    private String remarks;

    // For display
    private String userName;

    // Getters and Setters
    public Long getAuditId() { return auditId; }
    public void setAuditId(Long auditId) { this.auditId = auditId; }

    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public String getEntityId() { return entityId; }
    public void setEntityId(String entityId) { this.entityId = entityId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getOldValue() { return oldValue; }
    public void setOldValue(String oldValue) { this.oldValue = oldValue; }

    public String getNewValue() { return newValue; }
    public void setNewValue(String newValue) { this.newValue = newValue; }

    public String getFieldName() { return fieldName; }
    public void setFieldName(String fieldName) { this.fieldName = fieldName; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserIp() { return userIp; }
    public void setUserIp(String userIp) { this.userIp = userIp; }

    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }

    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }

    public Timestamp getActionDate() { return actionDate; }
    public void setActionDate(Timestamp actionDate) { this.actionDate = actionDate; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
}
