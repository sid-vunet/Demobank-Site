package com.ucobank.finacle.servlet;

import com.ucobank.finacle.config.DatabaseConfig;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Admin Servlet - Database administration and initialization
 * Provides endpoints to check DB status, reinitialize schema, etc.
 */
@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authenticated") == null) {
            response.sendRedirect(request.getContextPath() + "/fininfra/ui/SSOLogin.jsp");
            return;
        }
        
        out.println("<!DOCTYPE html><html><head>");
        out.println("<title>Finacle Admin - Database</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }");
        out.println(".container { max-width: 900px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }");
        out.println("h1 { color: #2e5f9e; border-bottom: 2px solid #2e5f9e; padding-bottom: 10px; }");
        out.println("h2 { color: #444; margin-top: 25px; }");
        out.println(".status { padding: 15px; border-radius: 5px; margin: 10px 0; }");
        out.println(".success { background: #e8f5e9; border-left: 4px solid #4caf50; }");
        out.println(".error { background: #ffebee; border-left: 4px solid #f44336; }");
        out.println(".warning { background: #fff3e0; border-left: 4px solid #ff9800; }");
        out.println(".info { background: #e3f2fd; border-left: 4px solid #2196f3; }");
        out.println("table { width: 100%; border-collapse: collapse; margin: 15px 0; }");
        out.println("th, td { padding: 10px; text-align: left; border: 1px solid #ddd; }");
        out.println("th { background: #2e5f9e; color: white; }");
        out.println("tr:nth-child(even) { background: #f9f9f9; }");
        out.println(".btn { display: inline-block; padding: 10px 20px; margin: 5px; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; color: white; }");
        out.println(".btn-primary { background: #2e5f9e; }");
        out.println(".btn-danger { background: #f44336; }");
        out.println(".btn-success { background: #4caf50; }");
        out.println(".btn:hover { opacity: 0.9; }");
        out.println("pre { background: #263238; color: #aed581; padding: 15px; border-radius: 5px; overflow-x: auto; }");
        out.println("</style></head><body>");
        out.println("<div class='container'>");
        out.println("<h1>🔧 UCO Bank Finacle - Database Admin</h1>");
        
        if ("/status".equals(pathInfo) || pathInfo == null || pathInfo.equals("/")) {
            showStatus(out);
        } else if ("/init".equals(pathInfo)) {
            initializeDatabase(out);
        } else if ("/reset".equals(pathInfo)) {
            resetDatabase(out);
        } else {
            out.println("<div class='status error'>Unknown action: " + pathInfo + "</div>");
        }
        
        out.println("<hr style='margin-top:30px;'>");
        out.println("<a href='" + request.getContextPath() + "/admin/status' class='btn btn-primary'>📊 Status</a>");
        out.println("<a href='" + request.getContextPath() + "/admin/init' class='btn btn-success'>▶ Initialize DB</a>");
        out.println("<a href='" + request.getContextPath() + "/admin/reset' class='btn btn-danger' onclick=\"return confirm('This will DELETE all data! Are you sure?')\">🗑 Reset DB</a>");
        out.println("<a href='" + request.getContextPath() + "/fininfra/ui/SSOLogin.jsp' class='btn btn-primary'>🏠 Back to App</a>");
        
        out.println("</div></body></html>");
    }

    private void showStatus(PrintWriter out) {
        out.println("<h2>📊 Database Status</h2>");
        
        // Test connection
        try (Connection conn = DatabaseConfig.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                out.println("<div class='status success'>✓ Database connection successful</div>");
                
                // Show connection info
                out.println("<div class='status info'>");
                out.println("<strong>JDBC URL:</strong> " + DatabaseConfig.getJdbcUrl() + "<br>");
                out.println("<strong>Username:</strong> " + DatabaseConfig.getUsername() + "<br>");
                out.println("</div>");
                
                // Show table counts
                out.println("<h2>📋 Table Statistics</h2>");
                out.println("<table>");
                out.println("<tr><th>Table Name</th><th>Row Count</th><th>Status</th></tr>");
                
                String[] tables = {"FIN_USERS", "FIN_CUSTOMERS", "FIN_ACCOUNTS", "FIN_TRANSACTIONS", "FIN_AUDIT_LOGS", "FIN_MENU_ITEMS"};
                int tablesFound = 0;
                
                for (String table : tables) {
                    try (Statement stmt = conn.createStatement()) {
                        ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM " + table);
                        if (rs.next()) {
                            int count = rs.getInt(1);
                            out.println("<tr><td>" + table + "</td><td>" + count + "</td><td style='color:green;'>✓ OK</td></tr>");
                            tablesFound++;
                        }
                    } catch (Exception e) {
                        out.println("<tr><td>" + table + "</td><td>-</td><td style='color:red;'>✗ Not found</td></tr>");
                    }
                }
                out.println("</table>");
                
                if (tablesFound == 0) {
                    out.println("<div class='status warning'>⚠ No tables found. Click 'Initialize DB' to create them.</div>");
                } else if (tablesFound < tables.length) {
                    out.println("<div class='status warning'>⚠ Some tables missing. Click 'Initialize DB' to create them.</div>");
                }
                
                // Show sequences
                out.println("<h2>🔢 Sequences</h2>");
                out.println("<table>");
                out.println("<tr><th>Sequence Name</th><th>Current Value</th><th>Status</th></tr>");
                
                String[] sequences = {"FIN_CUSTOMER_SEQ", "FIN_ACCOUNT_SEQ", "FIN_TRANSACTION_SEQ", "FIN_AUDIT_SEQ"};
                for (String seq : sequences) {
                    try (Statement stmt = conn.createStatement()) {
                        ResultSet rs = stmt.executeQuery("SELECT " + seq + ".CURRVAL FROM DUAL");
                        if (rs.next()) {
                            out.println("<tr><td>" + seq + "</td><td>" + rs.getLong(1) + "</td><td style='color:green;'>✓</td></tr>");
                        }
                    } catch (Exception e) {
                        // Try nextval if currval fails (first access)
                        try (Statement stmt2 = conn.createStatement()) {
                            ResultSet rs2 = stmt2.executeQuery("SELECT " + seq + ".NEXTVAL FROM DUAL");
                            if (rs2.next()) {
                                out.println("<tr><td>" + seq + "</td><td>" + rs2.getLong(1) + " (initialized)</td><td style='color:green;'>✓</td></tr>");
                            }
                        } catch (Exception e2) {
                            out.println("<tr><td>" + seq + "</td><td>-</td><td style='color:red;'>✗ Not found</td></tr>");
                        }
                    }
                }
                out.println("</table>");
                
            } else {
                out.println("<div class='status error'>✗ Database connection failed</div>");
            }
        } catch (Exception e) {
            out.println("<div class='status error'>✗ Database connection error: " + e.getMessage() + "</div>");
            out.println("<div class='status warning'>Check if Oracle is running at: " + DatabaseConfig.getJdbcUrl() + "</div>");
        }
    }

    private void initializeDatabase(PrintWriter out) {
        out.println("<h2>▶ Database Initialization</h2>");
        
        try {
            // Read schema.sql
            InputStream is = getClass().getClassLoader().getResourceAsStream("sql/schema.sql");
            if (is == null) {
                out.println("<div class='status error'>✗ schema.sql not found in resources!</div>");
                return;
            }

            List<String> statements = parseSqlFile(is);
            out.println("<div class='status info'>Found " + statements.size() + " SQL statements to execute</div>");

            try (Connection conn = DatabaseConfig.getConnection()) {
                conn.setAutoCommit(false);
                
                int success = 0;
                int failed = 0;
                StringBuilder log = new StringBuilder();
                
                for (String sql : statements) {
                    String shortSql = sql.length() > 60 ? sql.substring(0, 60) + "..." : sql;
                    shortSql = shortSql.replace("\n", " ").trim();
                    
                    try (Statement stmt = conn.createStatement()) {
                        stmt.execute(sql);
                        log.append("✓ ").append(shortSql).append("\n");
                        success++;
                    } catch (Exception e) {
                        String errMsg = e.getMessage().split("\n")[0];
                        if (sql.toUpperCase().contains("DROP")) {
                            log.append("⊘ ").append(shortSql).append(" (skipped - object doesn't exist)\n");
                        } else {
                            log.append("✗ ").append(shortSql).append(" - ").append(errMsg).append("\n");
                            failed++;
                        }
                    }
                }
                
                conn.commit();
                
                out.println("<div class='status success'>✓ Executed: " + success + " successful</div>");
                if (failed > 0) {
                    out.println("<div class='status warning'>⚠ Failed: " + failed + " statements</div>");
                }
                
                out.println("<h3>Execution Log</h3>");
                out.println("<pre>" + log.toString() + "</pre>");
            }
            
        } catch (Exception e) {
            out.println("<div class='status error'>✗ Initialization failed: " + e.getMessage() + "</div>");
            e.printStackTrace();
        }
    }

    private void resetDatabase(PrintWriter out) {
        out.println("<h2>🗑 Database Reset</h2>");
        out.println("<div class='status warning'>⚠ Dropping and recreating all tables...</div>");
        
        // This just calls init which handles drops and creates
        initializeDatabase(out);
    }

    private List<String> parseSqlFile(InputStream is) throws Exception {
        List<String> statements = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean inPlsqlBlock = false;

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();
                
                if (trimmed.isEmpty() || trimmed.startsWith("--")) {
                    continue;
                }

                if (trimmed.toUpperCase().startsWith("BEGIN") || 
                    trimmed.toUpperCase().startsWith("DECLARE") ||
                    trimmed.toUpperCase().startsWith("CREATE OR REPLACE")) {
                    inPlsqlBlock = true;
                }

                current.append(line).append("\n");

                if (inPlsqlBlock) {
                    if (trimmed.equals("/")) {
                        String sql = current.toString().replace("\n/", "").trim();
                        if (!sql.isEmpty()) {
                            statements.add(sql);
                        }
                        current = new StringBuilder();
                        inPlsqlBlock = false;
                    }
                } else {
                    if (trimmed.endsWith(";")) {
                        String sql = current.toString().trim();
                        sql = sql.substring(0, sql.length() - 1);
                        if (!sql.isEmpty()) {
                            statements.add(sql);
                        }
                        current = new StringBuilder();
                    }
                }
            }
        }

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
