package com.swp391.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/staff/audit-logs"})
public class AdminAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        if (!StaffSessionGuard.authorize(
                request,
                response,
                "ADMIN",
                "You do not have permission to access the Admin area.")) {
            return;
        }

        chain.doFilter(request, response);
    }
}
