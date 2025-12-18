package com.ucobank.finacle.servlet;

import java.io.IOException;
import java.util.Date;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ucobank.finacle.model.User;
import com.ucobank.finacle.service.AuthenticationService;

/**
 * Login Servlet - Handles user authentication
 * Validates credentials and creates session on success
 */
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AuthenticationService authService = new AuthenticationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("txtLoginId");
        String password = request.getParameter("txtPassword");
        
        // Validate input
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("errorMessage", "User ID is required");
            request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Password is required");
            request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
            return;
        }
        
        // Authenticate user
        User user = authService.authenticate(username.trim(), password);
        
        if (user != null) {
            // Authentication successful - create session
            HttpSession session = request.getSession(true);
            
            // Set session attributes
            session.setAttribute("authenticated", true);
            session.setAttribute("user", user);
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("solution", "FININFRA");
            session.setAttribute("loginTime", new Date());
            session.setAttribute("sessionToken", UUID.randomUUID().toString());
            
            // Set session timeout (30 minutes)
            session.setMaxInactiveInterval(30 * 60);
            
            // Set current view in session (no URL params)
            session.setAttribute("currentView", "home");
            session.setAttribute("currentFunction", "welcome");
            
            // Forward to SSOLogin.jsp (URL stays clean)
            request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
            
        } else {
            // Authentication failed
            request.setAttribute("errorMessage", "Invalid User ID or Password");
            request.setAttribute("lastUserId", username);
            request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward GET requests to login page (not redirect, keeps URL clean)
        request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
    }
}
