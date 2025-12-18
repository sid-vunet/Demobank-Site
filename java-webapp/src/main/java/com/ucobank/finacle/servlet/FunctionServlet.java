package com.ucobank.finacle.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ucobank.finacle.service.FunctionService;

/**
 * Function Servlet - Handles function execution requests
 * Loads the appropriate content based on selected function
 */
public class FunctionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private FunctionService functionService = new FunctionService();

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
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authenticated") == null) {
            // Not authenticated - forward to login
            request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
            return;
        }
        
        String functionId = request.getParameter("functionId");
        String action = request.getParameter("action");
        
        if (functionId == null || functionId.trim().isEmpty()) {
            functionId = (String) session.getAttribute("currentFunction");
            if (functionId == null) functionId = "welcome";
        }
        
        // Get function data from service
        Object functionData = functionService.getFunctionData(functionId, action, request);
        
        // Store current function in session (for internal state management)
        session.setAttribute("currentView", "home");
        session.setAttribute("currentFunction", functionId);
        
        // Set function data as request attribute
        request.setAttribute("functionData", functionData);
        request.setAttribute("functionTitle", functionService.getFunctionTitle(functionId));
        
        // Forward to SSOLogin.jsp (URL stays clean)
        request.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
    }
}
