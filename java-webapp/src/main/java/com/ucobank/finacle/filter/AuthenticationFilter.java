package com.ucobank.finacle.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Authentication Filter - Protects secured resources
 * Redirects unauthenticated users to login page
 */
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        HttpSession session = httpRequest.getSession(false);
        boolean isAuthenticated = false;
        
        if (session != null) {
            Boolean auth = (Boolean) session.getAttribute("authenticated");
            isAuthenticated = (auth != null && auth);
        }
        
        if (isAuthenticated) {
            // User is authenticated, continue with request
            chain.doFilter(request, response);
        } else {
            // User not authenticated, forward to login (keeps URL clean)
            httpRequest.getRequestDispatcher("/fininfra/ui/SSOLogin.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
