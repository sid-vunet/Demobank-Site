package com.ucobank.finacle.dao;

import com.ucobank.finacle.config.DatabaseConfig;
import com.ucobank.finacle.model.Customer;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Customer DAO - Data Access Object for Customer (CIF) operations
 */
public class CustomerDAO {

    /**
     * Get all customers with optional type filter
     */
    public List<Customer> getAllCustomers(String customerType) throws SQLException {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM FIN_CUSTOMERS WHERE STATUS = 'ACTIVE'";
        
        if (customerType != null && !customerType.isEmpty()) {
            sql += " AND CUSTOMER_TYPE = ?";
        }
        sql += " ORDER BY CREATED_DATE DESC";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            if (customerType != null && !customerType.isEmpty()) {
                stmt.setString(1, customerType);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    customers.add(mapResultSetToCustomer(rs));
                }
            }
        }
        return customers;
    }

    /**
     * Get customer by ID
     */
    public Customer getCustomerById(String customerId) throws SQLException {
        String sql = "SELECT * FROM FIN_CUSTOMERS WHERE CUSTOMER_ID = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, customerId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCustomer(rs);
                }
            }
        }
        return null;
    }

    /**
     * Search customers by various criteria
     */
    public List<Customer> searchCustomers(String searchTerm, String customerType, String status) throws SQLException {
        List<Customer> customers = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM FIN_CUSTOMERS WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (customerType != null && !customerType.isEmpty()) {
            sql.append(" AND CUSTOMER_TYPE = ?");
            params.add(customerType);
        }

        if (status != null && !status.isEmpty()) {
            sql.append(" AND STATUS = ?");
            params.add(status);
        }

        if (searchTerm != null && !searchTerm.isEmpty()) {
            sql.append(" AND (UPPER(CUSTOMER_ID) LIKE ? OR UPPER(FULL_NAME) LIKE ? OR MOBILE LIKE ? OR UPPER(PAN_NUMBER) LIKE ? OR AADHAR_NUMBER LIKE ?)");
            String term = "%" + searchTerm.toUpperCase() + "%";
            params.add(term);
            params.add(term);
            params.add("%" + searchTerm + "%");
            params.add(term);
            params.add("%" + searchTerm + "%");
        }

        sql.append(" ORDER BY CREATED_DATE DESC");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    customers.add(mapResultSetToCustomer(rs));
                }
            }
        }
        return customers;
    }

    /**
     * Create new customer
     */
    public Customer createCustomer(Customer customer, String createdBy) throws SQLException {
        String sql = "INSERT INTO FIN_CUSTOMERS (CUSTOMER_ID, CUSTOMER_TYPE, FULL_NAME, DATE_OF_BIRTH, GENDER, " +
                "EMAIL, PHONE, MOBILE, ADDRESS_LINE1, ADDRESS_LINE2, CITY, STATE, PIN_CODE, COUNTRY, " +
                "ID_TYPE, ID_NUMBER, PAN_NUMBER, AADHAR_NUMBER, OCCUPATION, ANNUAL_INCOME, " +
                "RELATIONSHIP_MANAGER, KYC_STATUS, RISK_CATEGORY, STATUS, CREATED_BY, CREATED_DATE) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = DatabaseConfig.getConnection()) {
            // Generate new customer ID
            String customerId = generateCustomerId(conn);
            customer.setCustomerId(customerId);

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, customerId);
                stmt.setString(2, customer.getCustomerType());
                stmt.setString(3, customer.getFullName());
                stmt.setDate(4, customer.getDateOfBirth() != null ? new java.sql.Date(customer.getDateOfBirth().getTime()) : null);
                stmt.setString(5, customer.getGender());
                stmt.setString(6, customer.getEmail());
                stmt.setString(7, customer.getPhone());
                stmt.setString(8, customer.getMobile());
                stmt.setString(9, customer.getAddressLine1());
                stmt.setString(10, customer.getAddressLine2());
                stmt.setString(11, customer.getCity());
                stmt.setString(12, customer.getState());
                stmt.setString(13, customer.getPinCode());
                stmt.setString(14, customer.getCountry() != null ? customer.getCountry() : "INDIA");
                stmt.setString(15, customer.getIdType());
                stmt.setString(16, customer.getIdNumber());
                stmt.setString(17, customer.getPanNumber());
                stmt.setString(18, customer.getAadharNumber());
                stmt.setString(19, customer.getOccupation());
                stmt.setBigDecimal(20, customer.getAnnualIncome());
                stmt.setString(21, customer.getRelationshipManager());
                stmt.setString(22, customer.getKycStatus() != null ? customer.getKycStatus() : "PENDING");
                stmt.setString(23, customer.getRiskCategory() != null ? customer.getRiskCategory() : "LOW");
                stmt.setString(24, "ACTIVE");
                stmt.setString(25, createdBy);

                stmt.executeUpdate();
            }
            return customer;
        }
    }

    /**
     * Update customer
     */
    public boolean updateCustomer(Customer customer, String updatedBy) throws SQLException {
        String sql = "UPDATE FIN_CUSTOMERS SET FULL_NAME = ?, DATE_OF_BIRTH = ?, GENDER = ?, " +
                "EMAIL = ?, PHONE = ?, MOBILE = ?, ADDRESS_LINE1 = ?, ADDRESS_LINE2 = ?, " +
                "CITY = ?, STATE = ?, PIN_CODE = ?, ID_TYPE = ?, ID_NUMBER = ?, " +
                "PAN_NUMBER = ?, AADHAR_NUMBER = ?, OCCUPATION = ?, ANNUAL_INCOME = ?, " +
                "RELATIONSHIP_MANAGER = ?, KYC_STATUS = ?, RISK_CATEGORY = ?, STATUS = ?, " +
                "UPDATED_BY = ?, UPDATED_DATE = CURRENT_TIMESTAMP " +
                "WHERE CUSTOMER_ID = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, customer.getFullName());
            stmt.setDate(2, customer.getDateOfBirth() != null ? new java.sql.Date(customer.getDateOfBirth().getTime()) : null);
            stmt.setString(3, customer.getGender());
            stmt.setString(4, customer.getEmail());
            stmt.setString(5, customer.getPhone());
            stmt.setString(6, customer.getMobile());
            stmt.setString(7, customer.getAddressLine1());
            stmt.setString(8, customer.getAddressLine2());
            stmt.setString(9, customer.getCity());
            stmt.setString(10, customer.getState());
            stmt.setString(11, customer.getPinCode());
            stmt.setString(12, customer.getIdType());
            stmt.setString(13, customer.getIdNumber());
            stmt.setString(14, customer.getPanNumber());
            stmt.setString(15, customer.getAadharNumber());
            stmt.setString(16, customer.getOccupation());
            stmt.setBigDecimal(17, customer.getAnnualIncome());
            stmt.setString(18, customer.getRelationshipManager());
            stmt.setString(19, customer.getKycStatus());
            stmt.setString(20, customer.getRiskCategory());
            stmt.setString(21, customer.getStatus());
            stmt.setString(22, updatedBy);
            stmt.setString(23, customer.getCustomerId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete (soft delete) customer
     */
    public boolean deleteCustomer(String customerId, String deletedBy) throws SQLException {
        String sql = "UPDATE FIN_CUSTOMERS SET STATUS = 'CLOSED', UPDATED_BY = ?, UPDATED_DATE = CURRENT_TIMESTAMP WHERE CUSTOMER_ID = ?";

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, deletedBy);
            stmt.setString(2, customerId);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Get customer count by type
     */
    public int getCustomerCount(String customerType) throws SQLException {
        String sql = "SELECT COUNT(*) FROM FIN_CUSTOMERS WHERE STATUS = 'ACTIVE'";
        if (customerType != null) {
            sql += " AND CUSTOMER_TYPE = ?";
        }

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            if (customerType != null) {
                stmt.setString(1, customerType);
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
     * Generate new customer ID
     */
    private String generateCustomerId(Connection conn) throws SQLException {
        String sql = "SELECT 'CIF' || FIN_CUSTOMER_SEQ.NEXTVAL FROM DUAL";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getString(1);
            }
        }
        throw new SQLException("Failed to generate customer ID");
    }

    /**
     * Map ResultSet to Customer object
     */
    private Customer mapResultSetToCustomer(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setCustomerId(rs.getString("CUSTOMER_ID"));
        customer.setCustomerType(rs.getString("CUSTOMER_TYPE"));
        customer.setFullName(rs.getString("FULL_NAME"));
        customer.setDateOfBirth(rs.getDate("DATE_OF_BIRTH"));
        customer.setGender(rs.getString("GENDER"));
        customer.setEmail(rs.getString("EMAIL"));
        customer.setPhone(rs.getString("PHONE"));
        customer.setMobile(rs.getString("MOBILE"));
        customer.setAddressLine1(rs.getString("ADDRESS_LINE1"));
        customer.setAddressLine2(rs.getString("ADDRESS_LINE2"));
        customer.setCity(rs.getString("CITY"));
        customer.setState(rs.getString("STATE"));
        customer.setPinCode(rs.getString("PIN_CODE"));
        customer.setCountry(rs.getString("COUNTRY"));
        customer.setIdType(rs.getString("ID_TYPE"));
        customer.setIdNumber(rs.getString("ID_NUMBER"));
        customer.setPanNumber(rs.getString("PAN_NUMBER"));
        customer.setAadharNumber(rs.getString("AADHAR_NUMBER"));
        customer.setOccupation(rs.getString("OCCUPATION"));
        customer.setAnnualIncome(rs.getBigDecimal("ANNUAL_INCOME"));
        customer.setRelationshipManager(rs.getString("RELATIONSHIP_MANAGER"));
        customer.setKycStatus(rs.getString("KYC_STATUS"));
        customer.setRiskCategory(rs.getString("RISK_CATEGORY"));
        customer.setStatus(rs.getString("STATUS"));
        customer.setCreatedBy(rs.getString("CREATED_BY"));
        customer.setCreatedDate(rs.getTimestamp("CREATED_DATE"));
        customer.setUpdatedBy(rs.getString("UPDATED_BY"));
        customer.setUpdatedDate(rs.getTimestamp("UPDATED_DATE"));
        customer.setApprovedBy(rs.getString("APPROVED_BY"));
        customer.setApprovedDate(rs.getTimestamp("APPROVED_DATE"));
        return customer;
    }
}
