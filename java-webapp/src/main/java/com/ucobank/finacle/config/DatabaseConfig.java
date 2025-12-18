package com.ucobank.finacle.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Database Configuration - Oracle Database Connection Pool
 * Uses HikariCP for connection pooling
 * Supports environment variables for Docker deployment
 */
public class DatabaseConfig {

    private static HikariDataSource dataSource;

    // Oracle Database Configuration - reads from environment variables with defaults
    private static final String DB_HOST = getEnv("DB_HOST", "10.1.92.130");
    private static final String DB_PORT = getEnv("DB_PORT", "1521");
    private static final String DB_SERVICE = getEnv("DB_SERVICE", "XEPDB1");
    private static final String USERNAME = getEnv("DB_USERNAME", "system");
    private static final String PASSWORD = getEnv("DB_PASSWORD", "Oracle123!");
    
    // Build JDBC URL from components
    private static final String JDBC_URL = "jdbc:oracle:thin:@//" + DB_HOST + ":" + DB_PORT + "/" + DB_SERVICE;
    
    private static String getEnv(String name, String defaultValue) {
        String value = System.getenv(name);
        return (value != null && !value.isEmpty()) ? value : defaultValue;
    }

    static {
        try {
            initializeDataSource();
        } catch (Exception e) {
            System.err.println("Failed to initialize database connection pool: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void initializeDataSource() {
        System.out.println("Connecting to Oracle Database: " + JDBC_URL);
        HikariConfig config = new HikariConfig();
        
        // Oracle JDBC settings
        config.setJdbcUrl(JDBC_URL);
        config.setUsername(USERNAME);
        config.setPassword(PASSWORD);
        config.setDriverClassName("oracle.jdbc.OracleDriver");
        
        // Connection pool settings
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(2);
        config.setIdleTimeout(300000); // 5 minutes
        config.setConnectionTimeout(20000); // 20 seconds
        config.setMaxLifetime(1200000); // 20 minutes
        
        // Oracle specific settings
        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", "250");
        config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        
        config.setPoolName("FinacleOraclePool");
        
        dataSource = new HikariDataSource(config);
        System.out.println("Database connection pool initialized successfully");
    }

    /**
     * Get a connection from the pool
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("DataSource not initialized");
        }
        return dataSource.getConnection();
    }

    /**
     * Get the DataSource
     */
    public static DataSource getDataSource() {
        return dataSource;
    }

    /**
     * Close the connection pool
     */
    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            System.out.println("Database connection pool closed");
        }
    }

    /**
     * Shutdown alias for closePool
     */
    public static void shutdown() {
        closePool();
    }

    /**
     * Get JDBC URL
     */
    public static String getJdbcUrl() {
        return JDBC_URL;
    }

    /**
     * Get username
     */
    public static String getUsername() {
        return USERNAME;
    }

    /**
     * Check if database connection is available
     */
    public static boolean isConnectionAvailable() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("Database connection check failed: " + e.getMessage());
            return false;
        }
    }
}
