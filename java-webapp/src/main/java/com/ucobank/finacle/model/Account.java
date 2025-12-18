package com.ucobank.finacle.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

/**
 * Account Model - Represents a bank account
 */
public class Account {
    private String accountId;
    private String customerId;
    private String accountType; // SAVINGS, CURRENT, FD, RD
    private String accountName;
    private String currency;
    private BigDecimal balance;
    private BigDecimal availableBalance;
    private BigDecimal interestRate;
    private Date openingDate;
    private Date maturityDate;
    private String branchCode;
    private String ifscCode;
    private String status;
    private String nomineeName;
    private String nomineeRelation;
    private String createdBy;
    private Timestamp createdDate;
    private String updatedBy;
    private Timestamp updatedDate;

    // For display - joined customer name
    private String customerName;

    // Getters and Setters
    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }

    public String getCustomerId() { return customerId; }
    public void setCustomerId(String customerId) { this.customerId = customerId; }

    public String getAccountType() { return accountType; }
    public void setAccountType(String accountType) { this.accountType = accountType; }

    public String getAccountName() { return accountName; }
    public void setAccountName(String accountName) { this.accountName = accountName; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public BigDecimal getBalance() { return balance; }
    public void setBalance(BigDecimal balance) { this.balance = balance; }

    public BigDecimal getAvailableBalance() { return availableBalance; }
    public void setAvailableBalance(BigDecimal availableBalance) { this.availableBalance = availableBalance; }

    public BigDecimal getInterestRate() { return interestRate; }
    public void setInterestRate(BigDecimal interestRate) { this.interestRate = interestRate; }

    public Date getOpeningDate() { return openingDate; }
    public void setOpeningDate(Date openingDate) { this.openingDate = openingDate; }

    public Date getMaturityDate() { return maturityDate; }
    public void setMaturityDate(Date maturityDate) { this.maturityDate = maturityDate; }

    public String getBranchCode() { return branchCode; }
    public void setBranchCode(String branchCode) { this.branchCode = branchCode; }

    public String getIfscCode() { return ifscCode; }
    public void setIfscCode(String ifscCode) { this.ifscCode = ifscCode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNomineeName() { return nomineeName; }
    public void setNomineeName(String nomineeName) { this.nomineeName = nomineeName; }

    public String getNomineeRelation() { return nomineeRelation; }
    public void setNomineeRelation(String nomineeRelation) { this.nomineeRelation = nomineeRelation; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public String getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(String updatedBy) { this.updatedBy = updatedBy; }

    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
}
