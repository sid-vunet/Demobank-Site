package com.ucobank.finacle.config;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Database Initializer - Automatically creates tables on application startup
 * Reads schema.sql from resources and executes it against Oracle database
 */
@WebListener
public class DatabaseInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("========================================");
        System.out.println("  UCO Bank Finacle - Database Init");
        System.out.println("========================================");
        
        try {
            // Check if database is accessible
            if (!testConnection()) {
                System.out.println("⚠ Database connection failed - skipping initialization");
                System.out.println("  App will work with demo mode (no persistence)");
                return;
            }
            
            // Check if tables already exist
            if (tablesExist()) {
                System.out.println("✓ Database tables already exist");
                printTableCounts();
                return;
            }
            
            // Initialize database
            System.out.println("→ Initializing database schema...");
            initializeDatabase();
            System.out.println("✓ Database initialization complete!");
            printTableCounts();
            
        } catch (Exception e) {
            System.out.println("⚠ Database initialization error: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("========================================");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Shutting down database connections...");
        DatabaseConfig.shutdown();
    }

    private boolean testConnection() {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            System.out.println("  Connection error: " + e.getMessage());
            return false;
        }
    }

    private boolean tablesExist() {
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement()) {
            ResultSet rs = stmt.executeQuery(
                "SELECT COUNT(*) FROM user_tables WHERE table_name IN ('FIN_CUSTOMERS', 'FIN_ACCOUNTS', 'FIN_TRANSACTIONS')"
            );
            if (rs.next()) {
                return rs.getInt(1) >= 3;
            }
        } catch (Exception e) {
            // Tables don't exist
        }
        return false;
    }

    private void printTableCounts() {
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement()) {
            
            String[] tables = {"FIN_CUSTOMERS", "FIN_ACCOUNTS", "FIN_TRANSACTIONS", "FIN_AUDIT_LOGS", "FIN_USERS"};
            for (String table : tables) {
                try {
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM " + table);
                    if (rs.next()) {
                        System.out.println("  " + table + ": " + rs.getInt(1) + " rows");
                    }
                } catch (Exception e) {
                    System.out.println("  " + table + ": (not found)");
                }
            }
        } catch (Exception e) {
            // Ignore
        }
    }

    private void initializeDatabase() throws Exception {
        // Read schema.sql from resources
        InputStream is = getClass().getClassLoader().getResourceAsStream("sql/schema.sql");
        if (is == null) {
            throw new RuntimeException("schema.sql not found in resources!");
        }

        List<String> statements = parseSqlFile(is);
        System.out.println("  Found " + statements.size() + " SQL statements");

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            
            int success = 0;
            int failed = 0;
            
            for (String sql : statements) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute(sql);
                    success++;
                } catch (Exception e) {
                    // Some statements (like DROP) may fail if object doesn't exist - that's OK
                    if (!sql.toUpperCase().contains("DROP") && !sql.toUpperCase().contains("EXCEPTION")) {
                        System.out.println("  Warning: " + e.getMessage().split("\n")[0]);
                        failed++;
                    }
                }
            }
            
            conn.commit();
            System.out.println("  Executed: " + success + " successful, " + failed + " warnings");
        }
    }

    private List<String> parseSqlFile(InputStream is) throws Exception {
        List<String> statements = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean inPlsqlBlock = false;

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();
                
                // Skip empty lines and comments
                if (trimmed.isEmpty() || trimmed.startsWith("--")) {
                    continue;
                }

                // Check for PL/SQL block start
                if (trimmed.toUpperCase().startsWith("BEGIN") || 
                    trimmed.toUpperCase().startsWith("DECLARE") ||
                    trimmed.toUpperCase().startsWith("CREATE OR REPLACE")) {
                    inPlsqlBlock = true;
                }

                current.append(line).append("\n");

                // Check for statement end
                if (inPlsqlBlock) {
                    // PL/SQL blocks end with /
                    if (trimmed.equals("/")) {
                        String sql = current.toString().replace("\n/", "").trim();
                        if (!sql.isEmpty()) {
                            statements.add(sql);
                        }
                        current = new StringBuilder();
                        inPlsqlBlock = false;
                    }
                } else {
                    // Regular SQL ends with ;
                    if (trimmed.endsWith(";")) {
                        String sql = current.toString().trim();
                        sql = sql.substring(0, sql.length() - 1); // Remove trailing ;
                        if (!sql.isEmpty()) {
                            statements.add(sql);
                        }
                        current = new StringBuilder();
                    }
                }
            }
        }

        // Add any remaining statement
        String remaining = current.toString().trim();
        if (!remaining.isEmpty() && !remaining.equals("/")) {
            if (remaining.endsWith(";")) {
                remaining = remaining.substring(0, remaining.length() - 1);
            }
            statements.add(remaining);
        }

        return statements;
    }
}
