package com.ucobank.finacle.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

/**
 * Customer Model - Represents a CIF (Customer Information File) record
 */
public class Customer {
    private String customerId;
    private String customerType; // RETAIL, CORPORATE
    private String fullName;
    private Date dateOfBirth;
    private String gender;
    private String email;
    private String phone;
    private String mobile;
    private String addressLine1;
    private String addressLine2;
    private String city;
    private String state;
    private String pinCode;
    private String country;
    private String idType;
    private String idNumber;
    private String panNumber;
    private String aadharNumber;
    private String occupation;
    private BigDecimal annualIncome;
    private String relationshipManager;
    private String kycStatus;
    private String riskCategory;
    private String status;
    private String createdBy;
    private Timestamp createdDate;
    private String updatedBy;
    private Timestamp updatedDate;
    private String approvedBy;
    private Timestamp approvedDate;

    // Getters and Setters
    public String getCustomerId() { return customerId; }
    public void setCustomerId(String customerId) { this.customerId = customerId; }

    public String getCustomerType() { return customerType; }
    public void setCustomerType(String customerType) { this.customerType = customerType; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public Date getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getMobile() { return mobile; }
    public void setMobile(String mobile) { this.mobile = mobile; }

    public String getAddressLine1() { return addressLine1; }
    public void setAddressLine1(String addressLine1) { this.addressLine1 = addressLine1; }

    public String getAddressLine2() { return addressLine2; }
    public void setAddressLine2(String addressLine2) { this.addressLine2 = addressLine2; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getPinCode() { return pinCode; }
    public void setPinCode(String pinCode) { this.pinCode = pinCode; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    public String getIdType() { return idType; }
    public void setIdType(String idType) { this.idType = idType; }

    public String getIdNumber() { return idNumber; }
    public void setIdNumber(String idNumber) { this.idNumber = idNumber; }

    public String getPanNumber() { return panNumber; }
    public void setPanNumber(String panNumber) { this.panNumber = panNumber; }

    public String getAadharNumber() { return aadharNumber; }
    public void setAadharNumber(String aadharNumber) { this.aadharNumber = aadharNumber; }

    public String getOccupation() { return occupation; }
    public void setOccupation(String occupation) { this.occupation = occupation; }

    public BigDecimal getAnnualIncome() { return annualIncome; }
    public void setAnnualIncome(BigDecimal annualIncome) { this.annualIncome = annualIncome; }

    public String getRelationshipManager() { return relationshipManager; }
    public void setRelationshipManager(String relationshipManager) { this.relationshipManager = relationshipManager; }

    public String getKycStatus() { return kycStatus; }
    public void setKycStatus(String kycStatus) { this.kycStatus = kycStatus; }

    public String getRiskCategory() { return riskCategory; }
    public void setRiskCategory(String riskCategory) { this.riskCategory = riskCategory; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public String getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(String updatedBy) { this.updatedBy = updatedBy; }

    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }

    public String getApprovedBy() { return approvedBy; }
    public void setApprovedBy(String approvedBy) { this.approvedBy = approvedBy; }

    public Timestamp getApprovedDate() { return approvedDate; }
    public void setApprovedDate(Timestamp approvedDate) { this.approvedDate = approvedDate; }
}
