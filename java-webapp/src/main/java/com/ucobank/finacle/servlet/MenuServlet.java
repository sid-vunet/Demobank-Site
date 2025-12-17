package com.ucobank.finacle.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.ucobank.finacle.model.MenuItem;
import com.ucobank.finacle.service.MenuService;

/**
 * Menu Servlet - Provides menu data for the left navigation panel
 * Returns JSON for AJAX requests or forwards to JSP for full page
 */
public class MenuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MenuService menuService = new MenuService();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authenticated") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not authenticated");
            return;
        }
        
        String format = request.getParameter("format");
        String userRole = (String) session.getAttribute("userRole");
        
        // Get menu items based on user role
        List<MenuItem> menuItems = menuService.getMenuItems(userRole);
        
        if ("json".equals(format)) {
            // Return JSON for AJAX requests
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print(gson.toJson(menuItems));
            out.flush();
        } else {
            // Set menu items as request attribute and forward to JSP
            request.setAttribute("menuItems", menuItems);
            request.getRequestDispatcher("/fininfra/ui/includes/leftmenu.jsp").forward(request, response);
        }
    }
}
