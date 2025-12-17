package com.ucobank.finacle.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Main SSO Servlet - Routes requests based on CALLTYPE parameter
 * Mimics Finacle's SSOServlet behavior
 */
public class SSOServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String callType = request.getParameter("CALLTYPE");
        HttpSession session = request.getSession();
        Boolean isAuthenticated = (Boolean) session.getAttribute("authenticated");
        
        if (callType == null) {
            callType = "GET_LOGIN_PAGE";
        }

        switch (callType) {
            case "GET_LOGIN_PAGE":
                // Show login page
                request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
                break;
                
            case "GET_BANK_HOME_PAGE":
                // Check if authenticated
                if (isAuthenticated != null && isAuthenticated) {
                    request.getRequestDispatcher("/fininfra/ui/home.jsp").forward(request, response);
                } else {
                    request.setAttribute("errorMessage", "Session expired. Please login again.");
                    request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
                }
                break;
                
            case "LOGOUT":
                // Invalidate session and redirect to login
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/fininfra/ui/SSOLogin.jsp");
                break;
                
            case "GET_MENU":
                // Return menu data (for AJAX calls)
                if (isAuthenticated != null && isAuthenticated) {
                    request.getRequestDispatcher("/menu").forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
                }
                break;
                
            default:
                // Default to login page
                request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
                break;
        }
    }
}
