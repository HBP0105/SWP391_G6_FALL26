package com.swp391.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(urlPatterns = {"/Manager/*", "/manager/*", "/staff/orders", "/staff/order-detail"})
public class ManagerAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Object roleObject = session.getAttribute("role");
        String role = roleObject != null ? roleObject.toString() : null;

        if (!"MANAGER".equalsIgnoreCase(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to access the Manager area."
            );
            return;
        }

        Object staff = session.getAttribute("staff");
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        chain.doFilter(request, response);
    }
}
