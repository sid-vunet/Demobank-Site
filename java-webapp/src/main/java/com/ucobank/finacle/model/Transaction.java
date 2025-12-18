package com.ucobank.finacle.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

/**
 * Transaction Model - Represents a bank transaction
 */
public class Transaction {
    private String transactionId;
    private String accountId;
    private String transactionType; // CREDIT, DEBIT, TRANSFER
    private String transactionMode; // CASH, CHEQUE, NEFT, RTGS, IMPS, UPI
    private BigDecimal amount;
    private BigDecimal balanceAfter;
    private String description;
    private String referenceNo;
    private String toAccountId;
    private String toIfsc;
    private String toAccountName;
    private String status;
    private Timestamp transactionDate;
    private Date valueDate;
    private String branchCode;
    private String tellerId;
    private String remarks;
    private Timestamp createdDate;

    // For display - joined fields
    private String accountName;
    private String customerName;

    // Getters and Setters
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }

    public String getTransactionType() { return transactionType; }
    public void setTransactionType(String transactionType) { this.transactionType = transactionType; }

    public String getTransactionMode() { return transactionMode; }
    public void setTransactionMode(String transactionMode) { this.transactionMode = transactionMode; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public BigDecimal getBalanceAfter() { return balanceAfter; }
    public void setBalanceAfter(BigDecimal balanceAfter) { this.balanceAfter = balanceAfter; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getReferenceNo() { return referenceNo; }
    public void setReferenceNo(String referenceNo) { this.referenceNo = referenceNo; }

    public String getToAccountId() { return toAccountId; }
    public void setToAccountId(String toAccountId) { this.toAccountId = toAccountId; }

    public String getToIfsc() { return toIfsc; }
    public void setToIfsc(String toIfsc) { this.toIfsc = toIfsc; }

    public String getToAccountName() { return toAccountName; }
    public void setToAccountName(String toAccountName) { this.toAccountName = toAccountName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getTransactionDate() { return transactionDate; }
    public void setTransactionDate(Timestamp transactionDate) { this.transactionDate = transactionDate; }

    public Date getValueDate() { return valueDate; }
    public void setValueDate(Date valueDate) { this.valueDate = valueDate; }

    public String getBranchCode() { return branchCode; }
    public void setBranchCode(String branchCode) { this.branchCode = branchCode; }

    public String getTellerId() { return tellerId; }
    public void setTellerId(String tellerId) { this.tellerId = tellerId; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public String getAccountName() { return accountName; }
    public void setAccountName(String accountName) { this.accountName = accountName; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
}
