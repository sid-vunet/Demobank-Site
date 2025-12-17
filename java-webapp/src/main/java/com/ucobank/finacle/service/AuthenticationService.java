package com.ucobank.finacle.service;

import com.ucobank.finacle.model.User;

/**
 * Authentication Service - Handles user authentication
 * In production, this would connect to a database or LDAP
 */
public class AuthenticationService {

    /**
     * Authenticate user with username and password
     * @param username User ID
     * @param password Password
     * @return User object if authenticated, null otherwise
     */
    public User authenticate(String username, String password) {
        // For simulation, accept any non-empty credentials
        // In production, this would validate against database/LDAP
        
        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        
        if (password == null || password.trim().isEmpty()) {
            return null;
        }
        
        // Simulate authentication - in production, verify against database
        // For demo purposes, any username/password combination works
        
        // Create authenticated user
        User user = new User();
        user.setUserId(username.toUpperCase());
        user.setUsername(username);
        user.setFullName(capitalizeFirst(username));
        user.setRole("ADMIN"); // Default role
        user.setBranch("HEAD_OFFICE");
        user.setSolution("FININFRA");
        user.setActive(true);
        
        // Special users for testing different roles
        if ("admin".equalsIgnoreCase(username)) {
            user.setRole("ADMIN");
            user.setFullName("Administrator");
        } else if ("maker".equalsIgnoreCase(username)) {
            user.setRole("MAKER");
            user.setFullName("Maker User");
        } else if ("checker".equalsIgnoreCase(username)) {
            user.setRole("CHECKER");
            user.setFullName("Checker User");
        } else if ("viewer".equalsIgnoreCase(username)) {
            user.setRole("VIEWER");
            user.setFullName("View Only User");
        }
        
        return user;
    }
    
    /**
     * Validate session token
     * @param token Session token
     * @return true if valid, false otherwise
     */
    public boolean validateToken(String token) {
        // In production, validate token against session store
        return token != null && !token.isEmpty();
    }
    
    private String capitalizeFirst(String str) {
        if (str == null || str.isEmpty()) {
            return str;
        }
        return str.substring(0, 1).toUpperCase() + str.substring(1).toLowerCase();
    }
}
